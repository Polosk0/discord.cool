# 📋 Commandes Rapides - Discord Bot

Guide rapide des commandes pour gérer votre bot Discord.

## 🚀 Commandes de Base

### Installation Initiale

```bash
# Rendre les scripts exécutables
chmod +x scripts/*.sh

# Installation complète
./scripts/setup.sh
```

### Démarrer le Bot

```bash
./scripts/start.sh
```

### Arrêter le Bot

```bash
./scripts/stop.sh
```

### Voir les Logs

```bash
# Logs en temps réel avec couleurs
./scripts/watch-logs.sh

# Ou directement
tail -f logs/bot.log
```

## 🔄 Déploiement Git

### Déploiement Complet

```bash
./scripts/deploy.sh
```

Ce script fait :
- ✅ Backup du .env
- ✅ Arrêt du bot
- ✅ Pull des modifications
- ✅ Restauration du .env
- ✅ Installation des dépendances
- ✅ Build du projet

### Déploiement Rapide

```bash
./scripts/quick-deploy.sh
```

Version simplifiée : pull → install → restart

### Commandes Git Manuelles

```bash
# Pull les dernières modifications
git pull origin main

# Voir le repository distant
git remote -v
# Devrait afficher: https://github.com/Polosk0/discord.cool.bot.git

# Voir l'état
git status

# Voir les commits récents
git log --oneline -10

# Changer de branche
git checkout nom-branche

# Forcer le pull (écrase les modifications locales)
git fetch origin
git reset --hard origin/main
```

## 📊 Monitoring

### Vérifier le Statut

```bash
# Vérifier si le bot tourne
ps -p $(cat bot.pid)

# Voir tous les processus Node
ps aux | grep node

# Voir l'utilisation des ressources
top -p $(cat bot.pid)
```

### Logs

```bash
# Dernières 50 lignes
tail -n 50 logs/bot.log

# Logs en temps réel
tail -f logs/bot.log

# Chercher des erreurs
grep ERROR logs/bot.log

# Chercher des warnings
grep WARN logs/bot.log
```

## 🔧 Maintenance

### Réinstaller les Dépendances

```bash
rm -rf node_modules
pnpm install
```

### Nettoyer les Logs

```bash
# Vider les logs
> logs/bot.log

# Ou supprimer les anciens logs
rm logs/*.log
```

### Vérifier la Configuration

```bash
# Voir le .env (sans afficher le token)
cat .env | grep -v TOKEN

# Vérifier les variables d'environnement
env | grep DISCORD
```

## 🐛 Dépannage

### Le Bot Ne Démarre Pas

```bash
# 1. Vérifier les logs
tail -n 100 logs/bot.log

# 2. Vérifier le .env
cat .env

# 3. Réinstaller les dépendances
pnpm install

# 4. Vérifier Node.js
node --version
pnpm --version
```

### Le Bot Crash

```bash
# Voir les dernières erreurs
tail -n 100 logs/bot.log | grep ERROR

# Vérifier les permissions
ls -la .env
chmod 600 .env
```

### Problèmes Git

```bash
# Résoudre les conflits
git stash
git pull origin main
git stash pop

# Reset complet (ATTENTION: perte des modifications locales)
git fetch origin
git reset --hard origin/main
```

## 📁 Fichiers Importants

| Fichier | Description |
|---------|-------------|
| `.env` | Configuration du bot (TOKEN, etc.) |
| `logs/bot.log` | Fichier de logs |
| `bot.pid` | PID du processus en cours |
| `scripts/` | Tous les scripts de gestion |

## 🔐 Sécurité

```bash
# Protéger le .env
chmod 600 .env

# Vérifier les permissions
ls -la .env
```

## 📝 Workflow Recommandé

### Sur votre Machine Locale

1. **Modifier le code**
2. **Tester localement**
   ```bash
   pnpm dev
   ```
3. **Commit et Push**
   ```bash
   git add .
   git commit -m "Description"
   git push origin main
   ```

### Sur le VPS

1. **Déployer**
   ```bash
   ./scripts/deploy.sh
   ```
2. **Vérifier les logs**
   ```bash
   ./scripts/watch-logs.sh
   ```

## 🎯 Commandes les Plus Utilisées

```bash
# Démarrage
./scripts/start.sh

# Arrêt
./scripts/stop.sh

# Déploiement
./scripts/deploy.sh

# Logs
./scripts/watch-logs.sh
```

## 💡 Astuces

- Utilisez `screen` ou `tmux` pour garder le bot actif après déconnexion SSH
- Configurez un cron job pour redémarrer automatiquement en cas de crash
- Utilisez PM2 ou systemd pour la gestion automatique

