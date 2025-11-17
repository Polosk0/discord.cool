#!/bin/bash

set -uo pipefail

echo "=== Correction du problème de module ES pour L7-XCDDOS-FLOOD.js ==="
echo ""

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="/opt/discord.cool"

if [ ! -d "$SCRIPT_DIR" ]; then
    echo -e "${RED}Erreur: Répertoire $SCRIPT_DIR non trouvé${NC}"
    exit 1
fi

cd "$SCRIPT_DIR"

# Solution 1: Renommer en .cjs (recommandé)
if [ -f "L7-XCDDOS-FLOOD.js" ]; then
    echo -e "${CYAN}Solution 1: Renommage en .cjs (CommonJS)${NC}"
    mv L7-XCDDOS-FLOOD.js L7-XCDDOS-FLOOD.cjs
    echo -e "${GREEN}✓ Fichier renommé en L7-XCDDOS-FLOOD.cjs${NC}"
    echo ""
    echo -e "${YELLOW}Nouvelle commande d'utilisation:${NC}"
    echo -e "${GREEN}node L7-XCDDOS-FLOOD.cjs <host> <time> <req> <thread> <proxy.txt> <data>${NC}"
    echo ""
    echo -e "${CYAN}Exemple:${NC}"
    echo -e "${GREEN}node L7-XCDDOS-FLOOD.cjs https://example.com 60 1000 50 proxies.txt GET${NC}"
else
    echo -e "${YELLOW}⚠ Fichier L7-XCDDOS-FLOOD.js non trouvé${NC}"
    if [ -f "L7-XCDDOS-FLOOD.cjs" ]; then
        echo -e "${GREEN}✓ Le fichier est déjà en .cjs${NC}"
    fi
fi

echo ""
echo -e "${CYAN}=== Solution alternative (si vous préférez garder .js) ===${NC}"
echo ""
echo -e "${YELLOW}Vous pouvez aussi créer un fichier package.json local pour ce script:${NC}"
echo ""
cat << 'EOF'
{
  "type": "commonjs"
}
EOF

echo ""
echo -e "${CYAN}Ou utiliser node avec --input-type=commonjs:${NC}"
echo -e "${GREEN}node --input-type=commonjs L7-XCDDOS-FLOOD.js <params>${NC}"
echo ""

