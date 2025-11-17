# 🔧 Solution Rapide PM2 - Si ecosystem.config.cjs n'existe pas

## Solution Immédiate sur le VPS

Si `ecosystem.config.cjs` n'existe pas, utilisez une de ces méthodes :

### Méthode 1 : Commande Directe (La Plus Simple) ⭐

```bash
cd /opt/discord.cool.bot

# Vérifier que start.js existe
ls -la start.js

# Démarrer directement
pm2 start start.js --name discord-bot

# Vérifier
pm2 status
pm2 logs discord-bot
```

### Méthode 2 : Avec tsx Directement

```bash
cd /opt/discord.cool.bot

# Vérifier que tsx existe
ls -la node_modules/.bin/tsx

# Démarrer
pm2 start node_modules/.bin/tsx --name discord-bot -- src/index.ts

# Vérifier
pm2 status
pm2 logs discord-bot
```

### Méthode 3 : Créer ecosystem.config.cjs Manuellement

```bash
cd /opt/discord.cool.bot

# Créer le fichier
cat > ecosystem.config.cjs << 'EOF'
const { resolve } = require('path');
const { existsSync } = require('fs');

const __dirname = process.cwd();
let scriptPath = resolve(__dirname, 'start.js');

if (!existsSync(scriptPath)) {
  scriptPath = resolve(__dirname, 'node_modules', '.bin', 'tsx');
}

module.exports = {
  apps: [{
    name: 'discord-bot',
    script: scriptPath,
    args: scriptPath.includes('tsx') ? [resolve(__dirname, 'src', 'index.ts')] : undefined,
    interpreter: scriptPath.endsWith('.js') ? 'node' : undefined,
    cwd: __dirname,
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '500M',
    env: { NODE_ENV: 'production' },
    error_file: resolve(__dirname, 'logs', 'pm2-error.log'),
    out_file: resolve(__dirname, 'logs', 'pm2-out.log'),
    log_file: resolve(__dirname, 'logs', 'pm2-combined.log'),
    time: true,
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    min_uptime: '10s',
    max_restarts: 10,
    restart_delay: 4000,
  }],
};
EOF

# Puis démarrer
pm2 start ecosystem.config.cjs
```

### Méthode 4 : Pull et Utiliser

```bash
cd /opt/discord.cool.bot

# Pull les dernières modifications
git pull origin main

# Vérifier que le fichier existe maintenant
ls -la ecosystem.config.cjs

# Si oui, démarrer
pm2 start ecosystem.config.cjs
```

## Vérification

Après avoir démarré, vérifiez :

```bash
# Statut
pm2 status

# Logs
pm2 logs discord-bot

# Vous devriez voir :
# [INFO] Bot logged in as YourBot#1234
# [INFO] Registered X slash commands
```

## Si Rien Ne Fonctionne

```bash
# Tester manuellement d'abord
cd /opt/discord.cool.bot
node start.js

# Si ça fonctionne, alors PM2 devrait aussi fonctionner avec :
pm2 start start.js --name discord-bot
```

