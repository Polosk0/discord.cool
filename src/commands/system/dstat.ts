import {
  SlashCommandBuilder,
  ChatInputCommandInteraction,
  EmbedBuilder,
  ButtonBuilder,
  ButtonStyle,
  ActionRowBuilder,
  ComponentType,
} from 'discord.js';
import { dstatService } from '../../services/system';
import { rateLimiter } from '../../utils/rate-limiter';
import { licenseService } from '../../services/license';

export const data = new SlashCommandBuilder()
  .setName('dstat')
  .setDescription('Display live system statistics (updates every second)');

function createStatsEmbed() {
  const stats = dstatService.getStats();

  const cpuBar = createProgressBar(stats.cpu.usage, 20);
  const memoryBar = createProgressBar(stats.memory.percentage, 20);
  const diskBar = createProgressBar(stats.disk.percentage, 20);

  return new EmbedBuilder()
    .setTitle('📊 System Statistics - Live')
    .setColor(0x0099ff)
    .addFields(
      {
        name: '💻 CPU',
        value: `\`${cpuBar}\` ${stats.cpu.usage.toFixed(1)}%\nCores: ${stats.cpu.cores}`,
        inline: true,
      },
      {
        name: '🧠 Memory',
        value: `\`${memoryBar}\` ${stats.memory.percentage.toFixed(1)}%\n${dstatService.formatBytes(stats.memory.used)} / ${dstatService.formatBytes(stats.memory.total)}`,
        inline: true,
      },
      {
        name: '💾 Disk',
        value: `\`${diskBar}\` ${stats.disk.percentage.toFixed(1)}%\n${dstatService.formatBytes(stats.disk.used)} / ${dstatService.formatBytes(stats.disk.total)}`,
        inline: true,
      },
      {
        name: '🌐 Network',
        value: `⬇️ ${dstatService.formatBytes(stats.network.received)}\n⬆️ ${dstatService.formatBytes(stats.network.sent)}`,
        inline: true,
      },
      {
        name: '⏱️ Uptime',
        value: formatUptime(process.uptime()),
        inline: true,
      },
      {
        name: '🔄 Status',
        value: '🟢 Live Updates Active',
        inline: true,
      }
    )
    .setFooter({ text: 'Updates every second • Click Stop to end live updates' })
    .setTimestamp();
}

function createProgressBar(percentage: number, length: number): string {
  const filled = Math.round((percentage / 100) * length);
  const empty = length - filled;
  const bar = '█'.repeat(filled) + '░'.repeat(empty);
  return bar;
}

function formatUptime(seconds: number): string {
  const days = Math.floor(seconds / 86400);
  const hours = Math.floor((seconds % 86400) / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  const secs = Math.floor(seconds % 60);

  if (days > 0) return `${days}d ${hours}h ${minutes}m`;
  if (hours > 0) return `${hours}h ${minutes}m ${secs}s`;
  if (minutes > 0) return `${minutes}m ${secs}s`;
  return `${secs}s`;
}

export async function execute(interaction: ChatInputCommandInteraction): Promise<void> {
  if (!licenseService.hasPermission(interaction.user.id, 'bot')) {
    await interaction.reply({
      content: '❌ You need a valid license to use this command. Use `/license-activate` to activate your license.',
      flags: MessageFlags.Ephemeral,
    });
    return;
  }

  if (!rateLimiter.isAllowed(interaction.user.id, 'dstat', 5, 60000)) {
    await interaction.reply({
      content: '❌ Rate limit exceeded. Please wait before using this command again.',
      flags: MessageFlags.Ephemeral,
    });
    return;
  }

  await interaction.deferReply();

  const embed = createStatsEmbed();
  const stopButton = new ButtonBuilder()
    .setCustomId('dstat_stop')
    .setLabel('Stop Updates')
    .setStyle(ButtonStyle.Danger);

  const row = new ActionRowBuilder<ButtonBuilder>().addComponents(stopButton);

  const message = await interaction.editReply({
    embeds: [embed],
    components: [row],
  });

  const updateInterval = setInterval(async () => {
    try {
      const newEmbed = createStatsEmbed();
      await interaction.editReply({
        embeds: [newEmbed],
        components: [row],
      });
    } catch (error) {
      clearInterval(updateInterval);
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

    if (buttonInteraction.customId === 'dstat_stop') {
      clearInterval(updateInterval);
      collector.stop();

      const finalEmbed = createStatsEmbed();
      finalEmbed.setFooter({ text: 'Live updates stopped' });

      await buttonInteraction.update({
        embeds: [finalEmbed],
        components: [],
      });
    }
  });

  collector.on('end', async () => {
    clearInterval(updateInterval);
    try {
      const finalEmbed = createStatsEmbed();
      finalEmbed.setFooter({ text: 'Live updates expired' });
      await interaction.editReply({
        embeds: [finalEmbed],
        components: [],
      });
    } catch {
    }
  });
}

