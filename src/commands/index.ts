import { Collection } from 'discord.js';
import type { SlashCommandBuilder, ChatInputCommandInteraction } from 'discord.js';
import { logger } from '../utils/logger';

export interface Command {
  data: SlashCommandBuilder;
  execute: (interaction: ChatInputCommandInteraction) => Promise<void>;
}

export const commands = new Collection<string, Command>();

async function loadCommands(): Promise<void> {
  const commandModules = [
    await import('./ddos/attack'),
    await import('./ddos/stop'),
    await import('./ddos/methods'),
    await import('./network/ping'),
    await import('./network/traceroute'),
    await import('./network/port-scan'),
    await import('./network/dns-lookup'),
    await import('./system/dstat'),
    await import('./utility/help'),
    await import('./admin/license-create'),
    await import('./admin/license-revoke'),
    await import('./admin/license-activate'),
  ];

  let loadedCount = 0;

  for (const module of commandModules) {
    if ('data' in module && 'execute' in module) {
      commands.set(module.data.name, module as Command);
      loadedCount++;
      logger.debug(`Loaded command: ${module.data.name}`);
    } else {
      logger.warn(`Failed to load command module: missing data or execute`);
    }
  }

  logger.info(`Loaded ${loadedCount} commands`);
}

loadCommands().catch((error) => {
  logger.error('Failed to load commands', error);
});

