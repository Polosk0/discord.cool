import { SlashCommandBuilder, ChatInputCommandInteraction, EmbedBuilder } from 'discord.js';
import { pingService } from '../../services/network';
import { isValidIp, isValidDomain } from '../../utils/validators';
import { rateLimiter } from '../../utils/rate-limiter';

export const data = new SlashCommandBuilder()
  .setName('ping')
  .setDescription('Ping a host')
  .addStringOption((option) =>
    option
      .setName('host')
      .setDescription('Host to ping (IP or domain)')
      .setRequired(true)
  )
  .addIntegerOption((option) =>
    option
      .setName('count')
      .setDescription('Number of ping packets')
      .setMinValue(1)
      .setMaxValue(10)
  );

export async function execute(interaction: ChatInputCommandInteraction): Promise<void> {
  if (!rateLimiter.isAllowed(interaction.user.id, 'ping', 10, 60000)) {
    await interaction.reply({
      content: '❌ Rate limit exceeded. Please wait before using this command again.',
      ephemeral: true,
    });
    return;
  }

  const host = interaction.options.getString('host', true);
  const count = interaction.options.getInteger('count') || 4;

  if (!isValidIp(host) && !isValidDomain(host)) {
    await interaction.reply({
      content: '❌ Invalid host. Please provide a valid IP address or domain.',
      ephemeral: true,
    });
    return;
  }

  await interaction.deferReply();

  try {
    const result = await pingService.ping(host, count);

    const embed = new EmbedBuilder()
      .setTitle('📡 Ping Results')
      .setColor(result.success ? 0x00ff00 : 0xff0000)
      .addFields(
        { name: 'Host', value: host, inline: true },
        { name: 'Status', value: result.success ? '✅ Success' : '❌ Failed', inline: true },
        { name: 'Packets', value: count.toString(), inline: true }
      )
      .setTimestamp();

    if (result.success) {
      if (result.latency !== undefined) {
        embed.addFields({ name: 'Latency', value: `${result.latency}ms`, inline: true });
      }
      if (result.packetLoss !== undefined) {
        embed.addFields({ name: 'Packet Loss', value: `${result.packetLoss}%`, inline: true });
      }
    } else if (result.error) {
      embed.addFields({ name: 'Error', value: result.error, inline: false });
    }

    await interaction.editReply({ embeds: [embed] });
  } catch (error: any) {
    await interaction.editReply({
      content: `❌ Failed to ping host: ${error.message}`,
    });
  }
}

