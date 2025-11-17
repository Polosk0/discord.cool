#!/bin/bash

# Quick deploy script - Pull, install, restart
# Usage: ./scripts/quick-deploy.sh

CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${CYAN}[INFO]${NC} Quick deployment starting..."

# Stop bot
if [ -f bot.pid ]; then
    PID=$(cat bot.pid)
    if ps -p $PID > /dev/null 2>&1; then
        echo -e "${CYAN}[INFO]${NC} Stopping bot..."
        kill $PID
        sleep 2
    fi
    rm -f bot.pid
fi

# Pull changes
echo -e "${CYAN}[INFO]${NC} Pulling changes..."
git pull origin main

# Install dependencies
echo -e "${CYAN}[INFO]${NC} Installing dependencies..."
pnpm install

# Start bot
echo -e "${CYAN}[INFO]${NC} Starting bot..."
./scripts/start.sh

echo -e "${GREEN}[SUCCESS]${NC} Quick deployment complete!"

