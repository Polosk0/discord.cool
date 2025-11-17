import { Client } from 'discord.js';
import { readdirSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath, pathToFileURL } from 'url';
import { logger } from '../utils/logger';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

export async function loadEvents(client: Client): Promise<void> {
  const eventsPath = join(__dirname, '.');
  const eventFiles = readdirSync(eventsPath).filter((file) => file.endsWith('.ts') && file !== 'index.ts');

  for (const file of eventFiles) {
    const filePath = join(eventsPath, file);
    const fileUrl = pathToFileURL(filePath).href;
    const event = await import(fileUrl);

    if ('name' in event && 'execute' in event) {
      if (event.once) {
        client.once(event.name, (...args) => event.execute(...args));
      } else {
        client.on(event.name, (...args) => event.execute(...args));
      }

      logger.info(`Loaded event: ${event.name}`);
    }
  }
}

