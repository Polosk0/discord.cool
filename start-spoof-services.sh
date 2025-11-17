#!/bin/bash

set -euo pipefail

echo "=== Démarrage des services spoof avec PM2 ==="
echo ""

# Vérifier que PM2 est installé
if ! command -v pm2 &> /dev/null; then
    echo "Installation de PM2..."
    npm install -g pm2
    echo "✓ PM2 installé"
fi

# Arrêter les services existants s'ils tournent
pm2 delete gost 2>/dev/null || true
pm2 delete tor-check 2>/dev/null || true

# Démarrer Gost
if [ -f "/etc/gost/gost.conf" ] && command -v gost &> /dev/null; then
    echo "Démarrage de Gost..."
    pm2 start gost --name gost -- -c /etc/gost/gost.conf -L /var/log/gost.log
    echo "✓ Gost démarré avec PM2"
else
    echo "⚠ Gost non configuré, ignoré"
fi

# Vérifier que Tor est actif (via systemd)
echo "Vérification de Tor..."
if systemctl is-active --quiet tor; then
    echo "✓ Tor est actif (systemd)"
else
    echo "⚠ Tor n'est pas actif, démarrage..."
    systemctl start tor
    systemctl enable tor
    echo "✓ Tor démarré"
fi

# Script de monitoring pour vérifier que Tor reste actif
cat <<'EOF' > /tmp/tor-check.sh
#!/bin/bash
while true; do
    if ! systemctl is-active --quiet tor; then
        systemctl start tor
        echo "$(date): Tor redémarré" >> /var/log/tor-check.log
    fi
    sleep 30
done
EOF
chmod +x /tmp/tor-check.sh

# Démarrer le monitoring Tor avec PM2
echo "Démarrage du monitoring Tor..."
pm2 start /tmp/tor-check.sh --name tor-check --no-autorestart
echo "✓ Monitoring Tor démarré"

# Sauvegarder la configuration PM2
pm2 save

# Configurer PM2 pour démarrer au boot
pm2 startup | grep -v "PM2" | bash || true

echo ""
echo "=== Services démarrés ==="
echo ""
pm2 list
echo ""
echo "Commandes utiles :"
echo "  - Voir les logs: pm2 logs"
echo "  - Voir les logs Gost: pm2 logs gost"
echo "  - Redémarrer Gost: pm2 restart gost"
echo "  - Arrêter tous les services: pm2 stop all"
echo "  - Voir le statut: pm2 status"
echo "  - Sauvegarder: pm2 save"

