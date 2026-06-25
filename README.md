# EtuSmart 🎓

> Plateforme SaaS de gestion étudiante — Bénin & Afrique francophone

[![CI](https://github.com/TonOrganisation/etusmart/actions/workflows/ci.yml/badge.svg)](https://github.com/TonOrganisation/etusmart/actions)

---

## 📋 Description

EtuSmart est une application web progressive (PWA) combinant :
- 💰 **Gestion budgétaire** intelligente avec visualisation et alertes
- 📚 **Bibliothèque académique** collaborative (PDF, cours, annales)
- 🤖 **Assistant IA** local (Ollama + Mistral 7B) en français

**Modèle** : SaaS Freemium — Paiement MTN MoMo & Stripe

---

## 🏗 Architecture

```
etusmart/
├── .github/workflows/    # CI/CD GitHub Actions
├── backend/
│   └── api-gateway/      # Point d'entrée API (Express.js)
├── frontend/             # React + Vite (PWA)
├── docker/
│   ├── postgres/         # init.sql (schéma BDD)
│   └── nginx/            # Reverse proxy config
├── docker-compose.yml    # Stack complète (dev)
├── .env.example          # Template des variables d'env
└── README.md
```

**Stack** : React · Node.js · PostgreSQL · Redis · MinIO · Ollama · Docker · Nginx

---

## 🚀 Démarrage rapide (Dev)

### Prérequis
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) 24+
- [Git](https://git-scm.com/)
- Node.js 20+ (optionnel, pour dev local hors Docker)

### 1. Cloner et configurer

```bash
git clone https://github.com/TonOrganisation/etusmart.git
cd etusmart

# Copier et compléter les variables d'environnement
cp .env.example .env
# Éditer .env avec vos vraies valeurs (secrets, clés API...)
```

### 2. Lancer l'infrastructure

```bash
docker compose up -d
```

### 3. Vérifier les services

| Service       | URL                          | Usage              |
|---------------|------------------------------|--------------------|
| Application   | http://localhost              | Frontend React     |
| API Gateway   | http://localhost:4000/health  | Santé de l'API     |
| MinIO Console | http://localhost:9001         | Gestion fichiers   |
| PostgreSQL    | localhost:5432                | Base de données    |
| Ollama        | http://localhost:11434        | LLM local          |

### 4. Arrêter

```bash
docker compose down          # Arrête les conteneurs
docker compose down -v       # Arrête + supprime les volumes
```

---

## 📦 Pull du modèle IA (Ollama)

Le modèle Mistral est automatiquement téléchargé au premier démarrage via `ollama-init`.
Pour le faire manuellement :

```bash
docker exec -it etusmart_ollama ollama pull mistral
```

> ⚠️ Le téléchargement est ~4 Go. Patience selon votre connexion.

---

## 🔒 Sécurité

- **Jamais de secrets dans le code** — tout passe par `.env` (non commité)
- JWT avec algorithme HS256 forcé, expiration courte (15 min) + refresh token
- Mots de passe hachés avec bcrypt
- Rate limiting sur tous les endpoints
- CORS strict (origines définies dans `.env`)
- Headers sécurité via Helmet (CSP, X-Frame-Options, nosniff…)
- Principe de moindre privilège : utilisateur BDD `etusmart_app` (pas root)

---

## 📅 Planning MVP

| Phase | Description              | Durée     |
|-------|--------------------------|-----------|
| P1    | ✅ Cadrage & Architecture | 1 sem     |
| P2    | ✅ Setup infrastructure   | 1 sem     |
| P3    | Auth & Users             | 1 sem     |
| P4    | Backend Dépenses         | 1 sem     |
| P5    | Backend Bibliothèque     | 1 sem     |
| P6    | Backend IA Service       | 1 sem     |
| P7    | Paiement MoMo + Stripe   | 3 jours   |
| P8    | Frontend Design System   | 4 jours   |
| P9    | Frontend Modules         | 2 sem     |
| P10   | Tests & QA               | 1 sem     |
| P11   | Déploiement VPS          | 3 jours   |

---

## 👤 Auteur

**TCHIDEHOU Dodji Virgile** — Cotonou, Bénin  
tchidehoudodjivirgile@gmail.com

---

*EtuSmart — Apprendre mieux, dépenser intelligemment.*
