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

print_info "Opening PM2 monitoring dashboard"
print_info "Press Ctrl+C to exit"
echo ""

pm2 monit

