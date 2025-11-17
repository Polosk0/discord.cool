import { Client, GatewayIntentBits } from 'discord.js';
import { config } from 'dotenv';
import { botConfig } from './config';
import { logger } from './utils/logger';
import { loadEvents } from './events';

config();

const client = new Client({
  intents: [
    GatewayIntentBits.Guilds,
    GatewayIntentBits.GuildMessages,
    GatewayIntentBits.MessageContent,
  ],
});

loadEvents(client)
  .then(() => {
    client.login(botConfig.token);
  })
  .catch((error) => {
    logger.error('Failed to load events', error);
    process.exit(1);
  });

client.on('error', (error) => {
  logger.error('Discord client error', error);
});

process.on('unhandledRejection', (error) => {
  logger.error('Unhandled promise rejection', error as Error);
});

process.on('SIGINT', () => {
  logger.info('Received SIGINT, shutting down gracefully...');
  client.destroy();
  process.exit(0);
});

process.on('SIGTERM', () => {
  logger.info('Received SIGTERM, shutting down gracefully...');
  client.destroy();
  process.exit(0);
});
