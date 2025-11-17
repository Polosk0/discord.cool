# 🚀 Guide Rapide VPS - Déploiement

Guide ultra-rapide pour déployer le bot sur votre VPS.

## 📋 Sur le VPS - Première Installation

```bash
# 1. Se connecter au VPS
ssh user@votre-vps-ip

# 2. Cloner le repository
git clone https://github.com/Polosk0/discord.cool.bot.git
cd discord.cool.bot

# 3. Rendre les scripts exécutables
chmod +x scripts/*.sh

# 4. Installation automatique
./scripts/setup.sh

# 5. Configurer le .env
nano .env
# Remplir avec votre DISCORD_TOKEN, CLIENT_ID, ADMIN_IDS, etc.

# 6. Démarrer le bot
./scripts/start.sh
```

## 🔄 Mises à Jour (Pull depuis GitHub)

### Option 1 : Script Automatique (Recommandé)

```bash
cd ~/discord.cool.bot
./scripts/deploy.sh
```

Ce script fait tout automatiquement :
- ✅ Backup du .env
- ✅ Arrêt du bot
- ✅ Pull des modifications
- ✅ Restauration du .env
- ✅ Installation des dépendances
- ✅ Build du projet

### Option 2 : Déploiement Rapide

```bash
cd ~/discord.cool.bot
./scripts/quick-deploy.sh
```

### Option 3 : Manuel

```bash
cd ~/discord.cool.bot

# Arrêter le bot
./scripts/stop.sh

# Pull les modifications
git pull origin main

# Installer les dépendances
pnpm install

# Redémarrer
./scripts/start.sh
```

## 📊 Commandes Utiles sur le VPS

```bash
# Voir les logs en temps réel
./scripts/watch-logs.sh

# Arrêter le bot
./scripts/stop.sh

# Démarrer le bot
./scripts/start.sh

# Vérifier si le bot tourne
ps -p $(cat bot.pid)
```

## 🔐 Vérifications Importantes

### Vérifier que le .env est bien configuré

```bash
# Voir le .env (sans afficher le token)
cat .env | grep -v TOKEN
```

### Vérifier les logs

```bash
# Dernières erreurs
tail -n 50 logs/bot.log | grep ERROR

# Tous les logs
tail -f logs/bot.log
```

## 🐛 Dépannage Rapide

### Le bot ne démarre pas

```bash
# Vérifier les logs
tail -n 100 logs/bot.log

# Vérifier le .env
cat .env

# Réinstaller les dépendances
rm -rf node_modules
pnpm install
```

### Le pull échoue

```bash
# Forcer le pull (ATTENTION: écrase les modifications locales)
git fetch origin
git reset --hard origin/main
./scripts/deploy.sh
```

## 📝 Workflow Complet

### Sur votre Machine Locale

```bash
# 1. Faire vos modifications
# ... éditer les fichiers ...

# 2. Commit et push
git add .
git commit -m "Description des modifications"
git push origin main
```

### Sur le VPS

```bash
# 1. Déployer automatiquement
cd ~/discord.cool.bot
./scripts/deploy.sh

# 2. Vérifier que tout fonctionne
./scripts/watch-logs.sh
```

## ✅ Checklist VPS

- [ ] Node.js 18+ installé
- [ ] PNPM installé
- [ ] Repository cloné
- [ ] Scripts exécutables (`chmod +x scripts/*.sh`)
- [ ] `.env` configuré avec votre token Discord
- [ ] Bot démarré et fonctionnel
- [ ] Logs accessibles

## 🔗 Liens Utiles

- **Repository GitHub**: https://github.com/Polosk0/discord.cool.bot
- **Documentation complète**: Voir `DEPLOY.md`
- **Commandes détaillées**: Voir `COMMANDS.md`

