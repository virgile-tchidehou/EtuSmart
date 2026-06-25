# EtuSmart
## Plateforme SaaS de Gestion Étudiante

**CAHIER DES CHARGES TECHNIQUE**

Version 1.0 — Juin 2026

**Auteur :** TCHIDEHOU Dodji Virgile
Bénin — Cotonou
tchidehoudodjivirgile@gmail.com

---

## Table des matières

1. [Introduction et Contexte](#1-introduction-et-contexte)
2. [Présentation du Produit](#2-présentation-du-produit)
3. [Spécifications Fonctionnelles](#3-spécifications-fonctionnelles)
4. [Exigences Fonctionnelles et Non Fonctionnelles](#4-exigences-fonctionnelles-et-non-fonctionnelles)
5. [Architecture Technique](#5-architecture-technique)
6. [Modélisation des Données](#6-modélisation-des-données)
7. [Interface Utilisateur](#7-interface-utilisateur)
8. [Planning de Développement](#8-planning-de-développement)
9. [Perspectives d'Évolution (Post-MVP)](#9-perspectives-dévolution-post-mvp)
10. [Conclusion](#10-conclusion)

---

## 1. Introduction et Contexte

### 1.1 Contexte

La vie étudiante en Afrique subsaharienne, et particulièrement au Bénin, est marquée par plusieurs défis structurels persistants :

- **Une gestion budgétaire difficile :** la majorité des étudiants vit avec des ressources limitées et irrégulières, sans outils adaptés pour planifier leurs dépenses.
- **Un accès fragmenté aux ressources pédagogiques :** les supports de cours circulent via des canaux informels (WhatsApp, clés USB), sans organisation, sans indexation et sans garantie de fiabilité.
- **Un déficit d'outils numériques locaux :** les solutions existantes (apps budgétaires ou plateformes LMS) sont généralement conçues pour des contextes occidentaux et inadaptées aux réalités locales (prix, langues, connectivité).

EtuSmart naît de ce constat pour proposer une solution pensée et construite pour les étudiants béninois, avec une ambition d'extension à l'Afrique francophone.

### 1.2 Objectifs du projet

EtuSmart est une plateforme SaaS (Software as a Service) à destination des étudiants. Elle poursuit trois objectifs principaux :

1. Outiller l'étudiant dans sa gestion financière quotidienne via un module de suivi de dépenses intelligent.
2. Centraliser et organiser les ressources académiques (cours, annales, fiches) dans un espace collaboratif structuré.
3. Intégrer une intelligence artificielle locale (via Ollama) capable d'assister l'étudiant, d'analyser ses comportements financiers et de recommander des ressources pertinentes.

### 1.3 Périmètre du document

Ce cahier des charges couvre l'ensemble des spécifications fonctionnelles, techniques et organisationnelles nécessaires au développement de la version V1 (MVP) du produit EtuSmart, à déployer initialement au Bénin.

---

## 2. Présentation du Produit

### 2.1 Description générale

EtuSmart est une application web et mobile progressive (PWA) qui combine en un seul écosystème numérique :

- Un tracker de dépenses personnelles avec catégorisation, visualisation et alertes budgétaires.
- Une bibliothèque académique collaborative permettant le dépôt, la recherche et le téléchargement de documents pédagogiques.
- Un assistant IA local intégré, alimenté par un modèle LLM open source déployé via Ollama, fournissant analyse financière, recommandations de ressources et assistance générale à l'étudiant.

Le produit adopte un modèle freemium : un plan gratuit couvre les fonctionnalités essentielles ; des plans payants (Basic et Premium) débloquent des capacités avancées (IA illimitée, espace de stockage étendu, analytics détaillés).

### 2.2 Public cible

| Segment | Taille estimée | Besoins principaux |
|---|---|---|
| Étudiants universitaires (L1–Master) | ~80 000 au Bénin | Budget, cours, annales |
| Élèves en formation technique/professionnelle | ~30 000 au Bénin | Organisation, ressources techniques |
| Répétiteurs / tuteurs | ~5 000 au Bénin | Partage de contenus, visibilité |

### 2.3 Modèle économique (Freemium)

| Fonctionnalité | Gratuit | Basic (~500 FCFA/mois) | Premium (~1500 FCFA/mois) |
|---|---|---|---|
| Suivi dépenses | ✔ (50 entrées/mois) | ✔ Illimité | ✔ Illimité |
| Bibliothèque académique | ✔ Lecture seule | ✔ Upload (500 Mo) | ✔ Upload (5 Go) |
| Assistant IA | 5 requêtes/jour | 50 requêtes/jour | ✔ Illimité |
| Analytics financiers | ✘ | Basique | ✔ Avancé + export |
| Export PDF / Excel | ✘ | ✔ | ✔ |
| Paiement mobile (MTN MoMo) | — | ✔ | ✔ |

---

## 3. Spécifications Fonctionnelles

### 3.1 Module — Gestion des dépenses

#### 3.1.1 Saisie et catégorisation

- Ajouter une dépense : montant (FCFA), catégorie, description, date, mode de paiement (MoMo, Carte bancaire).
- Catégories prédéfinies : Alimentation, Transport, Scolarité, Crédit téléphonique, Santé, Loisirs, Autre.
- Catégories personnalisées (plan Basic et Premium).
- Saisie rapide via widget depuis le tableau de bord.
- Import CSV (plan Premium).

#### 3.1.2 Visualisation et reporting

- Vue journalière / hebdomadaire / mensuelle avec graphiques (barres, camembert).
- Comparaison mois N vs mois N-1.
- Solde budgétaire en temps réel (budget alloué vs dépenses réelles).
- Alertes push lorsque le budget est atteint à 80% et à 100%.
- Export des données en PDF et Excel (plan Basic et Premium).

#### 3.1.3 Budget prévisionnel

- Définir un budget mensuel global et par catégorie.
- Recevoir des suggestions de rééquilibrage générées par l'IA.

### 3.2 Module — Bibliothèque académique

#### 3.2.1 Dépôt et gestion de documents

- Upload de fichiers PDF (max 50 Mo par fichier).
- Métadonnées obligatoires : titre, matière, niveau (L1/L2/L3/Master/Technique), établissement, type (cours / TD / annale / fiche).
- Versioning simple : possibilité de soumettre une révision d'un document existant.
- Modération manuelle ou par IA avant publication (signalement de contenus non conformes).

#### 3.2.2 Recherche et accès

- Recherche full-text par titre, matière, niveau, établissement.
- Filtres combinables (matière + niveau + type + date).
- Prévisualisation PDF inline sans téléchargement.
- Téléchargement direct (plan gratuit limité à 10 téléchargements/jour).
- Système de notation et de commentaires (1–5 étoiles + avis texte).

#### 3.2.3 Espaces communautaires

- Collections privées : l'étudiant organise ses favoris dans des dossiers personnels.
- Partage de collection entre utilisateurs (plan Premium).

### 3.3 Module — Intelligence Artificielle (Ollama)

#### 3.3.1 Assistant conversationnel

- Chat en langage naturel (français) intégré à l'application.
- Contexte utilisateur injecté automatiquement : dépenses récentes, ressources consultées, profil.
- Exemples de requêtes : *"Comment réduire mes dépenses ce mois ?"*, *"Trouve-moi un cours de thermodynamique L2."*, *"Résume ce document."*
- Historique des conversations persistant par session.

#### 3.3.2 Analyse financière intelligente

- Détection automatique d'anomalies de dépenses (pics inhabituels).
- Génération d'un rapport hebdomadaire synthétique envoyé par notification.
- Prédiction du solde budgétaire en fin de mois basée sur les habitudes passées.
- Score financier mensuel de l'étudiant (0–100) avec conseils ciblés.

#### 3.3.3 Recommandation de ressources

- Suggestion de documents selon le profil académique de l'étudiant (matières, niveau, historique de consultation).
- Mise en avant de documents récents et bien notés dans la filière de l'utilisateur.
- Résumé automatique d'un document PDF uploadé (extraction de points clés).

#### 3.3.4 Modèle LLM — Stack Ollama

L'IA sera déployée en self-hosted sur le serveur de l'application via Ollama. Le modèle retenu pour la V1 est **Mistral 7B** (ou LLaMA 3.1 8B selon les performances mesurées). L'intégration se fait via l'API REST exposée par Ollama sur le réseau interne du serveur.

- Endpoint principal : `http://localhost:11434/api/generate`
- Langue de traitement : français (prompt système en français).
- Streaming des réponses activé pour une expérience fluide.
- Fallback : si le modèle est surchargé, réponse en file d'attente avec indicateur visuel.

---

## 4. Exigences Fonctionnelles et Non Fonctionnelles

### 4.1 Exigences fonctionnelles

| ID | Exigence | Priorité | Module |
|---|---|---|---|
| EF-01 | L'utilisateur doit pouvoir créer un compte via email ou Google OAuth. | CRITIQUE | Auth |
| EF-02 | L'utilisateur doit pouvoir ajouter, modifier et supprimer une dépense. | CRITIQUE | Dépenses |
| EF-03 | Le système doit afficher des graphiques de dépenses (jour/semaine/mois). | HAUTE | Dépenses |
| EF-04 | L'utilisateur doit pouvoir définir un budget mensuel par catégorie. | HAUTE | Dépenses |
| EF-05 | L'utilisateur doit recevoir une alerte quand son budget est atteint à 80%. | HAUTE | Dépenses |
| EF-06 | L'utilisateur doit pouvoir uploader un document PDF avec métadonnées. | CRITIQUE | Bibliothèque |
| EF-07 | Le système doit permettre la recherche de documents par filtre combiné. | CRITIQUE | Bibliothèque |
| EF-08 | L'utilisateur doit pouvoir prévisualiser un document sans téléchargement. | MOYENNE | Bibliothèque |
| EF-09 | L'IA doit répondre aux questions en français dans un chat contextuel. | HAUTE | IA |
| EF-10 | L'IA doit produire un rapport financier hebdomadaire automatique. | HAUTE | IA |
| EF-11 | L'IA doit recommander des ressources selon le profil de l'étudiant. | MOYENNE | IA |
| EF-12 | Le paiement MTN MoMo doit permettre de souscrire à un plan payant. | HAUTE | Paiement |
| EF-13 | L'utilisateur peut exporter ses dépenses en PDF ou Excel. | BASSE | Dépenses |

### 4.2 Exigences non fonctionnelles

| Catégorie | Spécification |
|---|---|
| **Performance** | Temps de chargement des pages < 3s sur connexion 3G. Réponse IA < 10s. |
| **Disponibilité** | Uptime cible : 99,5% (hors maintenance planifiée). |
| **Sécurité** | Authentification JWT. Chiffrement TLS/HTTPS. Hachage des mots de passe (bcrypt). Isolation des données par utilisateur. |
| **Responsive / PWA** | Interface adaptée mobile (320px–768px) et desktop. Installable comme PWA sur Android et iOS. |
| **Accessibilité** | Interface en français. Conforme aux contrastes WCAG AA. Support des connexions lentes (lazy loading). |
| **Scalabilité** | Architecture containerisée (Docker) permettant la montée en charge horizontale. |
| **Conformité** | Respect des règles RGPD-like : consentement, suppression de compte et données sur demande. |
| **Maintenabilité** | Code documenté, tests unitaires couvrant > 70% du code métier, CI/CD avec GitHub Actions. |

---

## 5. Architecture Technique

### 5.1 Vue d'ensemble

EtuSmart suit une architecture en couches découplées, s'appuyant sur une API REST centrale consommée par le frontend et par les services IA. Le modèle LLM est hébergé localement sur le même serveur via Ollama pour éviter les coûts d'API cloud et garantir la confidentialité des données.

### 5.2 Stack technique

| Couche | Technologie choisie | Justification |
|---|---|---|
| Frontend | React.js (Vite) + TailwindCSS | Rapidité de dev, PWA-compatible, riche écosystème. |
| Backend API | Node.js + Express.js | Non-bloquant, adapté aux I/O multiples, JS full-stack. |
| Base de données | PostgreSQL | Relationnelle, robuste, support JSON, open source. |
| Stockage fichiers | MinIO (self-hosted S3-compatible) | Stockage des PDF sans dépendance AWS. |
| IA / LLM | Ollama + Mistral 7B (ou LLaMA 3.1 8B) | Open source, local, pas de coûts d'API, vie privée. |
| Cache | Redis | Sessions, rate limiting, file d'attente IA. |
| Paiement | MTN MoMo API (Bénin) + Stripe | Adapté au marché local, largement utilisé. |
| Auth | JWT + OAuth2 (Google) | Sécurisé, standards industry. |
| Containerisation | Docker + Docker Compose | Déploiement reproductible et scalable. |
| CI/CD | GitHub Actions | Automatisation tests et déploiement. |
| Hébergement | VPS Linux (Ubuntu 22.04) | Contrôle total, coût maîtrisé. |

### 5.3 Architecture des services

L'application est structurée en microservices légers communiquant via HTTP interne :

- **api-gateway** : point d'entrée unique, routing, rate limiting, auth middleware.
- **users-service** : gestion des comptes, profils, abonnements.
- **expenses-service** : CRUD dépenses, budget, export.
- **library-service** : upload, recherche, métadonnées documents.
- **ai-service** : proxy vers Ollama, injection de contexte utilisateur, historique de chat.
- **notification-service** : alertes push, emails hebdomadaires (Nodemailer + Web Push).
- **payment-service** : intégration MTN MoMo API + Stripe, gestion des plans.

### 5.4 Flux d'intégration IA

Lorsqu'un utilisateur envoie une requête à l'assistant :

1. Le frontend envoie la requête au `ai-service` via l'API Gateway.
2. Le `ai-service` récupère le contexte utilisateur (dépenses récentes, profil, historique chat) depuis Redis et PostgreSQL.
3. Il construit un prompt enrichi et l'envoie à Ollama (`localhost:11434`) en streaming.
4. La réponse est streamée en temps réel au client via Server-Sent Events (SSE).
5. L'historique est sauvegardé en base pour continuité de conversation.

---

## 6. Modélisation des Données

### 6.1 Schéma principal (PostgreSQL)

#### Table : `users`

| Champ | Type | Contrainte | Description |
|---|---|---|---|
| id | UUID | PK | Identifiant unique |
| nom | VARCHAR(100) | NOT NULL | Nom complet |
| email | VARCHAR(255) | UNIQUE NOT NULL | Email de connexion |
| mot_de_passe | VARCHAR(255) | NOT NULL | Hash bcrypt |
| plan | ENUM | NOT NULL | free \| basic \| premium |
| etablissement | VARCHAR(200) | NULL | Université ou école |
| niveau | VARCHAR(20) | NULL | L1, L2, L3, Master... |
| filiere | VARCHAR(100) | NULL | Domaine d'études |
| created_at | TIMESTAMP | DEFAULT NOW() | Date de création |
| updated_at | TIMESTAMP | DEFAULT NOW() | Dernière modification |

#### Table : `depenses`

| Champ | Type | Contrainte | Description |
|---|---|---|---|
| id | UUID | PK | Identifiant unique |
| user_id | UUID | FK → users.id | Propriétaire |
| montant | DECIMAL(10,0) | NOT NULL | Montant en FCFA |
| categorie | VARCHAR(50) | NOT NULL | Catégorie de dépense |
| description | TEXT | NULL | Détail optionnel |
| mode_paiement | ENUM | NOT NULL | momo \| carte |
| date_depense | DATE | NOT NULL | Date de la dépense |
| created_at | TIMESTAMP | DEFAULT NOW() | Date de saisie |

#### Table : `documents`

| Champ | Type | Contrainte | Description |
|---|---|---|---|
| id | UUID | PK | Identifiant unique |
| user_id | UUID | FK → users.id | Auteur / uploader |
| titre | VARCHAR(300) | NOT NULL | Titre du document |
| matiere | VARCHAR(100) | NOT NULL | Matière concernée |
| niveau | VARCHAR(20) | NOT NULL | L1, L2, L3, Master... |
| type_doc | ENUM | NOT NULL | cours \| td \| annale \| fiche |
| etablissement | VARCHAR(200) | NULL | Établissement source |
| fichier_url | VARCHAR(500) | NOT NULL | URL MinIO du fichier |
| taille_octets | BIGINT | NOT NULL | Taille du fichier |
| statut | ENUM | NOT NULL | pending \| approved \| rejected |
| note_moyenne | DECIMAL(3,2) | DEFAULT 0 | Note moyenne (0–5) |
| nb_telechargements | INTEGER | DEFAULT 0 | Compteur de DL |
| created_at | TIMESTAMP | DEFAULT NOW() | Date d'upload |

#### Tables complémentaires

Les tables suivantes complètent le schéma :

- **budgets** : `(id, user_id, categorie, montant_alloue, mois)` — budgets prévisionnels.
- **ai_conversations** : `(id, user_id, role, contenu, created_at)` — historique des chats IA.
- **abonnements** : `(id, user_id, plan, debut, fin, statut_paiement, reference_momo)` — gestion SaaS.
- **evaluations_doc** : `(id, user_id, document_id, note, commentaire)` — avis sur les documents.

---

## 7. Interface Utilisateur

### 7.1 Principes de design

- Design system cohérent basé sur TailwindCSS avec une palette centrée sur le bleu/teal et l'or.
- Mobile-first : toutes les vues conçues pour mobile avant desktop.
- Navigation principale par barre inférieure (mobile) / sidebar (desktop).
- Thème sombre optionnel.
- Chargement progressif (skeleton loaders) pour connexions lentes.

### 7.2 Pages et vues principales

| Page / Vue | Contenu et fonctionnalités |
|---|---|
| **Onboarding** | Présentation des 3 modules, saisie du profil (filière, niveau, établissement), configuration du budget initial. |
| **Dashboard** | Solde budgétaire du mois, dernières dépenses, documents récents, score IA du mois, raccourcis rapides. |
| **Dépenses** | Liste des dépenses filtrables, graphiques (camembert catégories, courbe temporelle), bouton + ajout rapide. |
| **Ajout de dépense** | Formulaire : montant, catégorie (tap-select), description, date, mode de paiement. |
| **Budget** | Barres de progression par catégorie, historique mensuel, suggestions IA de réallocation. |
| **Bibliothèque** | Grille de documents avec filtres (matière, niveau, type), barre de recherche, cartes avec note et DL. |
| **Détail document** | Prévisualisation PDF inline, métadonnées, notation, commentaires, bouton téléchargement. |
| **Upload document** | Formulaire métadonnées + zone drag-and-drop fichier PDF. |
| **Assistant IA** | Interface chat avec bulles de dialogue, indicateur de streaming, suggestions de questions rapides. |
| **Profil / Abonnement** | Informations personnelles, plan actuel, historique de paiement, bouton upgrade. |
| **Paramètres** | Notifications, thème, langue, export de données, suppression de compte. |

---

## 8. Planning de Développement

### 8.1 Phases du projet

| Phase | Nom | Durée | Livrables |
|---|---|---|---|
| P1 | Cadrage & Architecture | 1 semaine | CDC validé, schéma BDD, architecture validée, repos Git initialisé. |
| P2 | Setup infrastructure | 1 semaine | Docker Compose opérationnel, BDD créée, Ollama + modèle installé, CI/CD configuré. |
| P3 | Backend — Auth & Users | 1 semaine | API register/login, JWT, profil utilisateur, plan freemium. |
| P4 | Backend — Dépenses | 1 semaine | CRUD dépenses, budgets, alertes, agrégations statistiques. |
| P5 | Backend — Bibliothèque | 1 semaine | Upload MinIO, CRUD documents, recherche, notation, modération. |
| P6 | Backend — IA Service | 1 semaine | Proxy Ollama, injection contexte, SSE streaming, historique. |
| P7 | Paiement MTN MoMo + Stripe | 3 jours | Intégration API MoMo + Stripe, gestion plans, webhook confirmation. |
| P8 | Frontend — Design System | 4 jours | Composants TailwindCSS, routing React, layout mobile/desktop. |
| P9 | Frontend — Modules | 2 semaines | Dashboard, Dépenses, Bibliothèque, Chat IA, Profil/Abonnement. |
| P10 | Tests & QA | 1 semaine | Tests unitaires API, tests E2E, tests charge Ollama, correction bugs. |
| P11 | Déploiement MVP | 3 jours | VPS production, domaine, SSL, monitoring (UptimeRobot). |

**Durée totale estimée pour le MVP : 10 à 11 semaines.**

---

## 9. Perspectives d'Évolution (Post-MVP)

### 9.1 Court terme (V1.1 — 3 mois après lancement)

- Forum étudiant intégré : questions / réponses par matière et niveau.
- Application mobile native (React Native) pour Android.
- Notifications push natives (Firebase Cloud Messaging).
- Tableau de bord administrateur web pour la modération des documents.

### 9.2 Moyen terme (V2 — 6 à 12 mois)

- Extension à d'autres pays d'Afrique francophone (Togo, Côte d'Ivoire, Sénégal).
- Intégration d'autres opérateurs MoMo et Flooz (Moov Money, Wave).
- Modèle IA fine-tuné sur des données académiques africaines.
- Partenariats avec universités pour intégration officielle de leurs ressources.
- Fonctionnalité de tutorat peer-to-peer avec matching par matière.

### 9.3 Long terme (V3+)

- Marketplace de cours et contenus premium créés par des enseignants.
- API EtuSmart ouverte pour intégration dans d'autres applications étudiantes.
- Modèle B2B : offre institutionnelle pour universités et grandes écoles.
- Analytics agrégées (anonymisées) pour les établissements partenaires.

---

## 10. Conclusion

EtuSmart est bien plus qu'une simple application de gestion de dépenses : c'est une plateforme à part entière conçue pour répondre aux réalités quotidiennes des étudiants béninois, en combinant intelligence financière, accès au savoir et assistance par intelligence artificielle.

En adoptant un modèle SaaS freemium ancré dans le contexte local — paiement MTN MoMo, interface en français, hébergement autonome via Ollama — EtuSmart se positionne comme un outil durable et scalable, capable d'évoluer vers d'autres marchés africains sans dépendance aux géants du cloud.

Ce cahier des charges pose les bases solides d'un développement structuré et progressif, du MVP initial à l'écosystème complet envisagé pour les deux années à venir.

---

*Document préparé par **TCHIDEHOU Dodji Virgile** — EtuSmart SaaS — Cotonou, Bénin — Juin 2026*
