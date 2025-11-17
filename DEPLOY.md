# Guide de Déploiement - Discord Bot

Guide complet pour déployer le bot Discord sur un VPS.

## 📋 Prérequis

- VPS Linux (Ubuntu/Debian recommandé)
- Node.js 18+ installé
- Git installé
- Accès SSH au VPS

## 🚀 Installation Initiale

### 1. Se connecter au VPS

```bash
ssh user@your-vps-ip
```

### 2. Cloner le repository

```bash
# Créer un répertoire pour le bot
mkdir -p ~/discord-bot
cd ~/discord-bot

# Cloner votre repository
git clone https://github.com/Polosk0/discord.cool.bot.git .
# OU si vous avez déjà le repo localement, utilisez scp pour transférer
```

### 3. Exécuter le script de setup

```bash
chmod +x scripts/*.sh
./scripts/setup.sh
```

Le script va :
- ✅ Vérifier Node.js et PNPM
- ✅ Installer les dépendances
- ✅ Créer le fichier .env depuis .env.example
- ✅ Créer le dossier logs

### 4. Configurer le fichier .env

```bash
nano .env
```

Remplir avec vos informations :
```env
DISCORD_TOKEN=votre_token_discord
CLIENT_ID=votre_client_id
PREFIX=!
ADMIN_IDS=votre_user_id_1,votre_user_id_2
MAX_ATTACK_DURATION=300
MAX_THREADS=100
RATE_LIMIT_DELAY=1000
NODE_ENV=production
```

Sauvegarder avec `Ctrl+X`, puis `Y`, puis `Enter`.

## 🎮 Utilisation des Scripts

### Démarrer le bot

```bash
./scripts/start.sh
```

Le bot démarre en arrière-plan avec :
- ✅ Logs colorés dans la console
- ✅ Logs sauvegardés dans `logs/bot.log`
- ✅ PID sauvegardé dans `bot.pid`

### Arrêter le bot

```bash
./scripts/stop.sh
```

### Voir les logs en temps réel

```bash
./scripts/watch-logs.sh
```

Ou directement :
```bash
tail -f logs/bot.log
```

### Déployer les mises à jour depuis Git

```bash
./scripts/deploy.sh
```

Ce script va :
- ✅ Sauvegarder le .env actuel
- ✅ Arrêter le bot si en cours d'exécution
- ✅ Pull les dernières modifications
- ✅ Restaurer le .env sauvegardé
- ✅ Installer les nouvelles dépendances
- ✅ Rebuild le projet si nécessaire

## 🔄 Workflow de Déploiement

### Sur votre machine locale

1. **Faire vos modifications**
2. **Commit et push vers Git** :
```bash
git add .
git commit -m "Description des modifications"
git push origin main
```

### Sur le VPS

1. **Déployer les mises à jour** :
```bash
cd ~/discord-bot
./scripts/deploy.sh
```

2. **Redémarrer le bot** (si nécessaire) :
```bash
./scripts/stop.sh
./scripts/start.sh
```

## 📝 Commandes Git Utiles

### Pull les dernières modifications

```bash
git pull origin main
```

### Voir l'état du repository

```bash
git status
```

### Voir les logs Git

```bash
git log --oneline -10
```

### Changer de branche

```bash
git checkout nom-de-la-branche
```

### Forcer le pull (si conflits)

```bash
git fetch origin
git reset --hard origin/main
```

⚠️ **Attention** : Cette commande écrase les modifications locales !

## 🔧 Configuration Avancée

### Utiliser systemd pour auto-démarrage

Créer un service systemd :

```bash
sudo nano /etc/systemd/system/discord-bot.service
```

Contenu :
```ini
[Unit]
Description=Discord Bot
After=network.target

[Service]
Type=simple
User=votre-utilisateur
WorkingDirectory=/home/votre-utilisateur/discord-bot
ExecStart=/usr/bin/pnpm dev
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Activer le service :
```bash
sudo systemctl daemon-reload
sudo systemctl enable discord-bot
sudo systemctl start discord-bot
```

Vérifier le statut :
```bash
sudo systemctl status discord-bot
```

### Utiliser PM2 (Alternative)

```bash
# Installer PM2
npm install -g pm2

# Démarrer avec PM2
pm2 start pnpm --name "discord-bot" -- dev

# Sauvegarder la configuration
pm2 save

# Configurer le démarrage automatique
pm2 startup
```

## 📊 Monitoring

### Vérifier que le bot tourne

```bash
# Avec le script
cat bot.pid
ps -p $(cat bot.pid)

# Ou directement
ps aux | grep "pnpm dev"
```

### Voir l'utilisation des ressources

```bash
top -p $(cat bot.pid)
# ou
htop
```

## 🐛 Dépannage

### Le bot ne démarre pas

1. Vérifier les logs :
```bash
tail -n 50 logs/bot.log
```

2. Vérifier le .env :
```bash
cat .env
```

3. Vérifier les dépendances :
```bash
pnpm install
```

### Le bot crash en boucle

1. Vérifier les logs d'erreur
2. Vérifier que le token Discord est valide
3. Vérifier les permissions du bot sur Discord

### Problèmes de permissions

```bash
# Rendre les scripts exécutables
chmod +x scripts/*.sh

# Vérifier les permissions du .env
chmod 600 .env
```

## 📁 Structure des Fichiers

```
discord-bot/
├── scripts/
│   ├── start.sh          # Démarrer le bot
│   ├── stop.sh           # Arrêter le bot
│   ├── deploy.sh         # Déployer depuis Git
│   ├── setup.sh          # Installation initiale
│   └── watch-logs.sh     # Voir les logs en temps réel
├── logs/
│   └── bot.log           # Fichier de logs
├── .env                  # Configuration (non versionné)
├── bot.pid               # PID du processus
└── ...
```

## 🔐 Sécurité

- ✅ Ne jamais commiter le fichier `.env`
- ✅ Utiliser des permissions restrictives sur `.env` (chmod 600)
- ✅ Garder le token Discord secret
- ✅ Utiliser un utilisateur non-root pour exécuter le bot

## 📞 Support

En cas de problème :
1. Vérifier les logs : `./scripts/watch-logs.sh`
2. Vérifier la configuration : `cat .env`
3. Vérifier les dépendances : `pnpm install`

