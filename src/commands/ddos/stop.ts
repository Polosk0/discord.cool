import { SlashCommandBuilder, ChatInputCommandInteraction, EmbedBuilder } from 'discord.js';
import { ddosService } from '../../services/ddos';
import { isAdmin } from '../../utils/validators';
import { licenseService } from '../../services/license';
import { logger } from '../../utils/logger';

export const data = new SlashCommandBuilder()
  .setName('stop')
  .setDescription('Stop all active DDoS attacks');

export async function execute(interaction: ChatInputCommandInteraction): Promise<void> {
  if (!isAdmin(interaction.user.id) && !licenseService.hasPermission(interaction.user.id, 'attack')) {
    await interaction.reply({
      content: '❌ You do not have permission to use this command.',
      ephemeral: true,
    });
    return;
  }

  await interaction.deferReply();

  try {
    ddosService.stopAll();

    const embed = new EmbedBuilder()
      .setTitle('🛑 All Attacks Stopped')
      .setColor(0x00ff00)
      .setDescription('All active DDoS attacks have been stopped.')
      .setTimestamp();

    await interaction.editReply({ embeds: [embed] });

    logger.info(`All attacks stopped by ${interaction.user.id}`);
  } catch (error: any) {
    logger.error('Failed to stop attacks', error);
    await interaction.editReply({
      content: `❌ Failed to stop attacks: ${error.message}`,
    });
  }
}

