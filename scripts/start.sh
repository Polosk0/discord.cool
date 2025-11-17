#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Bot configuration
BOT_NAME="Discord Bot"
LOG_FILE="logs/bot.log"
PID_FILE="bot.pid"

# Create logs directory if it doesn't exist
mkdir -p logs

# Function to print colored messages
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

print_debug() {
    echo -e "${MAGENTA}[DEBUG]${NC} $1"
}

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${WHITE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

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

# Check if bot is already running
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if ps -p $OLD_PID > /dev/null 2>&1; then
        print_warning "Bot is already running (PID: $OLD_PID)"
        print_info "Use './scripts/stop.sh' to stop it first"
        exit 1
    else
        print_info "Removing stale PID file"
        rm -f "$PID_FILE"
    fi
fi

# Display startup information
print_header "Starting $BOT_NAME"
print_info "Time: $(date '+%Y-%m-%d %H:%M:%S')"
print_info "Node version: $(node --version)"
print_info "PNPM version: $(pnpm --version)"
print_info "Working directory: $(pwd)"
print_info "Log file: $LOG_FILE"
echo ""

# Start the bot
print_info "Starting bot process..."
print_debug "Command: pnpm dev"

# Start bot in background and capture PID
pnpm dev > "$LOG_FILE" 2>&1 &
BOT_PID=$!

# Save PID
echo $BOT_PID > "$PID_FILE"
print_success "Bot started with PID: $BOT_PID"

# Wait a moment and check if process is still running
sleep 2
if ps -p $BOT_PID > /dev/null 2>&1; then
    print_success "Bot is running successfully!"
    print_info "PID file: $PID_FILE"
    print_info "Log file: $LOG_FILE"
    print_info "To view logs: tail -f $LOG_FILE"
    print_info "To stop bot: ./scripts/stop.sh"
    echo ""
    print_header "Bot Status"
    tail -n 20 "$LOG_FILE" | while IFS= read -r line; do
        if [[ $line == *"[ERROR]"* ]]; then
            echo -e "${RED}$line${NC}"
        elif [[ $line == *"[WARN]"* ]]; then
            echo -e "${YELLOW}$line${NC}"
        elif [[ $line == *"[INFO]"* ]]; then
            echo -e "${CYAN}$line${NC}"
        elif [[ $line == *"[DEBUG]"* ]]; then
            echo -e "${MAGENTA}$line${NC}"
        else
            echo -e "${WHITE}$line${NC}"
        fi
    done
else
    print_error "Bot failed to start!"
    print_info "Check logs: $LOG_FILE"
    rm -f "$PID_FILE"
    exit 1
fi

