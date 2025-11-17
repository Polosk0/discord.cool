#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

LOG_FILE="${1:-logs/bot.log}"

if [ ! -f "$LOG_FILE" ]; then
    echo -e "${RED}[ERROR]${NC} Log file not found: $LOG_FILE"
    exit 1
fi

echo -e "${CYAN}[INFO]${NC} Watching log file: $LOG_FILE"
echo -e "${CYAN}[INFO]${NC} Press Ctrl+C to stop"
echo ""

tail -f "$LOG_FILE" | while IFS= read -r line; do
    if [[ $line == *"[ERROR]"* ]]; then
        echo -e "${RED}$line${NC}"
    elif [[ $line == *"[WARN]"* ]]; then
        echo -e "${YELLOW}$line${NC}"
    elif [[ $line == *"[INFO]"* ]]; then
        echo -e "${CYAN}$line${NC}"
    elif [[ $line == *"[DEBUG]"* ]]; then
        echo -e "${MAGENTA}$line${NC}"
    elif [[ $line == *"[SUCCESS]"* ]]; then
        echo -e "${GREEN}$line${NC}"
    else
        echo -e "${WHITE}$line${NC}"
    fi
done

