import { Events, Client } from 'discord.js';
import { logger } from '../utils/logger';
import { commands } from '../commands';

export const name = Events.ClientReady;
export const once = true;

export async function execute(client: Client): Promise<void> {
  logger.info(`Bot logged in as ${client.user?.tag}`);

  try {
    const commandData = commands.map((cmd) => cmd.data.toJSON());
    await client.application?.commands.set(commandData);
    logger.info(`Registered ${commands.size} slash commands`);
  } catch (error) {
    logger.error('Failed to register commands', error as Error);
  }
}

