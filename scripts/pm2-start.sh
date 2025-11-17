#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${WHITE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_header "Starting Discord Bot with PM2"

# Check if PM2 is installed
if ! command -v pm2 &> /dev/null; then
    print_error "PM2 is not installed. Installing..."
    npm install -g pm2
    if [ $? -ne 0 ]; then
        print_error "Failed to install PM2"
        exit 1
    fi
    print_success "PM2 installed"
fi

# Check if .env exists
if [ ! -f .env ]; then
    print_error ".env file not found!"
    print_info "Please create .env file with your configuration"
    exit 1
fi

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    print_warning "node_modules not found. Installing dependencies..."
    pnpm install
    if [ $? -ne 0 ]; then
        print_error "Failed to install dependencies"
        exit 1
    fi
    print_success "Dependencies installed"
fi

# Create logs directory
mkdir -p logs

# Check if bot is already running
if pm2 list | grep -q "discord-bot"; then
    print_warning "Bot is already running with PM2"
    print_info "Use './scripts/pm2-stop.sh' to stop it first"
    print_info "Or use 'pm2 restart discord-bot' to restart it"
    exit 1
fi

# Start with PM2
print_info "Starting bot with PM2..."
pm2 start ecosystem.config.js

if [ $? -eq 0 ]; then
    print_success "Bot started with PM2!"
    print_info "Bot name: discord-bot"
    print_info ""
    print_info "Useful commands:"
    print_info "  pm2 status              - View bot status"
    print_info "  pm2 logs discord-bot    - View logs"
    print_info "  pm2 monit               - Monitor in real-time"
    print_info "  pm2 restart discord-bot - Restart bot"
    print_info "  pm2 stop discord-bot    - Stop bot"
    print_info ""
    print_info "To save PM2 configuration:"
    print_info "  pm2 save"
    print_info "  pm2 startup"
else
    print_error "Failed to start bot with PM2"
    exit 1
fi

