import {
  SlashCommandBuilder,
  ChatInputCommandInteraction,
  EmbedBuilder,
  ActionRowBuilder,
  StringSelectMenuBuilder,
  StringSelectMenuInteraction,
  ComponentType,
  MessageFlags,
} from 'discord.js';
import { commands } from '../index';

export const data = new SlashCommandBuilder()
  .setName('help')
  .setDescription('Display help information with interactive menu');

const commandDescriptions: Record<string, { description: string; usage: string; category: string; permissions?: string; examples?: string[] }> = {
  attack: {
    description: 'Launch a DDoS attack on a target (interactive modal)',
    usage: '`/attack` - Opens interactive menu to select method and configure attack',
    category: '🚀 DDoS',
    permissions: '🔒 License Required (attack permission)',
    examples: [
      '`/attack` - Opens method selection menu',
    ],
  },
  methods: {
    description: 'View detailed information about DDoS attack methods',
    usage: '`/methods` - Opens interactive menu to browse attack methods',
    category: '🚀 DDoS',
    permissions: '🔒 License Required',
    examples: ['`/methods`'],
  },
  stop: {
    description: 'Stop all active DDoS attacks',
    usage: '`/stop`',
    category: '🚀 DDoS',
    permissions: '🔒 Admin Only',
    examples: ['`/stop`'],
  },
  ping: {
    description: 'Ping a host to test connectivity and measure latency',
    usage: '`/ping host:<ip|domain> [count:<1-10>]`',
    category: '🌐 Network',
    examples: [
      '`/ping host:google.com`',
      '`/ping host:8.8.8.8 count:5`',
    ],
  },
  traceroute: {
    description: 'Trace the network route to a host showing all hops',
    usage: '`/traceroute host:<ip|domain> [max-hops:<1-30>]`',
    category: '🌐 Network',
    examples: [
      '`/traceroute host:google.com`',
      '`/traceroute host:1.1.1.1 max-hops:20`',
    ],
  },
  'port-scan': {
    description: 'Scan ports on a target host to find open services',
    usage: '`/port-scan host:<ip|domain> type:<common|range|single> [options]`',
    category: '🌐 Network',
    examples: [
      '`/port-scan host:example.com type:common`',
      '`/port-scan host:192.168.1.1 type:range start-port:1 end-port:1000`',
      '`/port-scan host:example.com type:single port:443`',
    ],
  },
  'dns-lookup': {
    description: 'Perform DNS lookup or reverse DNS lookup',
    usage: '`/dns-lookup hostname:<hostname|ip> [reverse:<true|false>]`',
    category: '🌐 Network',
    examples: [
      '`/dns-lookup hostname:google.com`',
      '`/dns-lookup hostname:8.8.8.8 reverse:true`',
    ],
  },
  dstat: {
    description: 'Display live system statistics updated every second',
    usage: '`/dstat` - Shows real-time stats with live updates',
    category: '💻 System',
    permissions: '🔒 License Required',
    examples: ['`/dstat`'],
  },
  help: {
    description: 'Display this interactive help menu with all available commands',
    usage: '`/help`',
    category: '🛠️ Utility',
    examples: ['`/help`'],
  },
  'license-create': {
    description: 'Create a license for a user (Admin only)',
    usage: '`/license-create user:<user>` - Opens modal to configure license',
    category: '👑 Admin',
    permissions: '🔒 Admin Only',
    examples: ['`/license-create user:@user`'],
  },
  'license-revoke': {
    description: 'Revoke a user license (Admin only)',
    usage: '`/license-revoke user:<user>`',
    category: '👑 Admin',
    permissions: '🔒 Admin Only',
    examples: ['`/license-revoke user:@user`'],
  },
  'license-activate': {
    description: 'Activate your license key',
    usage: '`/license-activate` - Opens modal to enter license key',
    category: '👑 Admin',
    examples: ['`/license-activate`'],
  },
};

function createMainEmbed(): EmbedBuilder {
  const totalCommands = commands.size;
  const categories = {
    '🚀 DDoS': 3,
    '🌐 Network': 4,
    '💻 System': 1,
    '🛠️ Utility': 1,
    '👑 Admin': 3,
  };

  return new EmbedBuilder()
    .setTitle('📚 Bot Commands - Help Menu')
    .setColor(0x0099ff)
    .setDescription('Welcome to the interactive help menu! Select a category from the dropdown below to view detailed command information.\n\n**Quick Navigation:**\nUse the menu below to explore commands by category.')
    .addFields(
      {
        name: '🚀 DDoS Commands',
        value: `\`/attack\` - Launch attack (modal)\n\`/methods\` - View methods\n\`/stop\` - Stop attacks\n\n*${categories['🚀 DDoS']} command(s)*`,
        inline: true,
      },
      {
        name: '🌐 Network Commands',
        value: `\`/ping\` - Ping a host\n\`/traceroute\` - Trace route\n\`/port-scan\` - Scan ports\n\`/dns-lookup\` - DNS lookup\n\n*${categories['🌐 Network']} command(s)*`,
        inline: true,
      },
      {
        name: '💻 System Commands',
        value: `\`/dstat\` - System statistics\n\n*${categories['💻 System']} command(s)*`,
        inline: true,
      },
      {
        name: '🛠️ Utility Commands',
        value: `\`/help\` - Show this help menu\n\n*${categories['🛠️ Utility']} command(s)*`,
        inline: true,
      },
      {
        name: '👑 Admin Commands',
        value: `\`/license-create\` - Create license\n\`/license-revoke\` - Revoke license\n\`/license-activate\` - Activate license\n\n*3 command(s)*`,
        inline: true,
      }
    )
    .setFooter({ text: `Total commands: ${totalCommands} • Select a category to view details` })
    .setTimestamp();
}

function createCategoryEmbed(category: string): EmbedBuilder {
  const categoryCommands = Object.entries(commandDescriptions).filter(
    ([, info]) => info.category === category
  );

  const colorMap: Record<string, number> = {
    '🚀 DDoS': 0xff0000,
    '🌐 Network': 0x00ff00,
    '💻 System': 0x0099ff,
    '🛠️ Utility': 0xffa500,
    '👑 Admin': 0x9b59b6,
  };

  const embed = new EmbedBuilder()
    .setTitle(`${category} Commands`)
    .setColor(colorMap[category] || 0x0099ff)
    .setDescription(`Detailed information about ${category.toLowerCase()} commands`)
    .setTimestamp();

  for (const [commandName, info] of categoryCommands) {
    let fieldValue = `**${info.description}**\n\n📝 **Usage:**\n${info.usage}`;

    if (info.permissions) {
      fieldValue += `\n\n${info.permissions}`;
    }

    if (info.examples && info.examples.length > 0) {
      fieldValue += `\n\n💡 **Examples:**\n${info.examples.join('\n')}`;
    }

    embed.addFields({
      name: `\`/${commandName}\``,
      value: fieldValue,
      inline: false,
    });
  }

  embed.setFooter({ text: `${categoryCommands.length} command(s) in this category` });

  return embed;
}

function createSelectMenu(): ActionRowBuilder<StringSelectMenuBuilder> {
  return new ActionRowBuilder<StringSelectMenuBuilder>().addComponents(
    new StringSelectMenuBuilder()
      .setCustomId('help_category_select')
      .setPlaceholder('Select a category to view commands...')
      .addOptions(
        {
          label: 'All Commands',
          description: 'View overview of all commands',
          value: 'all',
          emoji: '📚',
        },
        {
          label: 'DDoS Commands',
          description: 'Attack, methods, and stop commands',
          value: '🚀 DDoS',
          emoji: '🚀',
        },
        {
          label: 'Admin Commands',
          description: 'License management commands',
          value: '👑 Admin',
          emoji: '👑',
        },
        {
          label: 'Network Commands',
          description: 'Ping, traceroute, port scan, DNS',
          value: '🌐 Network',
          emoji: '🌐',
        },
        {
          label: 'System Commands',
          description: 'System statistics and monitoring',
          value: '💻 System',
          emoji: '💻',
        },
        {
          label: 'Utility Commands',
          description: 'Help and utility commands',
          value: '🛠️ Utility',
          emoji: '🛠️',
        }
      )
  );
}

export async function execute(interaction: ChatInputCommandInteraction): Promise<void> {
  const embed = createMainEmbed();
  const selectMenu = createSelectMenu();

  const response = await interaction.reply({
    embeds: [embed],
    components: [selectMenu],
    flags: MessageFlags.Ephemeral,
  });

  const collector = response.createMessageComponentCollector({
    componentType: ComponentType.StringSelect,
    time: 300000,
  });

  collector.on('collect', async (selectInteraction: StringSelectMenuInteraction) => {
    if (selectInteraction.user.id !== interaction.user.id) {
      await selectInteraction.reply({
        content: '❌ This menu is not for you!',
        flags: MessageFlags.Ephemeral,
      });
      return;
    }

    const selectedValue = selectInteraction.values[0];
    let newEmbed: EmbedBuilder;

    if (selectedValue === 'all') {
      newEmbed = createMainEmbed();
    } else {
      newEmbed = createCategoryEmbed(selectedValue);
    }

    await selectInteraction.update({
      embeds: [newEmbed],
      components: [selectMenu],
    });
  });

  collector.on('end', async () => {
    const expiredEmbed = new EmbedBuilder()
      .setTitle('⏱️ Help Menu Expired')
      .setColor(0xff0000)
      .setDescription('This help menu has expired. Use `/help` to open a new one.')
      .setTimestamp();

    try {
      await interaction.editReply({
        embeds: [expiredEmbed],
        components: [],
      });
    } catch {
    }
  });
}

