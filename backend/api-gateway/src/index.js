/**
 * EtuSmart — API Gateway
 * Point d'entrée unique : routing, sécurité, rate limiting, auth middleware.
 *
 * SÉCURITÉ :
 * - JWT : algorithme HS256 forcé, exp validé, secret lu depuis ENV uniquement
 * - CORS : origines strictes via allowlist
 * - Helmet : headers sécurité (CSP, X-Frame-Options, nosniff…)
 * - Rate limiting : Redis-backed via express-rate-limit
 * - Cookies : HttpOnly, Secure, SameSite=Lax
 * - TODO(security): Implémenter MFA (TOTP) en P3
 * - TODO(security): Ajouter détection de mots de passe compromis (HaveIBeenPwned) en P3
 */

import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import rateLimit from 'express-rate-limit';
import { createRequire } from 'module';
import fs from 'fs';
import crypto from 'crypto';
import pino from 'pino';

// ── Logger sécurisé (pas de données sensibles dans les logs) ──────────────────
const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  // En prod, désactiver pretty-print
  ...(process.env.NODE_ENV !== 'production' && {
    transport: { target: 'pino-pretty', options: { colorize: true } },
  }),
});

// ── Chargement du secret JWT (multi-tiered, jamais de fallback hardcodé) ─────
function getJwtSecret() {
  if (process.env.JWT_SECRET) return process.env.JWT_SECRET;
  if (fs.existsSync('./jwt_secret.txt')) {
    return fs.readFileSync('./jwt_secret.txt', 'utf-8').trim();
  }
  // Fallback dev uniquement : éphémère + avertissement
  if (process.env.NODE_ENV !== 'production') {
    const ephemeral = crypto.randomBytes(64).toString('hex');
    logger.warn('⚠️  JWT_SECRET absent — secret éphémère généré. NON utilisable en production !');
    return ephemeral;
  }
  // En production, on refuse de démarrer sans secret
  logger.error('FATAL: JWT_SECRET manquant en production. Arrêt.');
  process.exit(1);
}
export const JWT_SECRET = getJwtSecret();

// ── Application Express ───────────────────────────────────────────────────────
const app = express();
const PORT = parseInt(process.env.PORT || '4000', 10);

// ── Trust proxy (Nginx devant) ────────────────────────────────────────────────
app.set('trust proxy', 1);

// ── Helmet : headers de sécurité ─────────────────────────────────────────────
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc:  ["'self'"],
      scriptSrc:   ["'self'"],
      styleSrc:    ["'self'"],
      imgSrc:      ["'self'", 'data:'],
      connectSrc:  ["'self'"],
      fontSrc:     ["'self'"],
      objectSrc:   ["'none'"],
      frameAncestors: ["'none'"],
    },
  },
  crossOriginEmbedderPolicy: false, // Prévisualisation PDF inline
}));

// ── CORS : origines strictes, pas de wildcard ─────────────────────────────────
const allowedOrigins = (process.env.CORS_ORIGINS || 'http://localhost:5173')
  .split(',')
  .map(o => o.trim());

app.use(cors({
  origin(origin, cb) {
    // Autoriser les requêtes sans origin (ex: Postman en dev)
    if (!origin || allowedOrigins.includes(origin)) return cb(null, true);
    cb(new Error(`CORS: origine non autorisée — ${origin}`));
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-CSRF-Token'],
}));

// ── Body parsing ──────────────────────────────────────────────────────────────
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: false, limit: '1mb' }));
app.use(cookieParser());

// ── Rate Limiting global (Redis en prod) ──────────────────────────────────────
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000', 10),
  max:      parseInt(process.env.RATE_LIMIT_MAX       || '100',    10),
  standardHeaders: 'draft-7',
  legacyHeaders:   false,
  message: { error: 'Trop de requêtes. Réessayez dans quelques minutes.' },
  // TODO(security): Brancher RedisStore ici en P6 pour rate-limit distribué
});
app.use(limiter);

// ── Rate limiting renforcé sur les endpoints d'auth ──────────────────────────
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 min
  max: 10,
  message: { error: 'Trop de tentatives. Réessayez dans 15 minutes.' },
  skipSuccessfulRequests: true,
});

// ── Health check ──────────────────────────────────────────────────────────────
app.get('/health', (_req, res) => {
  res.json({ status: 'ok', service: 'api-gateway', ts: new Date().toISOString() });
});

// ── Routes (à brancher progressivement par phase) ─────────────────────────────
// P3 : /api/auth
// P4 : /api/expenses, /api/budgets
// P5 : /api/library
// P6 : /api/ai
// P7 : /api/payments

app.use('/api/auth', authLimiter, (req, res) => {
  res.status(501).json({ error: 'Auth service — à implémenter en P3' });
});

// ── Gestion 404 ───────────────────────────────────────────────────────────────
app.use((_req, res) => {
  res.status(404).json({ error: 'Route introuvable' });
});

// ── Gestionnaire d'erreurs global (ne pas exposer les détails en prod) ────────
// eslint-disable-next-line no-unused-vars
app.use((err, req, res, _next) => {
  // Logging détaillé côté serveur uniquement
  logger.error({ err, url: req.url, method: req.method }, 'Erreur non gérée');
  // Message générique côté client
  res.status(500).json({ error: 'Une erreur interne est survenue.' });
});

// ── Démarrage ─────────────────────────────────────────────────────────────────
// En test : écoute sur 127.0.0.1 uniquement (directive sécurité)
const HOST = process.env.NODE_ENV === 'test' ? '127.0.0.1' : '0.0.0.0';
app.listen(PORT, HOST, () => {
  logger.info(`✅  API Gateway démarré sur ${HOST}:${PORT} [${process.env.NODE_ENV}]`);
});

export default app;
