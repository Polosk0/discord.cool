#!/bin/bash

set -uo pipefail

echo "=== Installation des prérequis pour L7-XCDDOS-FLOOD.js ==="
echo ""

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Vérifier si on est root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}⚠ Ce script doit être exécuté en tant que root${NC}"
    exit 1
fi

# Fonction pour vérifier si une commande existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 1. Vérifier/Installer Node.js
echo -e "${CYAN}[1/4] Vérification de Node.js...${NC}"
if command_exists node; then
    NODE_VERSION=$(node -v)
    echo -e "${GREEN}✓ Node.js est déjà installé: $NODE_VERSION${NC}"
    
    # Vérifier la version minimale (Node.js 12+ requis pour http2)
    NODE_MAJOR=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_MAJOR" -lt 12 ]; then
        echo -e "${YELLOW}⚠ Version de Node.js trop ancienne (< 12). Mise à jour nécessaire...${NC}"
        apt-get update -qq
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
        apt-get install -y nodejs
        echo -e "${GREEN}✓ Node.js mis à jour${NC}"
    fi
else
    echo -e "${YELLOW}Installation de Node.js...${NC}"
    apt-get update -qq
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs
    echo -e "${GREEN}✓ Node.js installé${NC}"
fi

# 2. Vérifier/Installer npm
echo -e "${CYAN}[2/4] Vérification de npm...${NC}"
if command_exists npm; then
    NPM_VERSION=$(npm -v)
    echo -e "${GREEN}✓ npm est déjà installé: v$NPM_VERSION${NC}"
else
    echo -e "${YELLOW}Installation de npm...${NC}"
    apt-get install -y npm
    echo -e "${GREEN}✓ npm installé${NC}"
fi

# 3. Installer les dépendances npm du script
echo -e "${CYAN}[3/4] Installation des modules npm requis...${NC}"

# Vérifier si package.json existe, sinon créer un environnement pour le script
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
cd "$SCRIPT_DIR"

# Installer colors (module requis par le script)
if [ -f "package.json" ]; then
    echo -e "${YELLOW}Installation via package.json...${NC}"
    npm install --production
else
    echo -e "${YELLOW}Installation du module 'colors'...${NC}"
    npm init -y > /dev/null 2>&1
    npm install colors --save
    echo -e "${GREEN}✓ Module 'colors' installé${NC}"
fi

# 4. Vérifier que le script peut être exécuté
echo -e "${CYAN}[4/4] Vérification finale...${NC}"

if [ -f "L7-XCDDOS-FLOOD.js" ]; then
    # Vérifier la syntaxe du script
    if node -c L7-XCDDOS-FLOOD.js 2>/dev/null; then
        echo -e "${GREEN}✓ Script syntaxiquement valide${NC}"
    else
        echo -e "${YELLOW}⚠ Le script contient des erreurs de syntaxe (peut être normal si dépend de paramètres)${NC}"
    fi
    
    # Rendre le script exécutable
    chmod +x L7-XCDDOS-FLOOD.js
    echo -e "${GREEN}✓ Script rendu exécutable${NC}"
else
    echo -e "${YELLOW}⚠ Fichier L7-XCDDOS-FLOOD.js non trouvé dans le répertoire actuel${NC}"
fi

# Afficher les versions installées
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC} ${GREEN}Installation terminée${NC}                                                  ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Versions installées:${NC}"
echo -e "  Node.js: $(node -v)"
echo -e "  npm: v$(npm -v)"
echo ""
echo -e "${YELLOW}Modules npm installés:${NC}"
npm list --depth=0 2>/dev/null | grep -E "colors|├──|└──" || echo "  - colors"
echo ""
echo -e "${CYAN}Utilisation du script:${NC}"
echo -e "  ${GREEN}node L7-XCDDOS-FLOOD.js <host> <time> <req> <thread> <proxy.txt> <data>${NC}"
echo ""
echo -e "${YELLOW}Exemple:${NC}"
echo -e "  node L7-XCDDOS-FLOOD.js https://example.com 60 1000 50 proxies.txt GET"
echo ""

