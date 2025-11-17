import { SlashCommandBuilder, ChatInputCommandInteraction, EmbedBuilder, ModalBuilder, TextInputBuilder, TextInputStyle, ActionRowBuilder } from 'discord.js';
import { licenseService } from '../../services/license';

export const data = new SlashCommandBuilder()
  .setName('license-activate')
  .setDescription('Activate your license key');

export async function execute(interaction: ChatInputCommandInteraction): Promise<void> {
  const modal = new ModalBuilder()
    .setCustomId(`license_activate_${interaction.user.id}`)
    .setTitle('Activate License');

  const keyInput = new TextInputBuilder()
    .setCustomId('license_key')
    .setLabel('License Key')
    .setStyle(TextInputStyle.Short)
    .setPlaceholder('XXXX-XXXX-XXXX-XXXX')
    .setRequired(true)
    .setMaxLength(19);

  const keyRow = new ActionRowBuilder<TextInputBuilder>().addComponents(keyInput);

  modal.addComponents(keyRow);

  await interaction.showModal(modal);
}

