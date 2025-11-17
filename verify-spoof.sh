#!/bin/bash

set -uo pipefail

echo "=== Vérification de l'installation spoof ==="
echo ""

ERRORS=0
WARNINGS=0

# Fonction pour vérifier une commande
check_command() {
    local cmd=$1
    local name=$2
    
    if command -v "$cmd" &> /dev/null; then
        echo "✓ $name: $(which $cmd)"
        return 0
    else
        echo "✗ $name: NON INSTALLÉ"
        ((ERRORS++))
        return 1
    fi
}

# Fonction pour vérifier un processus
check_process() {
    local process=$1
    local name=$2
    
    if pgrep -f "$process" > /dev/null; then
        echo "✓ $name: EN COURS D'EXÉCUTION"
        return 0
    else
        echo "⚠ $name: NON DÉMARRÉ"
        ((WARNINGS++))
        return 1
    fi
}

# Fonction pour vérifier un répertoire
check_directory() {
    local dir=$1
    local name=$2
    
    if [ -d "$dir" ]; then
        echo "✓ $name: $dir existe"
        return 0
    else
        echo "✗ $name: $dir n'existe pas"
        ((ERRORS++))
        return 1
    fi
}

# Fonction pour vérifier un venv
check_venv() {
    local dir=$1
    local name=$2
    
    if [ -d "$dir/venv" ]; then
        if [ -f "$dir/venv/bin/activate" ]; then
            echo "✓ $name venv: OK"
            return 0
        else
            echo "⚠ $name venv: incomplet"
            ((WARNINGS++))
            return 1
        fi
    else
        echo "✗ $name venv: manquant"
        ((ERRORS++))
        return 1
    fi
}

echo "[1/10] Vérification des outils système..."
check_command "tor" "Tor"
check_command "proxychains4" "ProxyChains"
check_command "gost" "Gost"
check_command "hping3" "Hping3"
check_command "nginx" "Nginx"
echo ""

echo "[2/10] Vérification des processus..."
# Vérifier Gost (peut tourner via PM2 ou directement)
GOST_RUNNING=false
if pgrep -f "gost -c /etc/gost/gost.conf" > /dev/null; then
    GOST_RUNNING=true
elif command -v pm2 &> /dev/null && pm2 list | grep -q "gost.*online" 2>/dev/null; then
    GOST_RUNNING=true
fi

if [ "$GOST_RUNNING" = true ]; then
    echo "✓ Gost: EN COURS D'EXÉCUTION"
    if command -v pm2 &> /dev/null && pm2 list | grep -q "gost.*online" 2>/dev/null; then
        echo "  → Gost géré par PM2"
    fi
else
    echo "⚠ Gost: NON DÉMARRÉ"
    echo "  → Pour démarrer avec PM2: ./start-spoof-services.sh"
    echo "  → Ou manuellement: nohup gost -c /etc/gost/gost.conf > /var/log/gost.log 2>&1 &"
    ((WARNINGS++))
fi
check_process "tor" "Tor"
echo ""

echo "[3/10] Vérification des répertoires..."
check_directory "/opt/CloudflareSpeedtest" "CloudflareSpeedtest"
check_directory "/opt/slowloris" "Slowloris"
echo ""

echo "[4/10] Vérification des venvs Python..."
check_venv "/opt/CloudflareSpeedtest" "CloudflareSpeedtest"
check_venv "/opt/slowloris" "Slowloris"
echo ""

echo "[5/10] Vérification des wrappers..."
check_command "slowloris" "Wrapper Slowloris"
check_command "cloudflarespeedtest" "Wrapper CloudflareSpeedtest"
echo ""

echo "[6/10] Vérification des configurations..."
if [ -f "/etc/gost/gost.conf" ]; then
    echo "✓ Configuration Gost: OK"
    if grep -q "geo.iproyal.com" /etc/gost/gost.conf 2>/dev/null; then
        echo "  → Proxy configuré dans gost.conf"
    fi
else
    echo "✗ Configuration Gost: manquante"
    ((ERRORS++))
fi

if [ -f "/etc/proxychains.conf" ]; then
    echo "✓ Configuration ProxyChains: OK"
    if grep -q "127.0.0.1:9051" /etc/proxychains.conf 2>/dev/null; then
        echo "  → Tor configuré (port 9051)"
    fi
else
    echo "⚠ Configuration ProxyChains: manquante (utilisera la config par défaut)"
    ((WARNINGS++))
fi
echo ""

echo "[7/10] Test de connexion Tor..."
if systemctl is-active --quiet tor; then
    echo "✓ Service Tor: ACTIF"
    if timeout 5 proxychains4 curl -s https://ifconfig.me > /dev/null 2>&1; then
        IP=$(timeout 5 proxychains4 curl -s https://ifconfig.me 2>/dev/null || echo "timeout")
        if [ "$IP" != "timeout" ] && [ -n "$IP" ]; then
            echo "  → IP via ProxyChains/Tor: $IP"
        else
            echo "  ⚠ Impossible de récupérer l'IP via ProxyChains"
            ((WARNINGS++))
        fi
    else
        echo "  ⚠ ProxyChains ne répond pas correctement"
        ((WARNINGS++))
    fi
else
    echo "⚠ Service Tor: INACTIF"
    ((WARNINGS++))
fi
echo ""

echo "[8/10] Test de Gost..."
GOST_RUNNING=false
if pgrep -f "gost -c /etc/gost/gost.conf" > /dev/null; then
    GOST_RUNNING=true
elif command -v pm2 &> /dev/null && pm2 list | grep -q "gost.*online" 2>/dev/null; then
    GOST_RUNNING=true
fi

if [ "$GOST_RUNNING" = true ]; then
    echo "✓ Gost: EN COURS D'EXÉCUTION"
    if command -v pm2 &> /dev/null && pm2 list | grep -q "gost.*online" 2>/dev/null; then
        echo "  → Gost géré par PM2"
        echo "  → Voir les logs: pm2 logs gost"
    fi
    if [ -f "/var/log/gost.log" ]; then
        echo "  → Logs disponibles: /var/log/gost.log"
        if tail -n 5 /var/log/gost.log 2>/dev/null | grep -q "error\|Error\|ERROR"; then
            echo "  ⚠ Des erreurs détectées dans les logs"
            ((WARNINGS++))
        fi
    fi
else
    echo "⚠ Gost: NON DÉMARRÉ"
    echo "  → Pour démarrer avec PM2: ./start-spoof-services.sh"
    echo "  → Ou manuellement: nohup gost -c /etc/gost/gost.conf > /var/log/gost.log 2>&1 &"
    ((WARNINGS++))
fi
echo ""

echo "[9/10] Test des outils Python..."
if [ -d "/opt/slowloris/venv" ]; then
    cd /opt/slowloris
    if source venv/bin/activate 2>/dev/null && python3 -c "import socket" 2>/dev/null; then
        echo "✓ Slowloris venv: fonctionnel"
        deactivate 2>/dev/null
    else
        echo "⚠ Slowloris venv: problème avec les dépendances"
        ((WARNINGS++))
    fi
    cd - > /dev/null
fi

if [ -d "/opt/CloudflareSpeedtest/venv" ]; then
    cd /opt/CloudflareSpeedtest
    if source venv/bin/activate 2>/dev/null && python3 -c "import cloudscraper" 2>/dev/null; then
        echo "✓ CloudflareSpeedtest venv: fonctionnel"
        deactivate 2>/dev/null
    else
        echo "⚠ CloudflareSpeedtest venv: problème avec les dépendances"
        ((WARNINGS++))
    fi
    cd - > /dev/null
fi
echo ""

echo "[10/10] Test de connectivité réseau..."
if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
    echo "✓ Connectivité Internet: OK"
else
    echo "✗ Connectivité Internet: PROBLÈME"
    ((ERRORS++))
fi
echo ""

echo "=== Résumé ==="
echo ""
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "✅ TOUT EST FONCTIONNEL !"
    echo ""
    echo "Commandes utiles :"
    echo "  - Tester ProxyChains: proxychains4 curl https://ifconfig.me"
    echo "  - Utiliser Slowloris: slowloris target_ip"
    echo "  - Utiliser CloudflareSpeedtest: cloudflarespeedtest -h"
    echo "  - Voir les logs Gost: tail -f /var/log/gost.log"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo "⚠ Installation complète avec $WARNINGS avertissement(s)"
    echo "  → Vérifiez les points d'avertissement ci-dessus"
    exit 0
else
    echo "✗ Installation incomplète: $ERRORS erreur(s), $WARNINGS avertissement(s)"
    echo "  → Relancez ./spoof.sh pour corriger les erreurs"
    exit 1
fi

