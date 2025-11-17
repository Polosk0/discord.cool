# 🚀 Configuration Git - Premier Push

Guide pour initialiser Git et pousser votre code sur GitHub.

## 📋 Prérequis

- Git installé sur votre machine
- Compte GitHub
- Repository créé sur GitHub : https://github.com/Polosk0/discord.cool.bot

## 🔧 Configuration Initiale

### 1. Initialiser Git (si pas déjà fait)

```bash
cd C:\Users\Polosko\Desktop\bot-script-discordtool
git init
```

### 2. Ajouter le Remote

```bash
git remote add origin https://github.com/Polosk0/discord.cool.bot.git
```

### 3. Vérifier le Remote

```bash
git remote -v
```

Vous devriez voir :
```
origin  https://github.com/Polosk0/discord.cool.bot.git (fetch)
origin  https://github.com/Polosk0/discord.cool.bot.git (push)
```

## 📤 Premier Push

### 1. Ajouter tous les fichiers

```bash
git add .
```

### 2. Faire le premier commit

```bash
git commit -m "Initial commit: Discord bot with network tools and DDoS capabilities"
```

### 3. Pousser vers GitHub

```bash
git branch -M main
git push -u origin main
```

Si c'est la première fois, GitHub vous demandera de vous authentifier.

## 🔄 Workflow Quotidien

### Push des modifications

```bash
# Voir les changements
git status

# Ajouter les fichiers modifiés
git add .

# Commit avec message descriptif
git commit -m "Description de vos modifications"

# Push vers GitHub
git push origin main
```

### Exemples de messages de commit

```bash
git commit -m "feat: Add new network command"
git commit -m "fix: Fix logger file writing issue"
git commit -m "docs: Update deployment guide"
git commit -m "refactor: Improve code structure"
```

## 🔐 Authentification GitHub

### Option 1: Personal Access Token (Recommandé)

1. Aller sur GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Générer un nouveau token avec les permissions `repo`
3. Utiliser le token comme mot de passe lors du push

### Option 2: SSH Key

```bash
# Générer une clé SSH
ssh-keygen -t ed25519 -C "votre-email@example.com"

# Copier la clé publique
cat ~/.ssh/id_ed25519.pub

# Ajouter sur GitHub → Settings → SSH and GPG keys
```

Puis changer le remote :
```bash
git remote set-url origin git@github.com:Polosk0/discord.cool.bot.git
```

## 📝 Fichiers à NE PAS Commiter

Le `.gitignore` est déjà configuré pour ignorer :
- `.env` (contient vos tokens secrets)
- `node_modules/` (dépendances)
- `logs/` (fichiers de logs)
- `bot.pid` (PID du processus)
- `dist/` (fichiers compilés)
- `backups/` (sauvegardes)

## ✅ Vérification

Après le push, vérifiez sur GitHub :
- Tous les fichiers sont présents
- Le `.env` n'est PAS présent (c'est normal)
- Le README.md est visible

## 🐛 Dépannage

### Erreur: "remote origin already exists"

```bash
git remote remove origin
git remote add origin https://github.com/Polosk0/discord.cool.bot.git
```

### Erreur: "failed to push some refs"

```bash
# Récupérer les changements distants
git pull origin main --rebase

# Puis repousser
git push origin main
```

### Erreur d'authentification

- Vérifier que vous utilisez le bon token/credentials
- Pour Windows, utiliser Git Credential Manager

## 📚 Commandes Utiles

```bash
# Voir l'historique
git log --oneline -10

# Voir les différences
git diff

# Annuler les changements non commités
git checkout .

# Voir les branches
git branch

# Créer une nouvelle branche
git checkout -b feature/nom-feature
```

## 🎯 Checklist Avant Push

- [ ] `.env` n'est pas dans les fichiers ajoutés
- [ ] `node_modules/` n'est pas commité
- [ ] Les logs ne sont pas commités
- [ ] Message de commit descriptif
- [ ] Code testé localement

