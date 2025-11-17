import { SlashCommandBuilder, ChatInputCommandInteraction, EmbedBuilder } from 'discord.js';
import { dstatService } from '../../services/system';
import { rateLimiter } from '../../utils/rate-limiter';

export const data = new SlashCommandBuilder()
  .setName('dstat')
  .setDescription('Display system statistics');

export async function execute(interaction: ChatInputCommandInteraction): Promise<void> {
  if (!rateLimiter.isAllowed(interaction.user.id, 'dstat', 10, 60000)) {
    await interaction.reply({
      content: '❌ Rate limit exceeded. Please wait before using this command again.',
      ephemeral: true,
    });
    return;
  }

  await interaction.deferReply();

  try {
    const stats = dstatService.getStats();

    const embed = new EmbedBuilder()
      .setTitle('📊 System Statistics')
      .setColor(0x0099ff)
      .addFields(
        {
          name: '💻 CPU',
          value: `Usage: ${stats.cpu.usage.toFixed(2)}%\nCores: ${stats.cpu.cores}`,
          inline: true,
        },
        {
          name: '🧠 Memory',
          value: `Used: ${dstatService.formatBytes(stats.memory.used)}\nTotal: ${dstatService.formatBytes(stats.memory.total)}\nUsage: ${stats.memory.percentage.toFixed(2)}%`,
          inline: true,
        },
        {
          name: '🌐 Network',
          value: `Received: ${dstatService.formatBytes(stats.network.received)}\nSent: ${dstatService.formatBytes(stats.network.sent)}`,
          inline: true,
        },
        {
          name: '💾 Disk',
          value: `Used: ${dstatService.formatBytes(stats.disk.used)}\nTotal: ${dstatService.formatBytes(stats.disk.total)}\nUsage: ${stats.disk.percentage.toFixed(2)}%`,
          inline: true,
        }
      )
      .setTimestamp();

    await interaction.editReply({ embeds: [embed] });
  } catch (error: any) {
    await interaction.editReply({
      content: `❌ Failed to get system statistics: ${error.message}`,
    });
  }
}

