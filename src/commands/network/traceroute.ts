import { SlashCommandBuilder, ChatInputCommandInteraction, EmbedBuilder } from 'discord.js';
import { tracerouteService } from '../../services/network';
import { isValidIp, isValidDomain } from '../../utils/validators';
import { rateLimiter } from '../../utils/rate-limiter';

export const data = new SlashCommandBuilder()
  .setName('traceroute')
  .setDescription('Trace the route to a host')
  .addStringOption((option) =>
    option
      .setName('host')
      .setDescription('Host to trace (IP or domain)')
      .setRequired(true)
  )
  .addIntegerOption((option) =>
    option
      .setName('max-hops')
      .setDescription('Maximum number of hops')
      .setMinValue(1)
      .setMaxValue(30)
  );

export async function execute(interaction: ChatInputCommandInteraction): Promise<void> {
  if (!rateLimiter.isAllowed(interaction.user.id, 'traceroute', 5, 60000)) {
    await interaction.reply({
      content: '❌ Rate limit exceeded. Please wait before using this command again.',
      ephemeral: true,
    });
    return;
  }

  const host = interaction.options.getString('host', true);
  const maxHops = interaction.options.getInteger('max-hops') || 30;

  if (!isValidIp(host) && !isValidDomain(host)) {
    await interaction.reply({
      content: '❌ Invalid host. Please provide a valid IP address or domain.',
      ephemeral: true,
    });
    return;
  }

  await interaction.deferReply();

  try {
    const result = await tracerouteService.trace(host, maxHops);

    const embed = new EmbedBuilder()
      .setTitle('🛤️ Traceroute Results')
      .setColor(result.success ? 0x00ff00 : 0xff0000)
      .addFields(
        { name: 'Host', value: host, inline: true },
        { name: 'Status', value: result.success ? '✅ Success' : '❌ Failed', inline: true },
        { name: 'Hops', value: result.hops.length.toString(), inline: true }
      )
      .setTimestamp();

    if (result.success && result.hops.length > 0) {
      const hopsText = result.hops
        .slice(0, 10)
        .map((hop) => `${hop.hop}. ${hop.hostname || hop.ip} (${hop.latency}ms)`)
        .join('\n');

      embed.addFields({
        name: 'Route',
        value: hopsText.length > 1024 ? hopsText.substring(0, 1021) + '...' : hopsText,
        inline: false,
      });
    } else if (result.error) {
      embed.addFields({ name: 'Error', value: result.error, inline: false });
    }

    await interaction.editReply({ embeds: [embed] });
  } catch (error: any) {
    await interaction.editReply({
      content: `❌ Failed to trace route: ${error.message}`,
    });
  }
}

