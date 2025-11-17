import {
  SlashCommandBuilder,
  ChatInputCommandInteraction,
  EmbedBuilder,
  ButtonBuilder,
  ButtonStyle,
  ActionRowBuilder,
  ComponentType,
  MessageFlags,
} from 'discord.js';
import { checkHostService } from '../../services/network';
import { isValidIp, isValidDomain } from '../../utils/validators';
import { rateLimiter } from '../../utils/rate-limiter';
import { licenseService } from '../../services/license';

export const data = new SlashCommandBuilder()
  .setName('ping')
  .setDescription('Ping a host from multiple locations worldwide (live updates)')
  .addStringOption((option) =>
    option
      .setName('host')
      .setDescription('Host to ping (IP or domain)')
      .setRequired(true)
  )
  .addIntegerOption((option) =>
    option
      .setName('nodes')
      .setDescription('Number of nodes to ping from (1-10)')
      .setMinValue(1)
      .setMaxValue(10)
  );

function createPingEmbed(host: string, nodes: any[], completed: boolean, requestId?: string): EmbedBuilder {
  const embed = new EmbedBuilder()
    .setTitle(`📡 Ping Test - ${host}`)
    .setColor(completed ? 0x00ff00 : 0x0099ff)
    .setDescription(completed ? '✅ All nodes completed' : '🔄 Testing in progress...')
    .setTimestamp();

  if (nodes.length === 0) {
    embed.addFields({
      name: '⏳ Status',
      value: 'Initializing ping test from multiple locations...',
      inline: false,
    });
    return embed;
  }

  const okNodes = nodes.filter((n) => n.status === 'OK');
  const errorNodes = nodes.filter((n) => n.status === 'ERROR');
  const pendingNodes = nodes.filter((n) => n.status === 'PENDING');

  if (okNodes.length > 0) {
    const avgLatency = okNodes.reduce((sum, n) => sum + (n.rtt || 0), 0) / okNodes.length;
    const minLatency = Math.min(...okNodes.map((n) => n.rtt || Infinity));
    const maxLatency = Math.max(...okNodes.map((n) => n.rtt || 0));

    embed.addFields({
      name: '📊 Statistics',
      value: `✅ Success: ${okNodes.length}/${nodes.length}\n📈 Avg: ${avgLatency.toFixed(2)}ms\n⚡ Min: ${minLatency}ms\n📉 Max: ${maxLatency}ms`,
      inline: true,
    });
  }

  if (pendingNodes.length > 0) {
    embed.addFields({
      name: '⏳ Pending',
      value: `${pendingNodes.length} node(s) still testing...`,
      inline: true,
    });
  }

  if (errorNodes.length > 0) {
    embed.addFields({
      name: '❌ Errors',
      value: `${errorNodes.length} node(s) failed`,
      inline: true,
    });
  }

  const nodeFields: string[] = [];
  for (const node of nodes.slice(0, 10)) {
    let status = '';
    if (node.status === 'OK') {
      status = `✅ ${node.rtt}ms`;
    } else if (node.status === 'ERROR') {
      status = `❌ ${node.error || 'Failed'}`;
    } else {
      status = '⏳ Testing...';
    }
    nodeFields.push(`${node.location} **${node.node}**\n${status}`);
  }

  if (nodeFields.length > 0) {
    embed.addFields({
      name: '🌍 Nodes',
      value: nodeFields.join('\n\n'),
      inline: false,
    });
  }

  if (requestId) {
    embed.setFooter({ text: `Request ID: ${requestId.substring(0, 8)}...` });
  }

  return embed;
}

export async function execute(interaction: ChatInputCommandInteraction): Promise<void> {
  if (!licenseService.hasPermission(interaction.user.id, 'bot')) {
    await interaction.reply({
      content: '❌ You need a valid license to use this command. Use `/license-activate` to activate your license.',
      flags: MessageFlags.Ephemeral,
    });
    return;
  }

  if (!rateLimiter.isAllowed(interaction.user.id, 'ping', 5, 60000)) {
    await interaction.reply({
      content: '❌ Rate limit exceeded. Please wait before using this command again.',
      flags: MessageFlags.Ephemeral,
    });
    return;
  }

  const host = interaction.options.getString('host', true);
  const maxNodes = interaction.options.getInteger('nodes') || 5;

  if (!isValidIp(host) && !isValidDomain(host)) {
    await interaction.reply({
      content: '❌ Invalid host. Please provide a valid IP address or domain.',
      flags: MessageFlags.Ephemeral,
    });
    return;
  }

  await interaction.deferReply();

  try {
    const requestId = await checkHostService.startPingCheck(host, maxNodes);

    const embed = createPingEmbed(host, [], false, requestId);
    const stopButton = new ButtonBuilder()
      .setCustomId('ping_stop')
      .setLabel('Stop Updates')
      .setStyle(ButtonStyle.Danger);

    const row = new ActionRowBuilder<ButtonBuilder>().addComponents(stopButton);

    const message = await interaction.editReply({
      embeds: [embed],
      components: [row],
    });

    let stopped = false;
    const updateInterval = setInterval(async () => {
      if (stopped) {
        clearInterval(updateInterval);
        return;
      }

      try {
        const results = await checkHostService.getPingResults(requestId);
        const newEmbed = createPingEmbed(host, results.nodes, results.completed, requestId);

        await interaction.editReply({
          embeds: [newEmbed],
          components: [row],
        });

        if (results.completed) {
          clearInterval(updateInterval);
          const finalEmbed = createPingEmbed(host, results.nodes, true, requestId);
          finalEmbed.setFooter({ text: 'Test completed • Click Stop to end live updates' });
          await interaction.editReply({
            embeds: [finalEmbed],
            components: [row],
          });
        }
      } catch (error) {
        clearInterval(updateInterval);
        await interaction.editReply({
          content: `❌ Failed to get ping results: ${error instanceof Error ? error.message : 'Unknown error'}`,
          components: [],
        });
      }
    }, 1000);

    const collector = message.createMessageComponentCollector({
      componentType: ComponentType.Button,
      time: 300000,
    });

    collector.on('collect', async (buttonInteraction) => {
      if (buttonInteraction.user.id !== interaction.user.id) {
        await buttonInteraction.reply({
          content: '❌ This button is not for you!',
          flags: MessageFlags.Ephemeral,
        });
        return;
      }

      if (buttonInteraction.customId === 'ping_stop') {
        stopped = true;
        clearInterval(updateInterval);
        collector.stop();

        try {
          const finalResults = await checkHostService.getPingResults(requestId);
          const finalEmbed = createPingEmbed(host, finalResults.nodes, finalResults.completed, requestId);
          finalEmbed.setFooter({ text: 'Live updates stopped' });

          await buttonInteraction.update({
            embeds: [finalEmbed],
            components: [],
          });
        } catch {
          await buttonInteraction.update({
            components: [],
          });
        }
      }
    });

    collector.on('end', async () => {
      stopped = true;
      clearInterval(updateInterval);
      try {
        const finalResults = await checkHostService.getPingResults(requestId);
        const finalEmbed = createPingEmbed(host, finalResults.nodes, finalResults.completed, requestId);
        finalEmbed.setFooter({ text: 'Live updates expired' });
        await interaction.editReply({
          embeds: [finalEmbed],
          components: [],
        });
      } catch {
      }
    });
  } catch (error: any) {
    await interaction.editReply({
      content: `❌ Failed to start ping test: ${error.message}`,
    });
  }
}

