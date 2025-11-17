# 📊 Commandes pour Voir les Logs du Bot

## Commandes PM2 (Recommandé)

### Voir les logs en temps réel
```bash
pm2 logs discord-bot
```

### Voir les dernières lignes
```bash
# 50 dernières lignes
pm2 logs discord-bot --lines 50

# 100 dernières lignes
pm2 logs discord-bot --lines 100

# 200 dernières lignes
pm2 logs discord-bot --lines 200
```

### Voir uniquement les erreurs
```bash
pm2 logs discord-bot --err
```

### Voir uniquement les sorties standard
```bash
pm2 logs discord-bot --out
```

### Suivre les logs en temps réel (tail -f style)
```bash
pm2 logs discord-bot --lines 0
```

### Voir les logs d'un processus spécifique
```bash
pm2 logs discord-bot --nostream
```

## Commandes de Fichiers de Logs

### Voir les logs du bot (fichier)
```bash
tail -f logs/bot.log
```

### Voir les dernières lignes du fichier de log
```bash
tail -n 100 logs/bot.log
```

### Voir les logs PM2 (fichiers)
```bash
# Logs combinés
tail -f logs/pm2-combined.log

# Logs d'erreur
tail -f logs/pm2-error.log

# Logs de sortie
tail -f logs/pm2-out.log
```

### Rechercher dans les logs
```bash
# Chercher "error" dans les logs
grep -i error logs/bot.log

# Chercher "ERROR" dans les logs PM2
grep ERROR logs/pm2-combined.log

# Chercher avec contexte (5 lignes avant/après)
grep -C 5 "error" logs/bot.log
```

## Commandes Utiles

### Voir le statut du bot
```bash
pm2 status
pm2 info discord-bot
```

### Voir l'utilisation des ressources
```bash
pm2 monit
```

### Redémarrer et voir les logs
```bash
pm2 restart discord-bot && pm2 logs discord-bot --lines 50
```

### Nettoyer les logs PM2
```bash
pm2 flush
```

## Script de Debug Complet

Si vous avez le script `watch-logs.sh` :

```bash
chmod +x scripts/watch-logs.sh
./scripts/watch-logs.sh
```

## Exemples d'Utilisation

### Debug en temps réel
```bash
# Terminal 1 : Voir les logs
pm2 logs discord-bot

# Terminal 2 : Redémarrer le bot
pm2 restart discord-bot
```

### Voir les erreurs récentes
```bash
pm2 logs discord-bot --err --lines 100
```

### Surveiller les erreurs en continu
```bash
pm2 logs discord-bot --err --lines 0
```

