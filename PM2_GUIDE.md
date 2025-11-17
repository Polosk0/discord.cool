# 🚀 Guide PM2 - Gestion du Bot Discord

Guide complet pour utiliser PM2 avec votre bot Discord.

## 📋 Qu'est-ce que PM2 ?

PM2 est un gestionnaire de processus pour Node.js qui permet de :
- ✅ Démarrer le bot automatiquement au démarrage du serveur
- ✅ Redémarrer automatiquement en cas de crash
- ✅ Surveiller les performances (CPU, mémoire)
- ✅ Gérer les logs facilement
- ✅ Gérer plusieurs instances

## 🔧 Installation

### Sur le VPS

```bash
# Installer PM2 globalement
npm install -g pm2

# Vérifier l'installation
pm2 --version
```

## 🚀 Utilisation

### Démarrer le Bot avec PM2

```bash
./scripts/pm2-start.sh
```

Ou manuellement :
```bash
pm2 start ecosystem.config.js
```

### Arrêter le Bot

```bash
./scripts/pm2-stop.sh
```

Ou manuellement :
```bash
pm2 stop discord-bot
pm2 delete discord-bot
```

### Redémarrer le Bot

```bash
pm2 restart discord-bot
```

### Voir les Logs en Temps Réel

```bash
# Script automatique avec couleurs
./scripts/pm2-logs.sh

# Ou directement
pm2 logs discord-bot

# Logs avec nombre de lignes
pm2 logs discord-bot --lines 100

# Logs d'erreur uniquement
pm2 logs discord-bot --err

# Logs de sortie uniquement
pm2 logs discord-bot --out
```

### Monitorer en Temps Réel

```bash
# Script automatique
./scripts/pm2-monitor.sh

# Ou directement
pm2 monit
```

Affiche :
- 📊 CPU usage
- 💾 Memory usage
- 📝 Logs en temps réel
- 🔄 Restart count

## 📊 Commandes PM2 Essentielles

### Voir le Statut

```bash
pm2 status
pm2 list
```

### Informations Détaillées

```bash
pm2 info discord-bot
pm2 describe discord-bot
```

### Redémarrer

```bash
pm2 restart discord-bot      # Redémarre le bot
pm2 reload discord-bot       # Recharge sans downtime
pm2 restart all              # Redémarre tous les processus
```

### Logs

```bash
pm2 logs discord-bot         # Logs en temps réel
pm2 logs discord-bot --lines 50  # 50 dernières lignes
pm2 flush                    # Vider tous les logs
```

### Monitoring

```bash
pm2 monit                    # Dashboard interactif
pm2 show discord-bot         # Détails du processus
```

## 🔄 Démarrage Automatique au Boot

### Sauvegarder la Configuration PM2

```bash
# Sauvegarder la liste des processus
pm2 save

# Configurer le démarrage automatique
pm2 startup

# Suivre les instructions affichées (copier-coller la commande)
```

### Désactiver le Démarrage Automatique

```bash
pm2 unstartup
```

## 📝 Fichiers de Logs PM2

Les logs PM2 sont sauvegardés dans :
- `logs/pm2-error.log` - Erreurs uniquement
- `logs/pm2-out.log` - Sortie standard
- `logs/pm2-combined.log` - Logs combinés

### Voir les Logs Fichiers

```bash
# Logs d'erreur
tail -f logs/pm2-error.log

# Logs de sortie
tail -f logs/pm2-out.log

# Logs combinés
tail -f logs/pm2-combined.log
```

## 🐛 Debug et Dépannage

### Voir les Logs de Debug

```bash
# Logs en temps réel (recommandé)
pm2 logs discord-bot --lines 100

# Logs avec timestamp
pm2 logs discord-bot --timestamp

# Logs JSON (pour parsing)
pm2 logs discord-bot --json
```

### Vérifier les Erreurs

```bash
# Dernières erreurs
pm2 logs discord-bot --err --lines 50

# Ou dans le fichier
tail -n 100 logs/pm2-error.log | grep ERROR
```

### Redémarrer après un Crash

PM2 redémarre automatiquement, mais vous pouvez forcer :

```bash
pm2 restart discord-bot
pm2 logs discord-bot --lines 50
```

### Voir l'Utilisation des Ressources

```bash
pm2 monit
# Ou
pm2 show discord-bot
```

## 🔧 Configuration PM2

Le fichier `ecosystem.config.js` contient la configuration :

```javascript
{
  name: 'discord-bot',           // Nom du processus
  script: 'pnpm',                // Commande à exécuter
  args: 'dev',                   // Arguments
  instances: 1,                  // Nombre d'instances
  autorestart: true,             // Redémarrage automatique
  max_memory_restart: '500M',    // Redémarrer si > 500MB RAM
  error_file: './logs/pm2-error.log',
  out_file: './logs/pm2-out.log',
}
```

### Modifier la Configuration

```bash
# Éditer le fichier
nano ecosystem.config.js

# Redémarrer avec la nouvelle config
pm2 restart discord-bot --update-env
```

## 📊 Statistiques

### Voir les Statistiques

```bash
pm2 status
pm2 show discord-bot
```

Affiche :
- Uptime (temps de fonctionnement)
- Restarts (nombre de redémarrages)
- CPU usage
- Memory usage

### Export des Statistiques

```bash
pm2 jlist                    # JSON
pm2 prettylist              # Format lisible
```

## 🔄 Intégration avec les Scripts de Déploiement

### Mettre à Jour le Script deploy.sh

Le script `deploy.sh` peut être modifié pour utiliser PM2 :

```bash
# Dans deploy.sh, remplacer :
./scripts/stop.sh
./scripts/start.sh

# Par :
pm2 stop discord-bot
pm2 restart discord-bot
```

## ✅ Checklist PM2

- [ ] PM2 installé (`npm install -g pm2`)
- [ ] Bot démarré avec PM2 (`./scripts/pm2-start.sh`)
- [ ] Configuration sauvegardée (`pm2 save`)
- [ ] Démarrage automatique configuré (`pm2 startup`)
- [ ] Logs accessibles (`pm2 logs discord-bot`)
- [ ] Monitoring fonctionnel (`pm2 monit`)

## 🎯 Commandes Rapides

```bash
# Démarrer
./scripts/pm2-start.sh

# Voir les logs
pm2 logs discord-bot

# Monitorer
pm2 monit

# Redémarrer
pm2 restart discord-bot

# Arrêter
./scripts/pm2-stop.sh

# Statut
pm2 status
```

## 💡 Astuces

1. **Logs Rotatifs** : PM2 gère automatiquement la rotation des logs
2. **Cluster Mode** : Pour plusieurs instances, modifier `instances` dans `ecosystem.config.js`
3. **Variables d'Environnement** : Utiliser `env` et `env_production` dans la config
4. **Monitoring** : Utiliser `pm2 monit` pour voir les ressources en temps réel

## 🔗 Ressources

- [Documentation PM2](https://pm2.keymetrics.io/docs/usage/quick-start/)
- [PM2 Ecosystem File](https://pm2.keymetrics.io/docs/usage/application-declaration/)

