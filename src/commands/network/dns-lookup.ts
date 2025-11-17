import { SlashCommandBuilder, ChatInputCommandInteraction, EmbedBuilder } from 'discord.js';
import { dnsLookupService } from '../../services/network';
import { isValidIp, isValidDomain } from '../../utils/validators';
import { rateLimiter } from '../../utils/rate-limiter';

export const data = new SlashCommandBuilder()
  .setName('dns-lookup')
  .setDescription('Perform DNS lookup')
  .addStringOption((option) =>
    option
      .setName('hostname')
      .setDescription('Hostname or IP address')
      .setRequired(true)
  )
  .addBooleanOption((option) =>
    option
      .setName('reverse')
      .setDescription('Perform reverse DNS lookup')
  );

export async function execute(interaction: ChatInputCommandInteraction): Promise<void> {
  if (!rateLimiter.isAllowed(interaction.user.id, 'dns-lookup', 10, 60000)) {
    await interaction.reply({
      content: '❌ Rate limit exceeded. Please wait before using this command again.',
      ephemeral: true,
    });
    return;
  }

  const hostname = interaction.options.getString('hostname', true);
  const reverse = interaction.options.getBoolean('reverse') || false;

  if (!isValidIp(hostname) && !isValidDomain(hostname)) {
    await interaction.reply({
      content: '❌ Invalid hostname or IP address.',
      ephemeral: true,
    });
    return;
  }

  await interaction.deferReply();

  try {
    const result = reverse && isValidIp(hostname)
      ? await dnsLookupService.reverseLookup(hostname)
      : await dnsLookupService.lookup(hostname);

    const embed = new EmbedBuilder()
      .setTitle('🔍 DNS Lookup Results')
      .setColor(result.success ? 0x00ff00 : 0xff0000)
      .addFields(
        { name: 'Hostname', value: hostname, inline: true },
        { name: 'Type', value: reverse ? 'Reverse DNS' : 'Forward DNS', inline: true },
        { name: 'Status', value: result.success ? '✅ Success' : '❌ Failed', inline: true }
      )
      .setTimestamp();

    if (result.success) {
      if (result.addresses.length > 0) {
        embed.addFields({
          name: reverse ? 'Hostname' : 'IP Addresses',
          value: result.addresses.join('\n'),
          inline: false,
        });
      }
    } else if (result.error) {
      embed.addFields({ name: 'Error', value: result.error, inline: false });
    }

    await interaction.editReply({ embeds: [embed] });
  } catch (error: any) {
    await interaction.editReply({
      content: `❌ Failed to perform DNS lookup: ${error.message}`,
    });
  }
}

