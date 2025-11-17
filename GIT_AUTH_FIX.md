# 🔐 Résolution du Problème d'Authentification Git

## Solution 1 : Utiliser un Personal Access Token (Recommandé)

### Étape 1 : Créer un Personal Access Token sur GitHub

1. Allez sur GitHub : https://github.com/settings/tokens
2. Cliquez sur "Generate new token" > "Generate new token (classic)"
3. Donnez un nom (ex: "VPS Bot Deploy")
4. Cochez la permission `repo` (accès complet aux repositories)
5. Cliquez sur "Generate token"
6. **COPIEZ LE TOKEN** (vous ne le verrez qu'une fois)

### Étape 2 : Configurer Git sur votre VPS

```bash
# Sur votre VPS, exécutez :
cd /opt/discord.cool.bot

# Configurer Git pour utiliser le token
git remote set-url origin https://VOTRE_TOKEN@github.com/Polosk0/discord.cool.git

# Remplacer VOTRE_TOKEN par le token que vous avez copié
# Exemple : git remote set-url origin https://ghp_xxxxxxxxxxxx@github.com/Polosk0/discord.cool.git
```

### Étape 3 : Vérifier

```bash
git remote -v
# Devrait afficher : https://ghp_xxxxx@github.com/Polosk0/discord.cool.git
```

## Solution 2 : Utiliser SSH (Plus sécurisé)

### Étape 1 : Générer une clé SSH sur votre VPS

```bash
# Générer une clé SSH (si vous n'en avez pas)
ssh-keygen -t ed25519 -C "vps-bot-deploy"
# Appuyez sur Entrée pour accepter les valeurs par défaut
```

### Étape 2 : Afficher la clé publique

```bash
cat ~/.ssh/id_ed25519.pub
# Copiez tout le contenu affiché
```

### Étape 3 : Ajouter la clé sur GitHub

1. Allez sur : https://github.com/settings/keys
2. Cliquez sur "New SSH key"
3. Donnez un titre (ex: "VPS Bot")
4. Collez la clé publique
5. Cliquez sur "Add SSH key"

### Étape 4 : Changer le remote vers SSH

```bash
cd /opt/discord.cool.bot
git remote set-url origin git@github.com:Polosk0/discord.cool.git
git remote -v
```

## Solution 3 : Utiliser Git Credential Helper (Temporaire)

```bash
# Configurer le credential helper pour stocker les identifiants
git config --global credential.helper store

# Faire un pull manuel une fois (entrer username et token)
git pull origin main
# Username: votre_username_github
# Password: votre_personal_access_token

# Les identifiants seront sauvegardés pour les prochaines fois
```

## Solution 4 : Modifier le script deploy.sh pour utiliser un token

Si vous préférez garder le token dans une variable d'environnement :

```bash
# Ajouter dans votre .env ou .bashrc
export GITHUB_TOKEN="votre_token_ici"

# Puis modifier le remote dans le script ou utiliser :
git remote set-url origin https://${GITHUB_TOKEN}@github.com/Polosk0/discord.cool.git
```

## 🚀 Après avoir configuré l'authentification

Relancez le script de déploiement :

```bash
cd /opt/discord.cool.bot
./scripts/deploy.sh
```

## ⚠️ Important

- **Ne partagez JAMAIS votre token ou clé privée**
- Le token doit avoir la permission `repo`
- Pour SSH, utilisez uniquement la clé **publique** sur GitHub

