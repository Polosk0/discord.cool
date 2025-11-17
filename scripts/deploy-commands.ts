import { REST, Routes } from 'discord.js';
import { config } from 'dotenv';
import { readdirSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

config();

const token = process.env.DISCORD_TOKEN;
const clientId = process.env.CLIENT_ID;
const guildId = process.env.GUILD_ID;

if (!token) {
  console.error('❌ DISCORD_TOKEN is not set in .env file');
  process.exit(1);
}

if (!clientId) {
  console.error('❌ CLIENT_ID is not set in .env file');
  process.exit(1);
}

async function loadCommands(): Promise<any[]> {
  const commands: any[] = [];
  const commandsPath = join(__dirname, '..', 'src', 'commands');

  const commandCategories = readdirSync(commandsPath, { withFileTypes: true })
    .filter((dirent) => dirent.isDirectory())
    .map((dirent) => dirent.name);

  for (const category of commandCategories) {
    const categoryPath = join(commandsPath, category);
    const commandFiles = readdirSync(categoryPath).filter((file) => file.endsWith('.ts'));

    for (const file of commandFiles) {
      const filePath = join(categoryPath, file);
      const fileUrl = `file://${filePath.replace(/\\/g, '/')}`;
      
      try {
        const command = await import(fileUrl);
        if ('data' in command && 'execute' in command) {
          const commandName = command.data.name;
          // Check for duplicates
          if (commands.some((cmd) => cmd.name === commandName)) {
            console.warn(`⚠️  Duplicate command skipped: ${commandName}`);
            continue;
          }
          commands.push(command.data.toJSON());
          console.log(`✅ Loaded command: ${commandName}`);
        }
      } catch (error) {
        console.error(`❌ Failed to load command from ${file}:`, error);
      }
    }
  }

  return commands;
}

async function deployCommands(): Promise<void> {
  try {
    console.log('📦 Loading commands...');
    const commands = await loadCommands();

    console.log(`✅ Loaded ${commands.length} command(s)`);

    const rest = new REST({ version: '10' }).setToken(token!);

    console.log('🚀 Deploying commands to Discord...');

    if (guildId) {
      console.log(`📡 Deploying to guild: ${guildId}`);
      await rest.put(Routes.applicationGuildCommands(clientId!, guildId), {
        body: commands,
      });
      console.log(`✅ Successfully deployed ${commands.length} guild command(s)`);
    } else {
      console.log('🌍 Deploying globally (this may take up to 1 hour to propagate)');
      await rest.put(Routes.applicationCommands(clientId!), {
        body: commands,
      });
      console.log(`✅ Successfully deployed ${commands.length} global command(s)`);
    }

    console.log('🎉 Commands deployed successfully!');
  } catch (error) {
    console.error('❌ Failed to deploy commands:', error);
    process.exit(1);
  }
}

deployCommands();

