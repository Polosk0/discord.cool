#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info "Stopping Discord Bot (PM2)..."

if ! command -v pm2 &> /dev/null; then
    print_error "PM2 is not installed"
    exit 1
fi

if pm2 list | grep -q "discord-bot"; then
    pm2 stop discord-bot
    pm2 delete discord-bot
    print_success "Bot stopped and removed from PM2"
else
    print_error "Bot is not running with PM2"
    exit 1
fi

