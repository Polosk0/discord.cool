import {
  SlashCommandBuilder,
  ChatInputCommandInteraction,
  EmbedBuilder,
  StringSelectMenuBuilder,
  ActionRowBuilder,
  MessageFlags,
} from 'discord.js';
import { rateLimiter } from '../../utils/rate-limiter';
import { licenseService } from '../../services/license';

export const data = new SlashCommandBuilder()
  .setName('attack')
  .setDescription('Launch a DDoS attack');

const attackMethods = [
  { value: 'http-flood', label: 'HTTP Flood', description: 'Flood HTTP requests to target', emoji: '🌊' },
  { value: 'tcp-flood', label: 'TCP Flood', description: 'Flood TCP connections', emoji: '⚡' },
  { value: 'udp-flood', label: 'UDP Flood', description: 'Flood UDP packets', emoji: '💥' },
  { value: 'slowloris', label: 'Slowloris', description: 'Slow HTTP attack', emoji: '🐌' },
  { value: 'syn-flood', label: 'SYN Flood', description: 'Flood SYN packets', emoji: '🔥' },
];

function createMethodSelectMenu(): ActionRowBuilder<StringSelectMenuBuilder> {
  return new ActionRowBuilder<StringSelectMenuBuilder>().addComponents(
    new StringSelectMenuBuilder()
      .setCustomId('attack_method_select')
      .setPlaceholder('Select an attack method...')
      .addOptions(
        attackMethods.map((method) => ({
          label: method.label,
          description: method.description,
          value: method.value,
          emoji: method.emoji,
        }))
      )
  );
}

export async function execute(interaction: ChatInputCommandInteraction): Promise<void> {
  if (!licenseService.hasPermission(interaction.user.id, 'attack')) {
    await interaction.reply({
      content: '❌ You need a valid license with attack permission to use this command. Use `/license-activate` to activate your license.',
      flags: MessageFlags.Ephemeral,
    });
    return;
  }

  if (!rateLimiter.isAllowed(interaction.user.id, 'attack', 5, 60000)) {
    await interaction.reply({
      content: '❌ Rate limit exceeded. Please wait before launching another attack.',
      flags: MessageFlags.Ephemeral,
    });
    return;
  }

  const embed = new EmbedBuilder()
    .setTitle('🚀 Launch DDoS Attack')
    .setColor(0xff0000)
    .setDescription('Select an attack method from the menu below to configure your attack.')
    .addFields(
      {
        name: '📋 Available Methods',
        value: attackMethods.map((m) => `${m.emoji} **${m.label}** - ${m.description}`).join('\n'),
        inline: false,
      }
    )
    .setFooter({ text: 'Select a method to continue' })
    .setTimestamp();

  const selectMenu = createMethodSelectMenu();

  await interaction.reply({
    embeds: [embed],
    components: [selectMenu],
    flags: MessageFlags.Ephemeral,
  });
}

