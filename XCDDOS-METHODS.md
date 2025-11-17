# Méthodes d'attaque du script L7-XCDDOS-FLOOD.js

## Vue d'ensemble
Script d'attaque Layer 7 (HTTP/2) utilisant plusieurs techniques avancées pour contourner les protections et maximiser l'impact.

---

## 🔥 Méthodes principales d'attaque

### 1. **HTTP/2 Flood Attack**
- **Type** : Layer 7 (Application Layer)
- **Protocole** : HTTP/2 via TLS
- **Mécanisme** : Envoi massif de requêtes HTTP/2 avec multiplexing
- **Caractéristiques** :
  - Utilise le module natif `http2` de Node.js
  - Multiplexing de requêtes sur une seule connexion TCP
  - Window size optimisé : `initialWindowSize: 6291456` (6 MB)
  - Frame size : `maxFrameSize: 16384` (16 KB)

### 2. **TLS/SSL Handshake Manipulation**
- **Cipher Suites Rotation** : 40+ suites de chiffrement différentes
- **Signature Algorithms** : Rotation de 9 algorithmes différents
  - `ecdsa_secp256r1_sha256`
  - `ecdsa_secp384r1_sha384`
  - `ecdsa_secp521r1_sha512`
  - `rsa_pss_rsae_sha256/384/512`
  - `rsa_pkcs1_sha256/384/512`
- **ECDH Curves** : `GREASE:X25519:x25519:P-256:P-384:P-521:X448`
- **ALPN Protocol** : Négociation forcée de HTTP/2 (`["h2"]`)
- **Secure Options** : Désactivation de SSLv2, SSLv3, TLSv1, TLSv1.1, TLSv1.3

### 3. **Proxy Rotation & Chaining**
- **Type** : HTTP CONNECT Proxy
- **Mécanisme** : Rotation aléatoire parmi une liste de proxies
- **Format proxy** : `IP:PORT` (fichier `proxy.txt`)
- **Méthode** : CONNECT tunnel pour HTTPS
- **Keep-Alive** : Connexions maintenues 600 secondes
- **Timeout** : 25 secondes par proxy

### 4. **Header Randomization & Spoofing**

#### Headers HTTP/2 randomisés :
- **Accept** : 5 variantes différentes (text/html, image/webp, etc.)
- **Accept-Language** : 130+ langues différentes
- **Accept-Encoding** : 4 variantes (gzip, deflate, br, compress)
- **Cache-Control** : 10 variantes différentes
- **User-Agent** : Génération dynamique avec :
  - OS randomisé (Windows 1.01 à Windows 10)
  - Architecture randomisée (x86-16, x86_64, ARM, etc.)
  - Build numbers aléatoires
  - Version Edge randomisée

#### Headers spéciaux :
- **Sec-Fetch-Mode** : navigate, same-origin, no-cors, cors
- **Sec-Fetch-Site** : same-origin, same-site, cross-site, none
- **Sec-Fetch-Dest** : document, sharedworker, subresource, unknown, worker
- **NEL (Network Error Logging)** : JSON randomisé
- **A-IM** : Feed
- **Accept-Range** : bytes/none
- **Delta-Base** : 12340001
- **te** : trailers
- **source-ip** : IP aléatoire générée

### 5. **Multi-threading avec Cluster**
- **Module** : Node.js `cluster`
- **Mécanisme** : Fork de processus enfants
- **Avantage** : Utilisation de tous les CPU cores
- **Paramètre** : `threads` (nombre de workers)

### 6. **Connection Management**
- **Keep-Alive** : 600 000 ms (10 minutes)
- **NoDelay** : TCP_NODELAY activé
- **Half-Open** : Connexions TCP half-open autorisées
- **Max Listeners** : Illimité (`setMaxListeners(0)`)
- **Timeout** : 600 000 ms par connexion

### 7. **HTTP/2 Settings Manipulation**
- **Header Table Size** : 65536 bytes
- **Initial Window Size** : 6291456 bytes (6 MB) - **TRÈS ÉLEVÉ**
- **Max Frame Size** : 16384 bytes (16 KB)
- **Enable Push** : Désactivé
- **Weight** : 241 (priorité élevée)
- **Exclusive** : true (priorité exclusive)

### 8. **Request Rate Control**
- **Interval** : 500ms entre chaque batch
- **Rate** : Nombre de requêtes par interval
- **Threads** : Multiplié par le nombre de workers
- **Formule** : `Total RPS = (Rate / 0.5) * Threads`

### 9. **Path Randomization**
- **Query Parameters** : Génération aléatoire
- **Format** : `?[3 chars]=[10-25 chars]`
- **Exemple** : `?abc=KjH8mN2pQ9wX`

### 10. **Fingerprint Evasion**
- **JA3 Fingerprint** : Rotation de 22 fingerprints différents
- **TLS Fingerprint** : Rotation via cipher suites
- **HTTP/2 Fingerprint** : Settings personnalisés
- **Browser Fingerprint** : User-Agent + Headers réalistes

---

## 📊 Caractéristiques techniques

### Performance
- **Concurrent Connections** : Illimité (max listeners = 0)
- **Connection Pooling** : Via proxies
- **Memory Management** : Destruction immédiate après réponse
- **Error Handling** : Silencieux (pas de logs d'erreur)

### Bypass Techniques
1. **Cloudflare** : Headers Sec-Fetch-* réalistes
2. **Rate Limiting** : Rotation de proxies + headers
3. **WAF** : User-Agent + TLS fingerprint rotation
4. **DDoS Protection** : Distribution via proxies

---

## 🎯 Méthodes HTTP supportées

Le script accepte n'importe quelle méthode HTTP via le paramètre `data` :
- **GET** : Requêtes GET standard
- **POST** : Requêtes POST (sans body)
- **HEAD** : Requêtes HEAD
- **OPTIONS** : Requêtes OPTIONS
- **Etc.** : Toute méthode HTTP valide

---

## ⚙️ Paramètres d'exécution

```bash
node L7-XCDDOS-FLOOD.js <host> <time> <req> <thread> <proxy.txt> <data>
```

- **host** : URL cible (https://example.com)
- **time** : Durée en secondes
- **req** : Taux de requêtes par interval (500ms)
- **thread** : Nombre de workers (CPU cores)
- **proxy.txt** : Fichier avec proxies (IP:PORT)
- **data** : Méthode HTTP (GET, POST, etc.)

---

## 🔒 Sécurité & Anonymat

- ✅ Rotation de proxies
- ✅ Fingerprint rotation
- ✅ Headers randomisés
- ✅ TLS cipher rotation
- ✅ User-Agent spoofing
- ✅ Source IP masquée

---

## 📈 Calcul de la puissance

**Exemple avec 50 threads, 1000 req/interval :**
- Requêtes par seconde : `(1000 / 0.5) * 50 = 100,000 RPS`
- Connexions simultanées : `50 threads * proxies disponibles`
- Bande passante : Variable selon la taille des réponses

---

## ⚠️ Limitations

- Nécessite un fichier de proxies valide
- Consommation mémoire élevée (cluster)
- Nécessite Node.js 12+ (pour http2 natif)
- Dépend de la qualité des proxies

