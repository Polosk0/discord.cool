import { SlashCommandBuilder, ChatInputCommandInteraction, EmbedBuilder } from 'discord.js';
import { portScanService } from '../../services/network';
import { isValidIp, isValidDomain, isValidPort } from '../../utils/validators';
import { rateLimiter } from '../../utils/rate-limiter';

export const data = new SlashCommandBuilder()
  .setName('port-scan')
  .setDescription('Scan ports on a host')
  .addStringOption((option) =>
    option
      .setName('host')
      .setDescription('Host to scan (IP or domain)')
      .setRequired(true)
  )
  .addStringOption((option) =>
    option
      .setName('type')
      .setDescription('Scan type')
      .setRequired(true)
      .addChoices(
        { name: 'Common Ports', value: 'common' },
        { name: 'Port Range', value: 'range' },
        { name: 'Single Port', value: 'single' }
      )
  )
  .addIntegerOption((option) =>
    option
      .setName('port')
      .setDescription('Port number (for single port scan)')
      .setMinValue(1)
      .setMaxValue(65535)
  )
  .addIntegerOption((option) =>
    option
      .setName('start-port')
      .setDescription('Start port (for range scan)')
      .setMinValue(1)
      .setMaxValue(65535)
  )
  .addIntegerOption((option) =>
    option
      .setName('end-port')
      .setDescription('End port (for range scan)')
      .setMinValue(1)
      .setMaxValue(65535)
  );

export async function execute(interaction: ChatInputCommandInteraction): Promise<void> {
  if (!rateLimiter.isAllowed(interaction.user.id, 'port-scan', 3, 60000)) {
    await interaction.reply({
      content: '❌ Rate limit exceeded. Please wait before using this command again.',
      ephemeral: true,
    });
    return;
  }

  const host = interaction.options.getString('host', true);
  const type = interaction.options.getString('type', true);
  const port = interaction.options.getInteger('port');
  const startPort = interaction.options.getInteger('start-port');
  const endPort = interaction.options.getInteger('end-port');

  if (!isValidIp(host) && !isValidDomain(host)) {
    await interaction.reply({
      content: '❌ Invalid host. Please provide a valid IP address or domain.',
      ephemeral: true,
    });
    return;
  }

  if (type === 'single' && (!port || !isValidPort(port))) {
    await interaction.reply({
      content: '❌ Invalid port number for single port scan.',
      ephemeral: true,
    });
    return;
  }

  if (type === 'range' && (!startPort || !endPort || !isValidPort(startPort) || !isValidPort(endPort) || startPort > endPort)) {
    await interaction.reply({
      content: '❌ Invalid port range. Please provide valid start and end ports.',
      ephemeral: true,
    });
    return;
  }

  await interaction.deferReply();

  try {
    let result;

    if (type === 'common') {
      result = await portScanService.scanCommonPorts(host);
    } else if (type === 'single' && port) {
      const isOpen = await portScanService.scanPort(host, port);
      result = {
        host,
        ports: isOpen ? [port] : [],
        status: isOpen ? 'open' : 'closed',
      };
    } else if (type === 'range' && startPort && endPort) {
      result = await portScanService.scanPortRange(host, startPort, endPort);
    } else {
      throw new Error('Invalid scan type configuration');
    }

    const embed = new EmbedBuilder()
      .setTitle('🔍 Port Scan Results')
      .setColor(result.ports.length > 0 ? 0x00ff00 : 0xff0000)
      .addFields(
        { name: 'Host', value: host, inline: true },
        { name: 'Status', value: result.status, inline: true },
        { name: 'Open Ports', value: result.ports.length.toString(), inline: true }
      )
      .setTimestamp();

    if (result.ports.length > 0) {
      const portsText = result.ports.slice(0, 20).join(', ');
      embed.addFields({
        name: 'Ports',
        value: portsText.length > 1024 ? portsText.substring(0, 1021) + '...' : portsText,
        inline: false,
      });
    } else {
      embed.addFields({
        name: 'Result',
        value: 'No open ports found',
        inline: false,
      });
    }

    await interaction.editReply({ embeds: [embed] });
  } catch (error: any) {
    await interaction.editReply({
      content: `❌ Failed to scan ports: ${error.message}`,
    });
  }
}

