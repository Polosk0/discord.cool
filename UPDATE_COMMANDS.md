# 🔄 Commandes de Mise à Jour - Guide Complet

Guide rapide pour mettre à jour votre bot sur le VPS.

## 📤 Sur votre Machine Locale (Windows)

### 1. Faire vos modifications
Éditez les fichiers que vous voulez modifier.

### 2. Commit et Push vers GitHub

```bash
# Aller dans le dossier du projet
cd C:\Users\Polosko\Desktop\bot-script-discordtool

# Voir les changements
git status

# Ajouter tous les fichiers modifiés
git add .

# Commit avec message descriptif
git commit -m "Description de vos modifications"

# Push vers GitHub
git push origin main
```

### Exemples de messages de commit

```bash
git commit -m "feat: Add new network command"
git commit -m "fix: Fix logger issue"
git commit -m "docs: Update documentation"
git commit -m "refactor: Improve code structure"
```

## 📥 Sur le VPS - Mise à Jour

### Option 1 : Script Automatique (Recommandé) ⭐

```bash
# Se connecter au VPS
ssh user@votre-vps-ip

# Aller dans le dossier du bot
cd ~/discord.cool.bot

# Déployer automatiquement (pull + install + restart)
./scripts/deploy.sh
```

Ce script fait automatiquement :
- ✅ Backup du .env
- ✅ Arrêt du bot (PM2 ou PID)
- ✅ Pull des modifications depuis GitHub
- ✅ Restauration du .env
- ✅ Installation des dépendances
- ✅ Build du projet
- ✅ Redémarrage avec PM2

### Option 2 : Déploiement Rapide

```bash
cd ~/discord.cool.bot
./scripts/quick-deploy.sh
```

### Option 3 : Commandes Manuelles

```bash
# 1. Aller dans le dossier
cd ~/discord.cool.bot

# 2. Arrêter le bot (si PM2)
pm2 stop discord-bot

# 3. Pull les modifications
git pull origin main

# 4. Installer les dépendances
pnpm install

# 5. Redémarrer le bot
pm2 restart discord-bot

# 6. Voir les logs
pm2 logs discord-bot
```

## 🔍 Vérifier les Mises à Jour

### Voir les derniers commits

```bash
# Sur votre machine locale
git log --oneline -5

# Sur le VPS
cd ~/discord.cool.bot
git log --oneline -5
```

### Voir les différences

```bash
# Sur le VPS, avant de pull
cd ~/discord.cool.bot
git fetch origin
git diff HEAD origin/main
```

## 🚀 Workflow Complet

### Scénario 1 : Modification Simple

**Local :**
```bash
cd C:\Users\Polosko\Desktop\bot-script-discordtool
# Modifier les fichiers
git add .
git commit -m "fix: Correction bug"
git push origin main
```

**VPS :**
```bash
cd ~/discord.cool.bot
./scripts/deploy.sh
```

### Scénario 2 : Nouvelle Fonctionnalité

**Local :**
```bash
cd C:\Users\Polosko\Desktop\bot-script-discordtool
# Ajouter nouvelle commande/fonctionnalité
git add .
git commit -m "feat: Add new command /example"
git push origin main
```

**VPS :**
```bash
cd ~/discord.cool.bot
./scripts/deploy.sh
pm2 logs discord-bot
```

## 📋 Checklist de Mise à Jour

### Avant de Push (Local)

- [ ] Code testé localement
- [ ] `.env` n'est pas dans les fichiers ajoutés
- [ ] Message de commit descriptif
- [ ] Pas de fichiers sensibles (tokens, etc.)

### Après Pull (VPS)

- [ ] `.env` toujours présent et correct
- [ ] Dépendances installées (`pnpm install`)
- [ ] Bot redémarré avec PM2
- [ ] Logs vérifiés (`pm2 logs discord-bot`)
- [ ] Bot fonctionne correctement

## 🐛 Dépannage

### Le pull échoue (conflits)

```bash
# Sur le VPS
cd ~/discord.cool.bot

# Sauvegarder les modifications locales
git stash

# Pull les modifications
git pull origin main

# Appliquer les modifications locales (si nécessaire)
git stash pop
```

### Forcer le pull (écrase les modifications locales)

```bash
# ATTENTION : Perd les modifications locales non commitées
cd ~/discord.cool.bot
git fetch origin
git reset --hard origin/main
./scripts/deploy.sh
```

### Le bot ne démarre pas après mise à jour

```bash
# Voir les logs d'erreur
pm2 logs discord-bot --err --lines 50

# Vérifier les dépendances
cd ~/discord.cool.bot
pnpm install

# Redémarrer
pm2 restart discord-bot
```

## 🔄 Commandes Rapides

### Local → GitHub → VPS

```bash
# 1. LOCAL : Commit et push
git add . && git commit -m "Update" && git push origin main

# 2. VPS : Déployer
ssh user@vps "cd ~/discord.cool.bot && ./scripts/deploy.sh"
```

### Voir l'état actuel

```bash
# Local
git status
git log --oneline -3

# VPS
cd ~/discord.cool.bot
git status
pm2 status
```

## 📝 Exemples Concrets

### Ajouter une nouvelle commande

**Local :**
```bash
# 1. Créer le fichier de commande
# src/commands/example/command.ts

# 2. Commit
git add .
git commit -m "feat: Add /example command"
git push origin main
```

**VPS :**
```bash
./scripts/deploy.sh
pm2 logs discord-bot
```

### Corriger un bug

**Local :**
```bash
# 1. Corriger le bug
# ...

# 2. Commit
git add .
git commit -m "fix: Fix error in logger"
git push origin main
```

**VPS :**
```bash
./scripts/deploy.sh
```

### Mettre à jour la documentation

**Local :**
```bash
# 1. Modifier README.md ou autres docs
# ...

# 2. Commit
git add .
git commit -m "docs: Update README with new features"
git push origin main
```

**VPS :**
```bash
./scripts/deploy.sh
```

## 🎯 Commandes les Plus Utilisées

```bash
# LOCAL
git add .
git commit -m "Description"
git push origin main

# VPS
cd ~/discord.cool.bot
./scripts/deploy.sh
pm2 logs discord-bot
```

## 💡 Astuces

1. **Toujours vérifier les logs après déploiement** : `pm2 logs discord-bot`
2. **Utiliser des messages de commit clairs** : `feat:`, `fix:`, `docs:`
3. **Tester localement avant de push**
4. **Sauvegarder le .env** avant chaque déploiement (fait automatiquement par deploy.sh)
5. **Utiliser `git status`** pour voir ce qui va être commité

## 🔗 Liens Utiles

- **Repository GitHub**: https://github.com/Polosk0/discord.cool.bot
- **Guide PM2**: Voir `PM2_GUIDE.md`
- **Guide Déploiement**: Voir `DEPLOY.md`

