import { SlashCommandBuilder, ChatInputCommandInteraction, ModalBuilder, TextInputBuilder, TextInputStyle, ActionRowBuilder } from 'discord.js';
import { isAdmin } from '../../utils/validators';

export const data = new SlashCommandBuilder()
  .setName('license-create')
  .setDescription('Create a license for a user')
  .addUserOption((option) =>
    option
      .setName('user')
      .setDescription('User to create license for')
      .setRequired(true)
  );

export async function execute(interaction: ChatInputCommandInteraction): Promise<void> {
  if (!isAdmin(interaction.user.id)) {
    await interaction.reply({
      content: '❌ You do not have permission to use this command.',
      flags: MessageFlags.Ephemeral,
    });
    return;
  }

  const user = interaction.options.getUser('user', true);

  const modal = new ModalBuilder()
    .setCustomId(`license_create_${user.id}`)
    .setTitle('Create License');

  const daysInput = new TextInputBuilder()
    .setCustomId('days')
    .setLabel('Expiration Days (0 = permanent)')
    .setStyle(TextInputStyle.Short)
    .setPlaceholder('30')
    .setRequired(true)
    .setMaxLength(4);

  const permissionsInput = new TextInputBuilder()
    .setCustomId('permissions')
    .setLabel('Permissions (comma-separated)')
    .setStyle(TextInputStyle.Short)
    .setPlaceholder('bot,attack')
    .setValue('bot,attack')
    .setRequired(true);

  const daysRow = new ActionRowBuilder<TextInputBuilder>().addComponents(daysInput);
  const permissionsRow = new ActionRowBuilder<TextInputBuilder>().addComponents(permissionsInput);

  modal.addComponents(daysRow, permissionsRow);

  await interaction.showModal(modal);
}

