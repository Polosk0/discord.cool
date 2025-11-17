# Structure du Projet

Arborescence complète du bot Discord avec outils réseau et DDoS.

```
bot-script-discordtool/
├── src/
│   ├── commands/                    # Commandes Discord (Slash Commands)
│   │   ├── ddos/                    # Catégorie: DDoS
│   │   │   ├── attack.ts           # /attack - Lancer une attaque
│   │   │   └── stop.ts             # /stop - Arrêter les attaques
│   │   ├── network/                 # Catégorie: Outils réseau
│   │   │   ├── ping.ts             # /ping - Test de connectivité
│   │   │   ├── traceroute.ts       # /traceroute - Traçage de route
│   │   │   ├── port-scan.ts        # /port-scan - Scan de ports
│   │   │   └── dns-lookup.ts       # /dns-lookup - Résolution DNS
│   │   ├── system/                  # Catégorie: Monitoring système
│   │   │   └── dstat.ts            # /dstat - Statistiques système
│   │   ├── utility/                 # Catégorie: Utilitaires
│   │   │   └── help.ts             # /help - Aide
│   │   └── index.ts                 # Chargement et export des commandes
│   │
│   ├── services/                    # Services métier (logique applicative)
│   │   ├── ddos/                    # Services DDoS
│   │   │   ├── http-flood.ts       # Implémentation HTTP Flood
│   │   │   ├── tcp-flood.ts        # Implémentation TCP Flood
│   │   │   └── index.ts            # Service DDoS principal
│   │   ├── network/                 # Services réseau
│   │   │   ├── ping.ts             # Service ping
│   │   │   ├── traceroute.ts       # Service traceroute
│   │   │   ├── port-scan.ts        # Service scan de ports
│   │   │   ├── dns-lookup.ts       # Service DNS lookup
│   │   │   └── index.ts            # Export des services réseau
│   │   └── system/                  # Services système
│   │       ├── dstat.ts            # Service statistiques système
│   │       └── index.ts            # Export des services système
│   │
│   ├── events/                      # Événements Discord
│   │   ├── ready.ts                # Événement: Bot prêt
│   │   ├── interaction-create.ts   # Événement: Interaction créée
│   │   └── index.ts                # Chargement des événements
│   │
│   ├── utils/                       # Utilitaires réutilisables
│   │   ├── logger.ts               # Système de logging
│   │   ├── validators.ts           # Validation des entrées
│   │   └── rate-limiter.ts         # Rate limiting par utilisateur
│   │
│   ├── middleware/                  # Middleware
│   │   └── error-handler.ts        # Gestionnaire d'erreurs centralisé
│   │
│   ├── types/                       # Types TypeScript
│   │   └── index.ts                # Définitions de types
│   │
│   ├── config/                      # Configuration
│   │   └── index.ts                # Configuration centralisée
│   │
│   └── index.ts                     # Point d'entrée principal
│
├── .env.example                     # Exemple de fichier d'environnement
├── .gitignore                       # Fichiers ignorés par Git
├── tsconfig.json                    # Configuration TypeScript
├── package.json                     # Dépendances et scripts
├── README.md                        # Documentation principale
└── STRUCTURE.md                     # Ce fichier
```

## Organisation par couches

### 1. **Commands** (Présentation)
- Interface utilisateur Discord
- Gestion des interactions
- Validation des entrées utilisateur
- Formatage des réponses

### 2. **Services** (Logique métier)
- Implémentation des fonctionnalités
- Logique de traitement
- Appels système et réseau
- Gestion des données

### 3. **Utils/Middleware** (Infrastructure)
- Logging
- Validation
- Rate limiting
- Gestion d'erreurs

### 4. **Config/Types** (Configuration)
- Types TypeScript
- Configuration centralisée
- Variables d'environnement

### 5. **Events** (Intégration Discord)
- Événements Discord
- Initialisation du bot
- Gestion des interactions

## Flux de données

```
User → Discord → Event → Command → Service → System/Network → Response → Discord → User
```

## Principes d'architecture

1. **Séparation des responsabilités**: Chaque module a une responsabilité unique
2. **Modularité**: Facile d'ajouter de nouvelles commandes/services
3. **Réutilisabilité**: Services et utils réutilisables
4. **Type safety**: TypeScript pour la sécurité des types
5. **Extensibilité**: Structure facile à étendre

## Ajout d'une nouvelle commande

1. Créer le service dans `src/services/[category]/`
2. Créer la commande dans `src/commands/[category]/`
3. Importer dans `src/commands/index.ts`
4. Ajouter les types si nécessaire dans `src/types/index.ts`

## Ajout d'un nouveau service

1. Créer le fichier dans `src/services/[category]/`
2. Exporter dans `src/services/[category]/index.ts`
3. Utiliser dans les commandes appropriées

