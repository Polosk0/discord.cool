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

print_header "Discord Bot Setup Script"

# Check Node.js
print_info "Checking Node.js installation..."
if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed. Please install Node.js 18+ first."
    exit 1
fi

NODE_VERSION=$(node --version)
print_success "Node.js found: $NODE_VERSION"

# Check PNPM
print_info "Checking PNPM installation..."
if ! command -v pnpm &> /dev/null; then
    print_warning "PNPM not found. Installing..."
    npm install -g pnpm
    if [ $? -ne 0 ]; then
        print_error "Failed to install PNPM"
        exit 1
    fi
    print_success "PNPM installed"
else
    PNPM_VERSION=$(pnpm --version)
    print_success "PNPM found: $PNPM_VERSION"
fi

# Install dependencies
print_info "Installing project dependencies..."
pnpm install

if [ $? -ne 0 ]; then
    print_error "Failed to install dependencies"
    exit 1
fi
print_success "Dependencies installed"

# Create .env from .env.example if .env doesn't exist
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        print_info "Creating .env from .env.example..."
        cp .env.example .env
        print_success ".env file created"
        print_warning "Please edit .env file with your configuration"
    else
        print_warning ".env.example not found. Creating basic .env..."
        cat > .env << EOF
DISCORD_TOKEN=your_discord_bot_token_here
CLIENT_ID=your_discord_client_id_here
PREFIX=!
ADMIN_IDS=user_id_1,user_id_2
MAX_ATTACK_DURATION=300
MAX_THREADS=100
RATE_LIMIT_DELAY=1000
NODE_ENV=development
EOF
        print_success ".env file created"
        print_warning "Please edit .env file with your configuration"
    fi
else
    print_info ".env file already exists"
fi

# Create logs directory
print_info "Creating logs directory..."
mkdir -p logs
print_success "Logs directory created"

# Make scripts executable
print_info "Making scripts executable..."
chmod +x scripts/*.sh 2>/dev/null || true
print_success "Scripts are executable"

print_header "Setup Complete"
print_success "Bot setup is complete!"
print_info "Next steps:"
print_info "1. Edit .env file with your Discord bot token and configuration"
print_info "2. Run './scripts/start.sh' to start the bot"
print_info "3. Run './scripts/deploy.sh' to deploy updates from Git"

