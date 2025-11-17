#!/bin/bash

# Script pour rendre tous les scripts exécutables
# Usage: ./scripts/fix-permissions.sh

CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${CYAN}[INFO]${NC} Fixing script permissions..."

chmod +x scripts/*.sh

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[SUCCESS]${NC} All scripts are now executable"
    echo ""
    echo "You can now run:"
    echo "  ./scripts/deploy.sh"
    echo "  ./scripts/pm2-start.sh"
    echo "  ./scripts/pm2-stop.sh"
    echo "  etc."
else
    echo -e "${RED}[ERROR]${NC} Failed to fix permissions"
    exit 1
fi

