# 🚀 Guide de Démarrage Rapide

## 📋 Commandes pour VPS

### 1. Se connecter au VPS et aller dans le dossier du bot

```bash
cd /opt/discord.cool.bot
# ou selon votre chemin d'installation
```

### 2. Récupérer les dernières modifications

```bash
git pull origin main
```

### 3. Installer les nouvelles dépendances (si nécessaire)

```bash
pnpm install
```

### 4. Déployer les commandes Discord

```bash
pnpm run deploy:commands
```

**Note :** Assurez-vous que votre fichier `.env` contient :
- `DISCORD_TOKEN` : Token de votre bot
- `CLIENT_ID` : ID de votre application Discord
- `GUILD_ID` : (Optionnel) ID de votre serveur Discord pour déploiement instantané

### 5. Redémarrer le bot avec PM2

```bash
# Si le bot tourne déjà
pm2 restart discord-bot

# Si le bot n'est pas démarré
pm2 start ecosystem.config.cjs
# ou
pm2 start start.js --name discord-bot
```

### 6. Vérifier les logs

```bash
# Voir les logs en temps réel
pm2 logs discord-bot

# Voir le statut
pm2 status

# Voir les logs des 50 dernières lignes
pm2 logs discord-bot --lines 50
```

## 🔄 Script de Déploiement Complet (Tout-en-un)

Si vous avez le script `deploy.sh` :

```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

Ce script fait automatiquement :
- Backup du `.env`
- Pull des dernières modifications
- Installation des dépendances
- Build du projet
- Redémarrage avec PM2

## 📝 Commandes Individuelles

### Déployer uniquement les commandes Discord

```bash
pnpm run deploy:commands
```

### Redémarrer le bot

```bash
pm2 restart discord-bot
```

### Arrêter le bot

```bash
pm2 stop discord-bot
```

### Démarrer le bot

```bash
pm2 start ecosystem.config.cjs
```

### Voir les logs en temps réel

```bash
pm2 logs discord-bot --lines 100
```

### Voir le statut du bot

```bash
pm2 status
pm2 info discord-bot
```

## 🆕 Nouvelles Fonctionnalités Déployées

1. **Système de License** : `/license-create`, `/license-revoke`, `/license-activate`
2. **Ping Amélioré** : `/ping` avec API check-host.net et mises à jour en temps réel
3. **Dstat Live** : `/dstat` avec mises à jour chaque seconde
4. **Attack Modal** : `/attack` avec menu interactif pour choisir les méthodes
5. **Methods** : `/methods` pour voir les explications des méthodes d'attaque

## ⚠️ Important

- Les commandes nécessitent une license (sauf `/help` et `/license-activate`)
- Utilisez `/license-create` pour créer des licenses pour les utilisateurs
- Les utilisateurs doivent activer leur license avec `/license-activate`

## 🔧 Dépannage

### Si le bot ne démarre pas :

```bash
# Vérifier les erreurs
pm2 logs discord-bot --err

# Redémarrer proprement
pm2 delete discord-bot
pm2 start ecosystem.config.cjs
```

### Si les commandes ne s'affichent pas :

```bash
# Redéployer les commandes
pnpm run deploy:commands

# Attendre quelques minutes si déploiement global
# (peut prendre jusqu'à 1h pour se propager)
```

### Si erreur de dépendances :

```bash
# Réinstaller les dépendances
rm -rf node_modules
pnpm install
```

