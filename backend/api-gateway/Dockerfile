FROM node:20-alpine AS base

# ── Sécurité : utilisateur non-root ──────────────────────────
RUN addgroup -S etusmart && adduser -S etusmart -G etusmart

WORKDIR /app

# ── Dépendances ───────────────────────────────────────────────
COPY package.json package-lock.json* ./
RUN npm ci --omit=dev && npm cache clean --force

# ── Code source ───────────────────────────────────────────────
COPY --chown=etusmart:etusmart . .

USER etusmart

EXPOSE 4000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:4000/health || exit 1

CMD ["node", "src/index.js"]
