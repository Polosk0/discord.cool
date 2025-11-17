#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

PID_FILE="bot.pid"

print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

if [ ! -f "$PID_FILE" ]; then
    print_error "PID file not found. Bot may not be running."
    exit 1
fi

PID=$(cat "$PID_FILE")

if ! ps -p $PID > /dev/null 2>&1; then
    print_error "Bot process (PID: $PID) is not running"
    rm -f "$PID_FILE"
    exit 1
fi

print_info "Stopping bot (PID: $PID)..."
kill $PID

# Wait for process to stop
for i in {1..10}; do
    if ! ps -p $PID > /dev/null 2>&1; then
        print_success "Bot stopped successfully"
        rm -f "$PID_FILE"
        exit 0
    fi
    sleep 1
done

# Force kill if still running
print_info "Force killing bot..."
kill -9 $PID
rm -f "$PID_FILE"
print_success "Bot force stopped"

