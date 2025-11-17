#!/usr/bin/env node

import { spawn } from 'child_process';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { existsSync } from 'fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const tsxPath = join(__dirname, 'node_modules', '.bin', 'tsx');
const scriptPath = join(__dirname, 'src', 'index.ts');

if (!existsSync(tsxPath)) {
  console.error('Error: tsx not found. Please run: pnpm install');
  process.exit(1);
}

if (!existsSync(scriptPath)) {
  console.error('Error: src/index.ts not found');
  process.exit(1);
}

const child = spawn(tsxPath, [scriptPath], {
  stdio: 'inherit',
  cwd: __dirname,
  env: process.env,
});

child.on('error', (error) => {
  console.error('Failed to start bot:', error);
  process.exit(1);
});

child.on('exit', (code) => {
  process.exit(code || 0);
});

