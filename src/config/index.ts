import { config } from 'dotenv';

config();

export const botConfig = {
  token: process.env.DISCORD_TOKEN || '',
  clientId: process.env.CLIENT_ID || '',
  prefix: process.env.PREFIX || '!',
  adminIds: (process.env.ADMIN_IDS || '').split(',').filter(Boolean),
  maxAttackDuration: parseInt(process.env.MAX_ATTACK_DURATION || '300', 10),
  maxThreads: parseInt(process.env.MAX_THREADS || '100', 10),
  rateLimitDelay: parseInt(process.env.RATE_LIMIT_DELAY || '1000', 10),
};

export const networkConfig = {
  defaultTimeout: 5000,
  maxConcurrentScans: 10,
  defaultPortRange: '1-1000',
};

export const systemConfig = {
  statsUpdateInterval: 5000,
  maxHistorySize: 100,
};

