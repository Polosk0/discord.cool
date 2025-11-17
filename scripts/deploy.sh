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

# Configuration
REPO_URL="${GIT_REPO_URL:-https://github.com/Polosk0/discord.cool.bot.git}"
BRANCH="${GIT_BRANCH:-main}"
BACKUP_DIR="backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

print_header "Discord Bot Deployment Script"

# Check if git is installed
if ! command -v git &> /dev/null; then
    print_error "Git is not installed. Please install it first."
    exit 1
fi

# Check if pnpm is installed
if ! command -v pnpm &> /dev/null; then
    print_error "PNPM is not installed. Installing..."
    npm install -g pnpm
    if [ $? -ne 0 ]; then
        print_error "Failed to install PNPM"
        exit 1
    fi
    print_success "PNPM installed"
fi

# Backup current .env if it exists
if [ -f .env ]; then
    print_info "Backing up .env file..."
    mkdir -p "$BACKUP_DIR"
    cp .env "$BACKUP_DIR/.env.backup.$TIMESTAMP"
    print_success ".env backed up to $BACKUP_DIR/.env.backup.$TIMESTAMP"
fi

# Stop bot if running (check PM2 first, then PID file)
if command -v pm2 &> /dev/null && pm2 list | grep -q "discord-bot"; then
    print_info "Stopping bot (PM2)..."
    pm2 stop discord-bot
    print_success "Bot stopped (PM2)"
elif [ -f bot.pid ]; then
    PID=$(cat bot.pid)
    if ps -p $PID > /dev/null 2>&1; then
        print_info "Stopping bot..."
        kill $PID
        sleep 2
        print_success "Bot stopped"
    fi
    rm -f bot.pid
fi

# Git operations
if [ -d .git ]; then
    print_info "Fetching latest changes from repository..."
    git fetch origin
    
    # Check for local changes
    if ! git diff-index --quiet HEAD --; then
        print_warning "Local changes detected. Stashing them..."
        git stash push -m "Auto-stash before deploy $(date +%Y%m%d_%H%M%S)"
        print_success "Local changes stashed"
    fi
    
    print_info "Pulling changes from branch: $BRANCH"
    git pull origin "$BRANCH"
    
    if [ $? -ne 0 ]; then
        print_error "Failed to pull changes"
        print_info "Trying to resolve conflicts..."
        
        # Try to reset to remote if pull fails
        print_warning "Resetting to match remote (local changes will be lost)"
        git fetch origin
        git reset --hard origin/"$BRANCH"
        
        if [ $? -eq 0 ]; then
            print_success "Successfully reset to remote branch"
        else
            print_error "Failed to reset. Please resolve conflicts manually"
            exit 1
        fi
    else
        print_success "Code updated successfully"
    fi
else
    if [ -z "$REPO_URL" ]; then
        print_error "Not a git repository and REPO_URL not set"
        print_info "To clone a repository, set GIT_REPO_URL environment variable"
        exit 1
    fi
    
    print_info "Cloning repository: $REPO_URL"
    git clone "$REPO_URL" .
    if [ $? -ne 0 ]; then
        print_error "Failed to clone repository"
        exit 1
    fi
    print_success "Repository cloned"
fi

# Restore .env from backup if new one doesn't exist
if [ ! -f .env ] && [ -f "$BACKUP_DIR/.env.backup.$TIMESTAMP" ]; then
    print_info "Restoring .env from backup..."
    cp "$BACKUP_DIR/.env.backup.$TIMESTAMP" .env
    print_success ".env restored"
fi

# Install/update dependencies
print_info "Installing dependencies..."
pnpm install

if [ $? -ne 0 ]; then
    print_error "Failed to install dependencies"
    exit 1
fi
print_success "Dependencies installed"

# Build project if needed (optional, we use tsx directly)
if [ -f "package.json" ] && grep -q "\"build\"" package.json; then
    print_info "Building project (optional, using tsx for runtime)..."
    pnpm build 2>&1 | head -20
    if [ $? -ne 0 ]; then
        print_warning "Build failed, but continuing (using tsx directly)..."
    else
        print_success "Project built successfully"
    fi
fi

# Check .env file
if [ ! -f .env ]; then
    print_warning ".env file not found!"
    if [ -f .env.example ]; then
        print_info "Copying .env.example to .env"
        cp .env.example .env
        print_warning "Please edit .env file with your configuration before starting the bot"
    else
        print_error ".env.example not found. Please create .env manually"
    fi
fi

print_header "Deployment Complete"
print_success "Bot is ready to start"

# Make sure start scripts are executable
chmod +x start.sh start.js 2>/dev/null || true

# Restart with PM2 if available, otherwise use start script
if command -v pm2 &> /dev/null; then
    print_info "Restarting bot with PM2..."
    if pm2 list | grep -q "discord-bot"; then
        pm2 restart discord-bot
        print_success "Bot restarted with PM2"
        print_info "To view logs: pm2 logs discord-bot"
    else
        print_info "Starting bot with PM2..."
        pm2 start ecosystem.config.js
        if [ $? -eq 0 ]; then
            print_success "Bot started with PM2"
            print_info "To view logs: pm2 logs discord-bot"
        else
            print_error "Failed to start with PM2. Check logs above."
            print_info "Try manually: pm2 start ecosystem.config.js"
        fi
    fi
else
    print_info "PM2 not found. Use: ./scripts/start.sh"
    print_info "To view logs: tail -f logs/bot.log"
    print_info "Or install PM2: npm install -g pm2"
fi

