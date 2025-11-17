const { resolve, join } = require('path');
const { existsSync } = require('fs');

const __dirname = __dirname || process.cwd();

// Try multiple possible script paths
let scriptPath = null;
let scriptArgs = [];

// Check for start.js first
const startJsPath = resolve(__dirname, 'start.js');
if (existsSync(startJsPath)) {
  scriptPath = startJsPath;
} else {
  // Fallback to tsx directly
  const tsxPath = resolve(__dirname, 'node_modules', '.bin', 'tsx');
  if (existsSync(tsxPath)) {
    scriptPath = tsxPath;
    scriptArgs = [resolve(__dirname, 'src', 'index.ts')];
  } else {
    // Last resort: use pnpm
    scriptPath = 'pnpm';
    scriptArgs = ['start'];
  }
}

module.exports = {
  apps: [
    {
      name: 'discord-bot',
      script: scriptPath,
      args: scriptArgs.length > 0 ? scriptArgs.join(' ') : undefined,
      interpreter: scriptPath.endsWith('.js') ? 'node' : undefined,
      cwd: __dirname,
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '500M',
      env: {
        NODE_ENV: 'production',
      },
      error_file: resolve(__dirname, 'logs', 'pm2-error.log'),
      out_file: resolve(__dirname, 'logs', 'pm2-out.log'),
      log_file: resolve(__dirname, 'logs', 'pm2-combined.log'),
      time: true,
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true,
      min_uptime: '10s',
      max_restarts: 10,
      restart_delay: 4000,
    },
  ],
};

