#!/bin/bash

# Colors
CYAN='\033[0;36m'
NC='\033[0m'

print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

# Check if PM2 is installed
if ! command -v pm2 &> /dev/null; then
    echo "PM2 is not installed. Please install it first: npm install -g pm2"
    exit 1
fi

# Check if bot is running
if ! pm2 list | grep -q "discord-bot"; then
    echo "Bot is not running with PM2. Start it first with: ./scripts/pm2-start.sh"
    exit 1
fi

print_info "Viewing PM2 logs for discord-bot"
print_info "Press Ctrl+C to stop"
echo ""

# Show logs with colors
pm2 logs discord-bot --lines 50

