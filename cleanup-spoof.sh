#!/bin/bash

set -euo pipefail

echo "=== Nettoyage de l'installation spoof ==="
echo ""

# Arrêt des processus
echo "[1/8] Arrêt des processus..."
pkill -f "gost -c /etc/gost/gost.conf" 2>/dev/null || true
systemctl stop tor 2>/dev/null || true
echo "✓ Processus arrêtés"
echo ""

# Suppression des répertoires clonés
echo "[2/8] Suppression des répertoires clonés..."
rm -rf /opt/proxychains 2>/dev/null || true
rm -rf /opt/gost 2>/dev/null || true
rm -rf /opt/CloudflareSpeedtest 2>/dev/null || true
rm -rf /opt/slowloris 2>/dev/null || true
rm -rf proxychains 2>/dev/null || true
rm -rf gost 2>/dev/null || true
rm -rf CloudflareSpeedtest 2>/dev/null || true
rm -rf slowloris 2>/dev/null || true
echo "✓ Répertoires clonés supprimés"
echo ""

# Suppression des fichiers téléchargés
echo "[3/8] Suppression des fichiers téléchargés..."
rm -f /opt/go*.tar.gz 2>/dev/null || true
rm -f /opt/ubooquity.jar 2>/dev/null || true
rm -f go*.tar.gz 2>/dev/null || true
rm -f ubooquity.jar 2>/dev/null || true
echo "✓ Fichiers téléchargés supprimés"
echo ""

# Suppression des binaires installés
echo "[4/8] Suppression des binaires installés..."
rm -f /usr/local/bin/gost 2>/dev/null || true
rm -f /usr/bin/proxychains4 2>/dev/null || true
rm -f /usr/bin/proxychains 2>/dev/null || true
rm -f /usr/bin/proxyresolv 2>/dev/null || true
rm -f /usr/lib/libproxychains.so.4 2>/dev/null || true
rm -f /usr/local/bin/start_attacks.sh 2>/dev/null || true
echo "✓ Binaires supprimés"
echo ""

# Suppression des configurations personnalisées
echo "[5/8] Suppression des configurations personnalisées..."
rm -rf /etc/gost 2>/dev/null || true
if [ -f /etc/proxychains.conf ]; then
    echo "⚠ /etc/proxychains.conf existe - sauvegarde avant suppression"
    cp /etc/proxychains.conf /etc/proxychains.conf.backup 2>/dev/null || true
fi
rm -f /etc/proxychains.conf 2>/dev/null || true
if [ -f /etc/tor/torrc ]; then
    echo "⚠ /etc/tor/torrc existe - sauvegarde avant suppression"
    cp /etc/tor/torrc /etc/tor/torrc.backup 2>/dev/null || true
fi
rm -f /etc/tor/torrc 2>/dev/null || true
echo "✓ Configurations supprimées (sauvegardes créées si nécessaire)"
echo ""

# Suppression de Go
echo "[6/8] Suppression de Go..."
if [ -d "/usr/local/go" ]; then
    rm -rf /usr/local/go
    echo "✓ Go supprimé"
else
    echo "✓ Go n'était pas installé"
fi
echo ""

# Nettoyage du cache Go
echo "[7/8] Nettoyage du cache Go..."
if [ -d "$HOME/go" ]; then
    rm -rf "$HOME/go" 2>/dev/null || true
    echo "✓ Cache Go supprimé"
else
    echo "✓ Cache Go n'existait pas"
fi
echo ""

# Suppression des répertoires d'installation
echo "[8/8] Suppression des répertoires d'installation..."
rm -rf /opt/ubooquity 2>/dev/null || true
echo "✓ Répertoires d'installation supprimés"
echo ""

# Suppression des logs
echo "[Bonus] Suppression des logs..."
rm -f /var/log/gost.log 2>/dev/null || true
echo "✓ Logs supprimés"
echo ""

echo "=== Nettoyage terminé ==="
echo ""
echo "Les packages système (tor, nginx, hping3, etc.) n'ont PAS été désinstallés."
echo "Pour les désinstaller, exécutez :"
echo "  apt remove --purge tor nginx hping3 -y"
echo ""
echo "Les packages Python (cloudscraper, etc.) n'ont PAS été désinstallés."
echo "Pour les désinstaller, exécutez :"
echo "  pip3 uninstall cloudscraper requests requests-toolbelt -y"
echo ""
echo "Vous pouvez maintenant relancer ./spoof.sh pour une installation propre."

