# discord.cool.bot

Bot Discord professionnel avec outils réseau, DDoS et monitoring système.

[![GitHub](https://img.shields.io/badge/GitHub-Polosk0%2Fdiscord.cool.bot-blue)](https://github.com/Polosk0/discord.cool.bot)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Node.js](https://img.shields.io/badge/Node.js-18%2B-brightgreen)](https://nodejs.org/)

## Description

Bot Discord modulaire offrant des fonctionnalités avancées pour les tests réseau, l'analyse système et les outils de diagnostic. Architecture propre et extensible avec système de commandes slash.

## Fonctionnalités

### 🚀 DDoS Tools
- **HTTP Flood** - Attaque par inondation HTTP
- **TCP Flood** - Attaque par inondation TCP
- Gestion des attaques actives
- Limitation de durée et de threads

### 🌐 Network Tools
- **Ping** - Test de connectivité réseau
- **Traceroute** - Traçage de route réseau
- **Port Scan** - Scan de ports (commun, range, single)
- **DNS Lookup** - Résolution DNS et reverse DNS

### 💻 System Monitoring
- **Dstat** - Statistiques système en temps réel
  - CPU (usage, cores)
  - Mémoire (used, total, percentage)
  - Réseau (received, sent)
  - Disque (used, total, percentage)

### 🛠️ Utility
- **Help** - Documentation des commandes
- Rate limiting par utilisateur
- Gestion des erreurs robuste
- Logging complet

## Installation

```bash
# Cloner le repository
git clone https://github.com/Polosk0/discord.cool.bot.git
cd discord.cool.bot

# Installer les dépendances
pnpm install
```

## Configuration

1. Copiez le fichier `.env.example` vers `.env`
2. Configurez vos variables d'environnement :

```env
DISCORD_TOKEN=your_discord_bot_token_here
CLIENT_ID=your_discord_client_id_here
PREFIX=!
ADMIN_IDS=user_id_1,user_id_2
MAX_ATTACK_DURATION=300
MAX_THREADS=100
RATE_LIMIT_DELAY=1000
NODE_ENV=development
```

### Obtenir un token Discord

1. Allez sur [Discord Developer Portal](https://discord.com/developers/applications)
2. Créez une nouvelle application
3. Allez dans "Bot" et créez un bot
4. Copiez le token dans votre `.env`
5. Activez les intents nécessaires dans "Privileged Gateway Intents"

## Utilisation

```bash
# Mode développement (avec watch)
pnpm dev

# Build du projet
pnpm build

# Production
pnpm start
```

## Structure du projet

```
discord.cool/
├── src/
│   ├── commands/          # Commandes Discord organisées par catégorie
│   │   ├── ddos/          # Commandes DDoS
│   │   │   ├── attack.ts  # Lancement d'attaque
│   │   │   └── stop.ts    # Arrêt des attaques
│   │   ├── network/       # Outils réseau
│   │   │   ├── ping.ts
│   │   │   ├── traceroute.ts
│   │   │   ├── port-scan.ts
│   │   │   └── dns-lookup.ts
│   │   ├── system/        # Monitoring système
│   │   │   └── dstat.ts
│   │   ├── utility/       # Utilitaires
│   │   │   └── help.ts
│   │   └── index.ts       # Chargement des commandes
│   ├── services/          # Services métier
│   │   ├── ddos/          # Services DDoS
│   │   │   ├── http-flood.ts
│   │   │   ├── tcp-flood.ts
│   │   │   └── index.ts
│   │   ├── network/       # Services réseau
│   │   │   ├── ping.ts
│   │   │   ├── traceroute.ts
│   │   │   ├── port-scan.ts
│   │   │   ├── dns-lookup.ts
│   │   │   └── index.ts
│   │   └── system/        # Services système
│   │       ├── dstat.ts
│   │       └── index.ts
│   ├── events/            # Événements Discord
│   │   ├── ready.ts       # Bot prêt
│   │   ├── interaction-create.ts
│   │   └── index.ts
│   ├── utils/             # Utilitaires
│   │   ├── logger.ts      # Système de logging
│   │   ├── validators.ts  # Validation des entrées
│   │   └── rate-limiter.ts # Rate limiting
│   ├── middleware/        # Middleware
│   │   └── error-handler.ts
│   ├── types/             # Types TypeScript
│   │   └── index.ts
│   ├── config/            # Configuration
│   │   └── index.ts
│   └── index.ts           # Point d'entrée
├── .env.example           # Exemple de configuration
├── .gitignore
├── tsconfig.json          # Configuration TypeScript
├── package.json
└── README.md
```

## Commandes disponibles

### DDoS
- `/attack` - Lancer une attaque DDoS
- `/stop` - Arrêter toutes les attaques actives

### Network
- `/ping <host> [count]` - Ping un hôte
- `/traceroute <host> [max-hops]` - Tracer la route vers un hôte
- `/port-scan <host> <type> [options]` - Scanner les ports
- `/dns-lookup <hostname> [reverse]` - Résolution DNS

### System
- `/dstat` - Afficher les statistiques système

### Utility
- `/help` - Afficher l'aide

## Sécurité

- Rate limiting par utilisateur et par commande
- Validation stricte des entrées
- Restrictions d'administration
- Limites de durée et de threads pour les attaques
- Gestion d'erreurs robuste

## Développement

Le projet utilise :
- **TypeScript** pour la sécurité des types
- **Discord.js v14** pour l'API Discord
- Architecture modulaire et extensible
- Système de logging structuré

## Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou une pull request.

## Avertissement

⚠️ **Ce bot est destiné à des fins éducatives et de test uniquement. L'utilisation de ces outils pour attaquer des systèmes sans autorisation est illégale et peut entraîner des poursuites judiciaires.**

## Licence

Voir le fichier [LICENSE](LICENSE) pour plus d'informations.

