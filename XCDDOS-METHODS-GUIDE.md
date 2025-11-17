# Guide complet des méthodes d'attaque - L7-XCDDOS-FLOOD.js

## 📋 Vue d'ensemble

Ce script utilise **HTTP/2** avec **TLS** pour toutes les méthodes. Toutes les attaques passent par des proxies et utilisent la randomisation des headers pour contourner les protections.

---

## 🔥 Méthodes HTTP disponibles

### 1. **GET Attack** ⭐ (Recommandé)

#### Description
Envoie des requêtes HTTP GET massives via HTTP/2. C'est la méthode la plus polyvalente et efficace.

#### Caractéristiques techniques
- **Type** : HTTP/2 GET Request Flood
- **Body** : Aucun (léger)
- **Headers** : Randomisés (User-Agent, Accept, etc.)
- **Path** : Randomisé avec query parameters

#### Pour quels sites/protections ?
✅ **Efficace contre :**
- Sites web classiques (WordPress, Joomla, Drupal)
- Sites e-commerce (Magento, WooCommerce, Shopify)
- Sites statiques (HTML/CSS/JS)
- APIs REST
- Sites avec protection Cloudflare (modérée)
- Sites avec rate limiting basique
- CDN (Cloudflare, Fastly, etc.)

⚠️ **Moins efficace contre :**
- Protection DDoS avancée (AWS Shield, Akamai)
- Rate limiting très strict
- WAF très agressif

#### Serveurs de jeux
✅ **Compatible avec :**
- Serveurs web de jeux (launcher, store, API)
- Sites web de jeux (Steam, Epic Games Store, etc.)
- Serveurs HTTP/HTTPS de jeux
- APIs de jeux en ligne

❌ **Non compatible avec :**
- Serveurs de jeu UDP (Minecraft, CS:GO, etc.)
- Serveurs de jeu TCP brut (sans HTTP)
- Serveurs de jeu avec protocole propriétaire

#### Commande
```bash
node L7-XCDDOS-FLOOD.js https://target.com 60 1000 50 proxies.txt GET
```

#### Puissance recommandée
- **Débutant** : `500 req, 25 threads`
- **Intermédiaire** : `1000 req, 50 threads`
- **Avancé** : `2000 req, 100 threads`

---

### 2. **POST Attack**

#### Description
Envoie des requêtes HTTP POST massives. Génère plus de charge serveur car le serveur doit traiter les requêtes POST.

#### Caractéristiques techniques
- **Type** : HTTP/2 POST Request Flood
- **Body** : Vide (mais méthode POST)
- **Headers** : Randomisés + Content-Type
- **Impact** : Plus élevé que GET (traitement serveur)

#### Pour quels sites/protections ?
✅ **Efficace contre :**
- APIs REST avec endpoints POST
- Formulaires web (login, contact, etc.)
- Sites avec traitement backend lourd
- Applications web (React, Vue, Angular)
- APIs GraphQL
- Webhooks

⚠️ **Moins efficace contre :**
- Protection anti-bot avancée
- Validation CSRF stricte
- Rate limiting sur POST

#### Serveurs de jeux
✅ **Compatible avec :**
- APIs de jeux (authentification, leaderboard)
- Systèmes de login de jeux
- APIs de microtransactions
- Systèmes de matchmaking HTTP

#### Commande
```bash
node L7-XCDDOS-FLOOD.js https://target.com 60 1000 50 proxies.txt POST
```

#### Puissance recommandée
- **Débutant** : `300 req, 20 threads`
- **Intermédiaire** : `800 req, 40 threads`
- **Avancé** : `1500 req, 80 threads`

---

### 3. **HEAD Attack** ⚡ (Léger et rapide)

#### Description
Envoie uniquement les en-têtes HTTP sans body. Très léger et rapide, permet un RPS très élevé.

#### Caractéristiques techniques
- **Type** : HTTP/2 HEAD Request Flood
- **Body** : Aucun (très léger)
- **Bande passante** : Minimale
- **RPS** : Le plus élevé possible

#### Pour quels sites/protections ?
✅ **Efficace contre :**
- Sites avec rate limiting basique
- CDN (Cloudflare, Fastly)
- Serveurs web légers (Nginx, Apache)
- Sites statiques
- APIs avec endpoints HEAD

⚠️ **Moins efficace contre :**
- Protection DDoS avancée
- Rate limiting intelligent
- WAF qui ignore HEAD

#### Serveurs de jeux
✅ **Compatible avec :**
- Serveurs web de jeux
- APIs de vérification
- Health checks HTTP

#### Commande
```bash
node L7-XCDDOS-FLOOD.js https://target.com 60 2000 50 proxies.txt HEAD
```

#### Puissance recommandée
- **Débutant** : `1000 req, 30 threads`
- **Intermédiaire** : `2000 req, 60 threads`
- **Avancé** : `5000 req, 120 threads`

---

### 4. **OPTIONS Attack**

#### Description
Envoie des requêtes OPTIONS (CORS preflight). Génère de la charge sur les serveurs qui gèrent CORS.

#### Caractéristiques techniques
- **Type** : HTTP/2 OPTIONS Request Flood
- **Body** : Aucun
- **Headers** : Access-Control-Request-* headers
- **Impact** : Spécifique aux APIs CORS

#### Pour quels sites/protections ?
✅ **Efficace contre :**
- APIs REST avec CORS
- Applications web cross-origin
- APIs publiques
- Services backend modernes

⚠️ **Moins efficace contre :**
- Sites sans CORS
- Protection anti-CORS
- Rate limiting sur OPTIONS

#### Serveurs de jeux
✅ **Compatible avec :**
- APIs de jeux cross-origin
- APIs publiques de jeux
- Services backend de jeux

#### Commande
```bash
node L7-XCDDOS-FLOOD.js https://target.com 60 1000 50 proxies.txt OPTIONS
```

#### Puissance recommandée
- **Débutant** : `500 req, 25 threads`
- **Intermédiaire** : `1000 req, 50 threads`
- **Avancé** : `2000 req, 100 threads`

---

### 5. **PUT Attack**

#### Description
Envoie des requêtes PUT (upload/modification). Génère une charge importante car le serveur doit traiter les modifications.

#### Caractéristiques techniques
- **Type** : HTTP/2 PUT Request Flood
- **Body** : Vide (mais méthode PUT)
- **Headers** : Content-Type, Content-Length
- **Impact** : Élevé (traitement serveur)

#### Pour quels sites/protections ?
✅ **Efficace contre :**
- APIs REST avec endpoints PUT
- Services de stockage HTTP
- APIs de modification de données
- Services cloud (S3, etc.)

⚠️ **Moins efficace contre :**
- Authentification stricte
- Validation de permissions
- Rate limiting sur PUT

#### Serveurs de jeux
✅ **Compatible avec :**
- APIs de modification de profil
- APIs de sauvegarde
- Services de stockage de jeux

#### Commande
```bash
node L7-XCDDOS-FLOOD.js https://target.com 60 800 40 proxies.txt PUT
```

#### Puissance recommandée
- **Débutant** : `300 req, 20 threads`
- **Intermédiaire** : `800 req, 40 threads`
- **Avancé** : `1500 req, 80 threads`

---

### 6. **DELETE Attack**

#### Description
Envoie des requêtes DELETE. Génère une charge importante car le serveur doit traiter les suppressions.

#### Caractéristiques techniques
- **Type** : HTTP/2 DELETE Request Flood
- **Body** : Aucun
- **Impact** : Très élevé (opération critique)
- **Risque** : Peut être bloqué rapidement

#### Pour quels sites/protections ?
✅ **Efficace contre :**
- APIs REST avec endpoints DELETE
- Services de gestion de données
- APIs CRUD complètes

⚠️ **Moins efficace contre :**
- Authentification stricte (généralement requise)
- Protection anti-suppression
- Rate limiting très strict

#### Serveurs de jeux
⚠️ **Partiellement compatible :**
- APIs de suppression de données
- Services de gestion de compte
- ⚠️ Généralement protégé par authentification

#### Commande
```bash
node L7-XCDDOS-FLOOD.js https://target.com 60 500 30 proxies.txt DELETE
```

#### Puissance recommandée
- **Débutant** : `200 req, 15 threads`
- **Intermédiaire** : `500 req, 30 threads`
- **Avancé** : `1000 req, 60 threads`

---

### 7. **PATCH Attack**

#### Description
Envoie des requêtes PATCH (modification partielle). Similaire à PUT mais pour modifications partielles.

#### Caractéristiques techniques
- **Type** : HTTP/2 PATCH Request Flood
- **Body** : Vide
- **Headers** : Content-Type, Content-Length
- **Impact** : Élevé (traitement serveur)

#### Pour quels sites/protections ?
✅ **Efficace contre :**
- APIs REST modernes
- Services de mise à jour de données
- APIs JSON Patch
- Services backend modernes

⚠️ **Moins efficace contre :**
- Authentification requise
- Validation stricte
- Rate limiting

#### Serveurs de jeux
✅ **Compatible avec :**
- APIs de mise à jour de profil
- APIs de progression
- Services de synchronisation

#### Commande
```bash
node L7-XCDDOS-FLOOD.js https://target.com 60 800 40 proxies.txt PATCH
```

#### Puissance recommandée
- **Débutant** : `300 req, 20 threads`
- **Intermédiaire** : `800 req, 40 threads`
- **Avancé** : `1500 req, 80 threads`

---

### 8. **TRACE Attack**

#### Description
Envoie des requêtes TRACE (debugging). Rarement utilisé, peut contourner certaines protections.

#### Caractéristiques techniques
- **Type** : HTTP/2 TRACE Request Flood
- **Body** : Aucun
- **Impact** : Variable selon le serveur
- **Support** : Peu de serveurs supportent TRACE

#### Pour quels sites/protections ?
⚠️ **Efficacité limitée :**
- Serveurs avec TRACE activé (rare)
- Serveurs de debug
- Tests de sécurité

❌ **Généralement inefficace :**
- La plupart des serveurs désactivent TRACE
- Protection standard

#### Serveurs de jeux
❌ **Généralement non compatible :**
- TRACE rarement activé
- Généralement désactivé par sécurité

#### Commande
```bash
node L7-XCDDOS-FLOOD.js https://target.com 60 1000 50 proxies.txt TRACE
```

#### Puissance recommandée
- **Test uniquement** : `500 req, 25 threads`

---

### 9. **CONNECT Attack**

#### Description
Envoie des requêtes CONNECT (tunnel TCP). Utilisé pour les proxies, peut générer de la charge.

#### Caractéristiques techniques
- **Type** : HTTP/2 CONNECT Request Flood
- **Body** : Aucun
- **Impact** : Variable
- **Support** : Serveurs proxy uniquement

#### Pour quels sites/protections ?
⚠️ **Efficacité limitée :**
- Serveurs proxy HTTP
- Serveurs avec CONNECT activé
- Services de tunneling

❌ **Généralement inefficace :**
- Sites web normaux
- La plupart des serveurs

#### Serveurs de jeux
❌ **Généralement non compatible :**
- CONNECT rarement utilisé
- Spécifique aux proxies

#### Commande
```bash
node L7-XCDDOS-FLOOD.js https://target.com 60 1000 50 proxies.txt CONNECT
```

#### Puissance recommandée
- **Test uniquement** : `500 req, 25 threads`

---

## 🎯 Guide de sélection par type de cible

### Sites web classiques
**Méthode recommandée :** `GET` ou `HEAD`
```bash
node L7-XCDDOS-FLOOD.js https://target.com 60 1000 50 proxies.txt GET
```

### APIs REST
**Méthode recommandée :** `GET`, `POST`, ou `OPTIONS`
```bash
node L7-XCDDOS-FLOOD.js https://api.target.com 60 1000 50 proxies.txt GET
```

### Sites e-commerce
**Méthode recommandée :** `GET` ou `POST`
```bash
node L7-XCDDOS-FLOOD.js https://shop.target.com 60 1500 60 proxies.txt GET
```

### CDN (Cloudflare, etc.)
**Méthode recommandée :** `HEAD` (RPS élevé)
```bash
node L7-XCDDOS-FLOOD.js https://target.com 60 2000 80 proxies.txt HEAD
```

### Applications web modernes
**Méthode recommandée :** `POST` ou `GET`
```bash
node L7-XCDDOS-FLOOD.js https://app.target.com 60 1000 50 proxies.txt POST
```

### Serveurs de jeux (web/API)
**Méthode recommandée :** `GET` ou `POST`
```bash
node L7-XCDDOS-FLOOD.js https://game-api.target.com 60 1000 50 proxies.txt GET
```

---

## 🎮 Serveurs de jeux - Compatibilité détaillée

### ✅ Compatible (HTTP/HTTPS)

#### Serveurs web de jeux
- **Launcher** : Steam, Epic Games, Battle.net
- **Store** : Boutiques de jeux en ligne
- **API** : APIs REST de jeux
- **Site web** : Sites officiels de jeux

**Méthode :** `GET` ou `POST`
```bash
node L7-XCDDOS-FLOOD.js https://store.steampowered.com 60 1000 50 proxies.txt GET
```

#### APIs de jeux
- **Authentification** : Login, tokens
- **Leaderboard** : Classements
- **Profil** : Données de profil
- **Matchmaking** : Systèmes de matchmaking HTTP

**Méthode :** `GET`, `POST`, ou `OPTIONS`
```bash
node L7-XCDDOS-FLOOD.js https://api.game.com/auth 60 1000 50 proxies.txt POST
```

### ❌ Non compatible (UDP/TCP brut)

#### Serveurs de jeu en ligne
- **Minecraft** : UDP/TCP brut
- **CS:GO** : UDP/TCP brut
- **Valorant** : UDP/TCP brut
- **Fortnite** : UDP/TCP brut
- **Tous les FPS** : Généralement UDP/TCP

**Raison :** Ces serveurs utilisent des protocoles propriétaires, pas HTTP/HTTPS.

**Solution :** Utiliser des outils L4 (TCP/UDP flood) au lieu de L7.

---

## 🛡️ Efficacité par type de protection

### Cloudflare (Basic/Pro)
**Méthode :** `GET` ou `HEAD`
**Efficacité :** ⭐⭐⭐ (Modérée)
**Recommandation :** Utiliser rotation de proxies + headers randomisés

### Cloudflare (Business/Enterprise)
**Méthode :** `GET` avec RPS élevé
**Efficacité :** ⭐⭐ (Faible)
**Recommandation :** Nécessite beaucoup de proxies + RPS très élevé

### AWS Shield
**Méthode :** `GET` ou `HEAD`
**Efficacité :** ⭐⭐ (Faible)
**Recommandation :** Très difficile à contourner

### Akamai
**Méthode :** `GET`
**Efficacité :** ⭐⭐ (Faible)
**Recommandation :** Protection très avancée

### Rate Limiting basique
**Méthode :** `HEAD` (RPS élevé)
**Efficacité :** ⭐⭐⭐⭐ (Bonne)
**Recommandation :** Rotation de proxies efficace

### WAF basique
**Méthode :** `GET` avec headers randomisés
**Efficacité :** ⭐⭐⭐ (Modérée)
**Recommandation :** Headers randomisés contournent souvent

### WAF avancé
**Méthode :** `GET`
**Efficacité :** ⭐⭐ (Faible)
**Recommandation :** Difficile à contourner

---

## 📊 Tableau récapitulatif

| Méthode | RPS Max | Impact | Efficacité | Serveurs Jeux |
|---------|---------|--------|------------|---------------|
| **GET** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ✅ Oui |
| **POST** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ✅ Oui |
| **HEAD** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ✅ Oui |
| **OPTIONS** | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ✅ Oui |
| **PUT** | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ✅ Oui |
| **PATCH** | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ✅ Oui |
| **DELETE** | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⚠️ Partiel |
| **TRACE** | ⭐⭐⭐ | ⭐⭐ | ⭐ | ❌ Non |
| **CONNECT** | ⭐⭐ | ⭐⭐ | ⭐ | ❌ Non |

---

## 🎯 Recommandations finales

### Pour débuter
```bash
# Méthode GET, paramètres modérés
node L7-XCDDOS-FLOOD.js https://target.com 60 500 25 proxies.txt GET
```

### Pour attaque efficace
```bash
# Méthode GET, paramètres optimaux
node L7-XCDDOS-FLOOD.js https://target.com 60 1000 50 proxies.txt GET
```

### Pour RPS maximum
```bash
# Méthode HEAD, paramètres élevés
node L7-XCDDOS-FLOOD.js https://target.com 60 2000 80 proxies.txt HEAD
```

### Pour charge serveur maximale
```bash
# Méthode POST, paramètres élevés
node L7-XCDDOS-FLOOD.js https://target.com 60 1500 60 proxies.txt POST
```

---

## ⚠️ Notes importantes

1. **Toutes les méthodes utilisent HTTP/2** : Plus efficace que HTTP/1.1
2. **Toutes passent par des proxies** : Anonymat et distribution
3. **Headers randomisés** : Contourne les protections basiques
4. **TLS/SSL** : Toutes les connexions sont chiffrées
5. **Multi-threading** : Utilise tous les CPU cores disponibles

---

## 🔧 Optimisation

### Pour maximiser l'efficacité :
1. Utiliser plusieurs proxies dans `proxies.txt`
2. Augmenter progressivement `req` et `threads`
3. Tester différentes méthodes (GET, HEAD, POST)
4. Surveiller les ressources système (CPU, RAM, réseau)
5. Adapter selon la réponse de la cible

