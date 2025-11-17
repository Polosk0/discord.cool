import {
  SlashCommandBuilder,
  ChatInputCommandInteraction,
  EmbedBuilder,
  StringSelectMenuBuilder,
  ActionRowBuilder,
  ComponentType,
  MessageFlags,
} from 'discord.js';
import { licenseService } from '../../services/license';
import { rateLimiter } from '../../utils/rate-limiter';

export const data = new SlashCommandBuilder()
  .setName('methods')
  .setDescription('View detailed information about DDoS attack methods');

const methodDetails: Record<string, { name: string; description: string; howItWorks: string; bestFor: string; requirements: string; emoji: string }> = {
  'http-flood': {
    name: 'HTTP Flood',
    description: 'Overwhelms the target server with a flood of HTTP requests',
    howItWorks: 'Sends massive amounts of HTTP GET/POST requests to the target server, exhausting its resources and bandwidth. Each request consumes server resources to process.',
    bestFor: 'Web servers, HTTP-based services, websites',
    requirements: 'Target must accept HTTP connections (ports 80, 443, 8080, etc.)',
    emoji: '🌊',
  },
  'tcp-flood': {
    name: 'TCP Flood',
    description: 'Floods the target with TCP connection requests',
    howItWorks: 'Establishes numerous TCP connections to the target, consuming server resources. The server must allocate memory and processing power for each connection attempt.',
    bestFor: 'Any TCP-based service, servers with open TCP ports',
    requirements: 'Target port number (default: 80)',
    emoji: '⚡',
  },
  'udp-flood': {
    name: 'UDP Flood',
    description: 'Sends large volumes of UDP packets to random ports',
    howItWorks: 'Floods the target with UDP packets to random ports. The server must process each packet and respond with ICMP "Destination Unreachable" messages, consuming resources.',
    bestFor: 'DNS servers, gaming servers, VoIP services',
    requirements: 'Target port number',
    emoji: '💥',
  },
  'slowloris': {
    name: 'Slowloris',
    description: 'Slow HTTP attack that keeps connections open',
    howItWorks: 'Opens many HTTP connections and keeps them open by sending partial HTTP requests slowly. This exhausts the server\'s connection pool, preventing legitimate users from connecting.',
    bestFor: 'Web servers with limited connection pools, Apache servers',
    requirements: 'Target must accept HTTP connections',
    emoji: '🐌',
  },
  'syn-flood': {
    name: 'SYN Flood',
    description: 'Floods the target with TCP SYN packets',
    howItWorks: 'Sends many TCP SYN packets to initiate connections but never completes the handshake. The server keeps these half-open connections in memory, exhausting its connection table.',
    bestFor: 'Any TCP-based service, routers, firewalls',
    requirements: 'Target port number',
    emoji: '🔥',
  },
};

function createMethodEmbed(methodKey: string): EmbedBuilder {
  const method = methodDetails[methodKey];
  if (!method) {
    return new EmbedBuilder().setTitle('❌ Method not found').setColor(0xff0000);
  }

  return new EmbedBuilder()
    .setTitle(`${method.emoji} ${method.name}`)
    .setColor(0x0099ff)
    .setDescription(method.description)
    .addFields(
      {
        name: '🔧 How It Works',
        value: method.howItWorks,
        inline: false,
      },
      {
        name: '🎯 Best For',
        value: method.bestFor,
        inline: true,
      },
      {
        name: '📋 Requirements',
        value: method.requirements,
        inline: true,
      }
    )
    .setFooter({ text: 'Select another method to view details' })
    .setTimestamp();
}

function createMethodSelectMenu(): ActionRowBuilder<StringSelectMenuBuilder> {
  return new ActionRowBuilder<StringSelectMenuBuilder>().addComponents(
    new StringSelectMenuBuilder()
      .setCustomId('methods_select')
      .setPlaceholder('Select a method to view details...')
      .addOptions(
        Object.entries(methodDetails).map(([value, method]) => ({
          label: method.name,
          description: method.description.substring(0, 100),
          value,
          emoji: method.emoji,
        }))
      )
  );
}

export async function execute(interaction: ChatInputCommandInteraction): Promise<void> {
  if (!licenseService.hasPermission(interaction.user.id, 'bot')) {
    await interaction.reply({
      content: '❌ You need a valid license to use this command. Use `/license-activate` to activate your license.',
      flags: MessageFlags.Ephemeral,
    });
    return;
  }

  if (!rateLimiter.isAllowed(interaction.user.id, 'methods', 10, 60000)) {
    await interaction.reply({
      content: '❌ Rate limit exceeded. Please wait before using this command again.',
      flags: MessageFlags.Ephemeral,
    });
    return;
  }

  const embed = new EmbedBuilder()
    .setTitle('📚 DDoS Attack Methods')
    .setColor(0x0099ff)
    .setDescription('Select a method from the menu below to view detailed information about how it works.')
    .addFields(
      {
        name: '📋 Available Methods',
        value: Object.entries(methodDetails)
          .map(([, method]) => `${method.emoji} **${method.name}**`)
          .join('\n'),
        inline: false,
      }
    )
    .setFooter({ text: 'Select a method to view detailed information' })
    .setTimestamp();

  const selectMenu = createMethodSelectMenu();

  const response = await interaction.reply({
    embeds: [embed],
    components: [selectMenu],
    flags: MessageFlags.Ephemeral,
  });

  const collector = response.createMessageComponentCollector({
    componentType: ComponentType.StringSelect,
    time: 300000,
  });

  collector.on('collect', async (selectInteraction) => {
    if (selectInteraction.user.id !== interaction.user.id) {
      await selectInteraction.reply({
        content: '❌ This menu is not for you!',
        flags: MessageFlags.Ephemeral,
      });
      return;
    }

    const selectedMethod = selectInteraction.values[0];
    const methodEmbed = createMethodEmbed(selectedMethod);

    await selectInteraction.update({
      embeds: [methodEmbed],
      components: [selectMenu],
    });
  });

  collector.on('end', async () => {
    try {
      const expiredEmbed = new EmbedBuilder()
        .setTitle('⏱️ Menu Expired')
        .setColor(0xff0000)
        .setDescription('This menu has expired. Use `/methods` to open a new one.')
        .setTimestamp();

      await interaction.editReply({
        embeds: [expiredEmbed],
        components: [],
      });
    } catch {
    }
  });
}

