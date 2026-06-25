-- ============================================================
--  EtuSmart — Schéma PostgreSQL initial (V1 MVP)
--  Exécuté automatiquement par Docker au démarrage
-- ============================================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";   -- gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "pg_trgm";    -- Recherche full-text trigram

-- ── Enumérations ─────────────────────────────────────────────────────────────

CREATE TYPE plan_type       AS ENUM ('free', 'basic', 'premium');
CREATE TYPE mode_paiement   AS ENUM ('momo', 'carte', 'especes');
CREATE TYPE type_doc        AS ENUM ('cours', 'td', 'annale', 'fiche');
CREATE TYPE statut_doc      AS ENUM ('pending', 'approved', 'rejected');
CREATE TYPE statut_abonnement AS ENUM ('active', 'expired', 'cancelled', 'pending');
CREATE TYPE niveau_etude    AS ENUM ('L1','L2','L3','Master1','Master2','Technique','Autre');

-- ── Table : users ────────────────────────────────────────────────────────────

CREATE TABLE users (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    nom             VARCHAR(100) NOT NULL,
    email           VARCHAR(255) NOT NULL UNIQUE,
    -- Hash bcrypt/argon2 ; NULL si authentification OAuth uniquement
    mot_de_passe    VARCHAR(255),
    -- Provider OAuth : 'local' | 'google'
    auth_provider   VARCHAR(20)  NOT NULL DEFAULT 'local',
    oauth_id        VARCHAR(255),
    plan            plan_type   NOT NULL DEFAULT 'free',
    etablissement   VARCHAR(200),
    niveau          niveau_etude,
    filiere         VARCHAR(100),
    -- Compte actif / désactivé
    actif           BOOLEAN     NOT NULL DEFAULT TRUE,
    -- Date de dernière connexion (pour expiration session)
    last_login_at   TIMESTAMP WITH TIME ZONE,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_auth_provider CHECK (auth_provider IN ('local','google')),
    -- Si local, mot_de_passe obligatoire
    CONSTRAINT chk_password_or_oauth CHECK (
        auth_provider = 'google' OR mot_de_passe IS NOT NULL
    )
);

CREATE INDEX idx_users_email ON users(email);

-- ── Table : refresh_tokens ───────────────────────────────────────────────────
-- Invalidation explicite des JWT refresh tokens (logout / suppression compte)

CREATE TABLE refresh_tokens (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash  VARCHAR(255) NOT NULL UNIQUE, -- SHA-256 du token
    expires_at  TIMESTAMP WITH TIME ZONE NOT NULL,
    revoked     BOOLEAN     NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_refresh_tokens_user ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_hash ON refresh_tokens(token_hash);

-- ── Table : depenses ─────────────────────────────────────────────────────────

CREATE TABLE depenses (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    montant         NUMERIC(12,0) NOT NULL CHECK (montant > 0),  -- en FCFA
    categorie       VARCHAR(50) NOT NULL,
    description     TEXT,
    mode_paiement   mode_paiement NOT NULL DEFAULT 'especes',
    date_depense    DATE        NOT NULL,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_depenses_user ON depenses(user_id);
CREATE INDEX idx_depenses_date ON depenses(user_id, date_depense DESC);
CREATE INDEX idx_depenses_categorie ON depenses(user_id, categorie);

-- ── Table : budgets ──────────────────────────────────────────────────────────

CREATE TABLE budgets (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    categorie       VARCHAR(50) NOT NULL,        -- 'global' pour le budget global
    montant_alloue  NUMERIC(12,0) NOT NULL CHECK (montant_alloue >= 0),
    mois            DATE        NOT NULL,         -- Premier jour du mois (ex: 2026-06-01)
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    UNIQUE(user_id, categorie, mois)
);

CREATE INDEX idx_budgets_user_mois ON budgets(user_id, mois DESC);

-- ── Table : documents ────────────────────────────────────────────────────────

CREATE TABLE documents (
    id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID        NOT NULL REFERENCES users(id) ON DELETE SET NULL,
    titre               VARCHAR(300) NOT NULL,
    matiere             VARCHAR(100) NOT NULL,
    niveau              niveau_etude NOT NULL,
    type_doc            type_doc    NOT NULL,
    etablissement       VARCHAR(200),
    -- Clé MinIO (UUID unique généré côté app, jamais le nom original)
    fichier_key         VARCHAR(500) NOT NULL UNIQUE,
    -- Nom original conservé en BDD uniquement (non exposé dans l'URL)
    nom_original        VARCHAR(255) NOT NULL,
    taille_octets       BIGINT      NOT NULL CHECK (taille_octets > 0),
    statut              statut_doc  NOT NULL DEFAULT 'pending',
    note_moyenne        NUMERIC(3,2) NOT NULL DEFAULT 0 CHECK (note_moyenne >= 0 AND note_moyenne <= 5),
    nb_telechargements  INTEGER     NOT NULL DEFAULT 0,
    -- Version pour le versioning simple
    version             INTEGER     NOT NULL DEFAULT 1,
    parent_id           UUID        REFERENCES documents(id) ON DELETE SET NULL,
    created_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_documents_statut ON documents(statut);
CREATE INDEX idx_documents_user ON documents(user_id);
CREATE INDEX idx_documents_niveau_matiere ON documents(niveau, matiere);
-- Index trigram pour la recherche full-text
CREATE INDEX idx_documents_titre_trgm ON documents USING gin(titre gin_trgm_ops);
CREATE INDEX idx_documents_matiere_trgm ON documents USING gin(matiere gin_trgm_ops);

-- ── Table : evaluations_doc ──────────────────────────────────────────────────

CREATE TABLE evaluations_doc (
    id          UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID    NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    document_id UUID    NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
    note        SMALLINT NOT NULL CHECK (note BETWEEN 1 AND 5),
    commentaire TEXT,
    created_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    UNIQUE(user_id, document_id)
);

CREATE INDEX idx_eval_document ON evaluations_doc(document_id);

-- Trigger : mise à jour automatique de note_moyenne
CREATE OR REPLACE FUNCTION update_note_moyenne()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE documents
    SET note_moyenne = (
        SELECT COALESCE(AVG(note), 0) FROM evaluations_doc WHERE document_id = NEW.document_id
    ),
    updated_at = NOW()
    WHERE id = NEW.document_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_note_moyenne
AFTER INSERT OR UPDATE OR DELETE ON evaluations_doc
FOR EACH ROW EXECUTE FUNCTION update_note_moyenne();

-- ── Table : collections ──────────────────────────────────────────────────────

CREATE TABLE collections (
    id          UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID    NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    nom         VARCHAR(150) NOT NULL,
    description TEXT,
    publique    BOOLEAN NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE collection_documents (
    collection_id UUID NOT NULL REFERENCES collections(id) ON DELETE CASCADE,
    document_id   UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
    added_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    PRIMARY KEY (collection_id, document_id)
);

-- ── Table : ai_conversations ─────────────────────────────────────────────────

CREATE TABLE ai_conversations (
    id          UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID    NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    -- 'user' | 'assistant'
    role        VARCHAR(20) NOT NULL CHECK (role IN ('user', 'assistant')),
    contenu     TEXT    NOT NULL,
    -- Nombre de tokens (pour rate limiting par plan)
    tokens_used INTEGER NOT NULL DEFAULT 0,
    session_id  UUID    NOT NULL,             -- Groupe les messages d'une même session
    created_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ai_conv_user_session ON ai_conversations(user_id, session_id, created_at DESC);

-- ── Table : abonnements ──────────────────────────────────────────────────────

CREATE TABLE abonnements (
    id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    plan                plan_type   NOT NULL,
    debut               DATE        NOT NULL,
    fin                 DATE        NOT NULL,
    statut              statut_abonnement NOT NULL DEFAULT 'pending',
    -- 'momo' | 'stripe'
    provider_paiement   VARCHAR(20) NOT NULL,
    reference_externe   VARCHAR(255),         -- Référence transaction MoMo / Stripe
    montant_fcfa        NUMERIC(10,0) NOT NULL,
    created_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_abonnements_user ON abonnements(user_id);
CREATE INDEX idx_abonnements_statut ON abonnements(statut, fin DESC);

-- ── Triggers updated_at automatiques ─────────────────────────────────────────

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at        BEFORE UPDATE ON users        FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_depenses_updated_at     BEFORE UPDATE ON depenses     FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_budgets_updated_at      BEFORE UPDATE ON budgets      FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_documents_updated_at    BEFORE UPDATE ON documents    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_abonnements_updated_at  BEFORE UPDATE ON abonnements  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ── Utilisateur applicatif (Least Privilege) ─────────────────────────────────
-- Le user etusmart_app n'a que SELECT/INSERT/UPDATE/DELETE sur les tables métier.
-- Il ne peut PAS faire DROP TABLE, TRUNCATE, ALTER, etc.
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'etusmart_app') THEN
        CREATE ROLE etusmart_app WITH LOGIN PASSWORD 'CHANGE_ME_APP_DB_PASS';
    END IF;
END
$$;

GRANT CONNECT ON DATABASE etusmart TO etusmart_app;
GRANT USAGE ON SCHEMA public TO etusmart_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO etusmart_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO etusmart_app;
-- Appliquer aux futures tables automatiquement
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO etusmart_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT USAGE, SELECT ON SEQUENCES TO etusmart_app;
