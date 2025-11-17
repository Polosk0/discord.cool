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
import { livePingService } from '../../services/network';
import { isValidIp, isValidDomain } from '../../utils/validators';
import { rateLimiter } from '../../utils/rate-limiter';
import { licenseService } from '../../services/license';

export const data = new SlashCommandBuilder()
  .setName('ping')
  .setDescription('Ping a host with live real-time updates (like Windows ping -t)')
  .addStringOption((option) =>
    option
      .setName('host')
      .setDescription('Host to ping (IP or domain)')
      .setRequired(true)
  );

function createPingEmbed(host: string, stats: any, isRunning: boolean): EmbedBuilder {
  const embed = new EmbedBuilder()
    .setTitle(`📡 Live Ping - ${host}`)
    .setColor(isRunning ? 0x00ff00 : 0xff0000)
    .setTimestamp();

  if (!stats || stats.packetsSent === 0) {
    embed.setDescription('🔄 Starting ping...')
      .addFields({
        name: '⏳ Status',
        value: 'Initializing ping test...',
        inline: false,
      });
    return embed;
  }

  const packetLossColor = stats.packetLoss === 0 ? '🟢' : stats.packetLoss < 10 ? '🟡' : '🔴';
  const latencyColor = stats.avgLatency < 50 ? '🟢' : stats.avgLatency < 100 ? '🟡' : '🔴';

  const statusEmoji = isRunning ? '🟢' : '🔴';
  const statusText = isRunning ? 'Running' : 'Stopped';

  embed.setDescription(`${statusEmoji} **${statusText}** - Live ping in progress`)
    .addFields(
      {
        name: '📊 Statistics',
        value: `**Packets:** ${stats.packetsReceived}/${stats.packetsSent}\n**Loss:** ${packetLossColor} ${stats.packetLoss.toFixed(1)}%\n**Status:** ${statusText}`,
        inline: true,
      },
      {
        name: '⚡ Latency',
        value: `**Current:** ${stats.currentLatency ? `${stats.currentLatency.toFixed(0)}ms` : 'N/A'}\n**Min:** ${stats.minLatency !== Infinity ? `${stats.minLatency.toFixed(0)}ms` : 'N/A'}\n**Max:** ${stats.maxLatency > 0 ? `${stats.maxLatency.toFixed(0)}ms` : 'N/A'}`,
        inline: true,
      },
      {
        name: '📈 Average',
        value: `${latencyColor} **${stats.avgLatency > 0 ? stats.avgLatency.toFixed(2) : '0.00'}ms**`,
        inline: true,
      }
    );

  if (stats.packetsReceived > 0) {
    const successRate = ((stats.packetsReceived / stats.packetsSent) * 100).toFixed(1);
    embed.addFields({
      name: '✅ Success Rate',
      value: `${successRate}%`,
      inline: true,
    });
  }

  const lastUpdate = new Date(stats.lastUpdate);
  const now = new Date();
  const secondsAgo = Math.floor((now.getTime() - lastUpdate.getTime()) / 1000);

  embed.setFooter({ 
    text: `Last update: ${secondsAgo}s ago • Click Stop to end ping` 
  });

  return embed;
}

function createProgressBar(value: number, max: number, length: number = 20): string {
  const percentage = Math.min(100, Math.max(0, (value / max) * 100));
  const filled = Math.round((percentage / 100) * length);
  const empty = length - filled;
  return '█'.repeat(filled) + '░'.repeat(empty);
}

export async function execute(interaction: ChatInputCommandInteraction): Promise<void> {
  if (!licenseService.hasPermission(interaction.user.id, 'bot')) {
    await interaction.reply({
      content: '❌ You need a valid license to use this command. Use `/license-activate` to activate your license.',
      flags: MessageFlags.Ephemeral,
    });
    return;
  }

  if (!rateLimiter.isAllowed(interaction.user.id, 'ping', 3, 60000)) {
    await interaction.reply({
      content: '❌ Rate limit exceeded. Please wait before using this command again.',
      flags: MessageFlags.Ephemeral,
    });
    return;
  }

  const host = interaction.options.getString('host', true);

  if (!isValidIp(host) && !isValidDomain(host)) {
    await interaction.reply({
      content: '❌ Invalid host. Please provide a valid IP address or domain.',
      flags: MessageFlags.Ephemeral,
    });
    return;
  }

  await interaction.deferReply();

  try {
    await livePingService.startLivePing(host, interaction.user.id);

    const stopButton = new ButtonBuilder()
      .setCustomId('ping_stop')
      .setLabel('🛑 Stop Ping')
      .setStyle(ButtonStyle.Danger);

    const row = new ActionRowBuilder<ButtonBuilder>().addComponents(stopButton);

    let stopped = false;
    let updateCount = 0;
    const maxUpdates = 300;

    const updateInterval = setInterval(async () => {
      if (stopped) {
        clearInterval(updateInterval);
        return;
      }

      updateCount++;
      if (updateCount > maxUpdates) {
        clearInterval(updateInterval);
        livePingService.stopPing(interaction.user.id, host);
        const finalStats = livePingService.getStats(interaction.user.id, host);
        const finalEmbed = createPingEmbed(host, finalStats, false);
        finalEmbed.setFooter({ text: 'Ping stopped - Maximum time reached (10 minutes)' });
        try {
          await interaction.editReply({
            embeds: [finalEmbed],
            components: [],
          });
        } catch {
          // Ignore
        }
        return;
      }

      try {
        const stats = livePingService.getStats(interaction.user.id, host);
        const embed = createPingEmbed(host, stats, !stopped);

        try {
          await interaction.editReply({
            embeds: [embed],
            components: [row],
          });
        } catch (editError: any) {
          if (editError.code === 40060 || editError.code === 10062) {
            clearInterval(updateInterval);
            livePingService.stopPing(interaction.user.id, host);
            return;
          }
          throw editError;
        }
      } catch (error: any) {
        if (error.code === 40060 || error.code === 10062) {
          clearInterval(updateInterval);
          livePingService.stopPing(interaction.user.id, host);
          return;
        }
        logger.error('Error updating ping embed', error);
      }
    }, 1000);

    const message = await interaction.editReply({
      embeds: [createPingEmbed(host, null, true)],
      components: [row],
    });

    const collector = message.createMessageComponentCollector({
      componentType: ComponentType.Button,
      time: 600000,
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
        livePingService.stopPing(interaction.user.id, host);

        const finalStats = livePingService.getStats(interaction.user.id, host);
        const finalEmbed = createPingEmbed(host, finalStats, false);
        finalEmbed.setFooter({ text: 'Ping stopped by user' });

        try {
          await buttonInteraction.update({
            embeds: [finalEmbed],
            components: [],
          });
        } catch {
          try {
            await interaction.editReply({
              embeds: [finalEmbed],
              components: [],
            });
          } catch {
            // Ignore
          }
        }
      }
    });

    collector.on('end', async () => {
      stopped = true;
      clearInterval(updateInterval);
      livePingService.stopPing(interaction.user.id, host);
      try {
        const finalStats = livePingService.getStats(interaction.user.id, host);
        const finalEmbed = createPingEmbed(host, finalStats, false);
        finalEmbed.setFooter({ text: 'Ping stopped - Interaction expired' });
        await interaction.editReply({
          embeds: [finalEmbed],
          components: [],
        });
      } catch {
        // Ignore
      }
    });
  } catch (error: any) {
    await interaction.editReply({
      content: `❌ Failed to start ping: ${error.message}`,
    });
  }
}
