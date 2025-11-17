#!/bin/bash

set -euo pipefail

echo "=== Démarrage des services spoof avec PM2 ==="
echo ""

# Vérifier que PM2 est installé
if ! command -v pm2 &> /dev/null; then
    echo "Installation de PM2..."
    if command -v npm &> /dev/null; then
        npm install -g pm2
        echo "✓ PM2 installé via npm"
    elif command -v npx &> /dev/null; then
        echo "⚠ Utilisation de npx pour PM2 (installation temporaire)"
        echo "  → Pour une installation permanente, installez npm"
    else
        echo "✗ npm et npx non disponibles, impossible d'installer PM2"
        exit 1
    fi
fi

# Arrêter les services existants s'ils tournent
pm2 delete gost 2>/dev/null || true
pm2 delete tor-check 2>/dev/null || true

# Démarrer Gost
if [ -f "/etc/gost/gost.conf" ] && command -v gost &> /dev/null; then
    echo "Démarrage de Gost..."
    # Démarrer Gost directement avec PM2
    pm2 start gost --name gost -- -C /etc/gost/gost.conf -L /var/log/gost.log
    sleep 2
    # Vérifier que Gost a démarré correctement
    if pm2 list | grep gost | grep -q "online"; then
        echo "✓ Gost démarré avec PM2"
    else
        echo "⚠ Gost a des problèmes, vérifiez les logs:"
        echo "  → pm2 logs gost"
        echo "  → tail /var/log/gost.log"
    fi
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
echo "Configuration de PM2 pour le démarrage au boot..."
STARTUP_CMD=$(pm2 startup systemd -u root --hp /root 2>/dev/null | grep -E "sudo|env" | tail -1)
if [ -n "$STARTUP_CMD" ]; then
    eval "$STARTUP_CMD" 2>/dev/null || {
        echo "⚠ Impossible de configurer le démarrage automatique"
        echo "  → Exécutez manuellement: pm2 startup"
    }
else
    echo "⚠ Commande de démarrage non trouvée"
    echo "  → Exécutez manuellement: pm2 startup"
fi

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

