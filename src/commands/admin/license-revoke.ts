import { SlashCommandBuilder, ChatInputCommandInteraction, EmbedBuilder } from 'discord.js';
import { licenseService } from '../../services/license';
import { isAdmin } from '../../utils/validators';

export const data = new SlashCommandBuilder()
  .setName('license-revoke')
  .setDescription('Revoke a user license')
  .addUserOption((option) =>
    option
      .setName('user')
      .setDescription('User to revoke license from')
      .setRequired(true)
  );

export async function execute(interaction: ChatInputCommandInteraction): Promise<void> {
  if (!isAdmin(interaction.user.id)) {
    await interaction.reply({
      content: '❌ You do not have permission to use this command.',
      ephemeral: true,
    });
    return;
  }

  const user = interaction.options.getUser('user', true);

  await interaction.deferReply({ ephemeral: true });

  const revoked = licenseService.revokeLicense(user.id);

  if (revoked) {
    const embed = new EmbedBuilder()
      .setTitle('✅ License Revoked')
      .setColor(0x00ff00)
      .setDescription(`License revoked for ${user.tag}`)
      .setTimestamp();

    await interaction.editReply({ embeds: [embed] });
  } else {
    await interaction.editReply({
      content: `❌ No license found for ${user.tag}`,
    });
  }
}

