-- =========================================================
-- GoBiz Payment — Clean Schema
-- Generated: (auto)
-- No sensitive data. Safe to commit.
-- =========================================================

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

-- =========================================================
-- DROP (reverse FK order)
-- =========================================================
DROP TABLE IF EXISTS public.webhook_logs CASCADE;
DROP TABLE IF EXISTS public.withdrawals CASCADE;
DROP TABLE IF EXISTS public.sessions CASCADE;
DROP TABLE IF EXISTS public.api_keys CASCADE;
DROP TABLE IF EXISTS public.transactions CASCADE;
DROP TABLE IF EXISTS public.transactions_sandbox CASCADE;
DROP TABLE IF EXISTS public.fee_logs CASCADE;
DROP TABLE IF EXISTS public.gobiz_history CASCADE;
DROP TABLE IF EXISTS public.meta CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;
DROP SEQUENCE IF EXISTS public.unique_code_seq CASCADE;

-- =========================================================
-- USERS
-- =========================================================
CREATE TABLE public.users (
    id                 integer NOT NULL,
    email              text NOT NULL,
    password           text NOT NULL,
    name               text,
    phone              varchar(20),
    role               text DEFAULT 'user'::text NOT NULL,
    status             text DEFAULT 'active'::text NOT NULL,
    "createdAt"        text NOT NULL,
    "lastLoginAt"      text,
    "webhookUrl"       text,
    "webhookSecret"    text,
    balance            bigint DEFAULT 0 NOT NULL,
    totp_secret        text,
    totp_enabled       boolean DEFAULT false,
    totp_backup_codes  text,
    totp_verified_at   text,
    "isAdmin"          boolean DEFAULT false,
    "adminBalance"     bigint DEFAULT 0 NOT NULL
);

CREATE SEQUENCE public.users_id_seq
    AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;
ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);

CREATE INDEX idx_users_email   ON public.users USING btree (email);
CREATE INDEX idx_users_role    ON public.users USING btree (role);
CREATE INDEX idx_users_balance ON public.users USING btree (balance);

-- =========================================================
-- API KEYS
-- =========================================================
CREATE TABLE public.api_keys (
    id            integer NOT NULL,
    "userId"      integer NOT NULL,
    name          text NOT NULL,
    key           text NOT NULL,
    secret        text NOT NULL,
    status        text DEFAULT 'active'::text NOT NULL,
    "lastUsedAt"  text,
    "createdAt"   text NOT NULL,
    environment   text DEFAULT 'production'::text,
    "revokedAt"   text
);

CREATE SEQUENCE public.api_keys_id_seq
    AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;

ALTER SEQUENCE public.api_keys_id_seq OWNED BY public.api_keys.id;
ALTER TABLE ONLY public.api_keys ALTER COLUMN id SET DEFAULT nextval('public.api_keys_id_seq'::regclass);

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_key_key UNIQUE (key);
ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT "api_keys_userId_fkey" FOREIGN KEY ("userId")
        REFERENCES public.users(id) ON DELETE CASCADE;

CREATE INDEX idx_apikeys_key  ON public.api_keys USING btree (key);
CREATE INDEX idx_apikeys_user ON public.api_keys USING btree ("userId");

-- =========================================================
-- SESSIONS
-- =========================================================
CREATE TABLE public.sessions (
    token        text NOT NULL,
    "userId"     integer NOT NULL,
    "createdAt"  text NOT NULL,
    "expiresAt"  text NOT NULL,
    "ipAddress"  text,
    "userAgent"  text
);

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (token);
ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT "sessions_userId_fkey" FOREIGN KEY ("userId")
        REFERENCES public.users(id) ON DELETE CASCADE;

CREATE INDEX idx_sessions_user    ON public.sessions USING btree ("userId");
CREATE INDEX idx_sessions_expires ON public.sessions USING btree ("expiresAt");

-- =========================================================
-- TRANSACTIONS
-- =========================================================
CREATE TABLE public.transactions (
    "trxId"              text NOT NULL,
    status               text NOT NULL,
    amount               bigint NOT NULL,
    fee                  bigint DEFAULT 0 NOT NULL,
    total                bigint NOT NULL,
    "payAmount"          bigint NOT NULL,
    "uniqueCode"         integer,
    "qrString"           text NOT NULL,
    "callbackUrl"        text,
    "callbackSecret"     text,
    "idempotencyKey"     text,
    metadata             jsonb,
    "createdAt"          text NOT NULL,
    "expiresAt"          text NOT NULL,
    "paidAt"             text,
    entry                jsonb,
    "webhookState"       text,
    "webhookAttempts"    integer DEFAULT 0 NOT NULL,
    "webhookNextAt"      text,
    "webhookLastError"   text,
    "userId"             integer,
    "qrImageUrl"         text,
    "amountToPay"        bigint,
    "feeAmount"          bigint DEFAULT 0,
    "merchantAmount"     bigint DEFAULT 0,
    "feePercent"         numeric(5,2) DEFAULT 0,
    "adminFee"           bigint DEFAULT 0 NOT NULL
);

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY ("trxId");

CREATE INDEX idx_status      ON public.transactions USING btree (status);
CREATE INDEX idx_created     ON public.transactions USING btree ("createdAt" DESC);
CREATE INDEX idx_trx_user_id ON public.transactions USING btree ("userId");

-- =========================================================
-- TRANSACTIONS SANDBOX
-- =========================================================
CREATE TABLE public.transactions_sandbox (
    "trxId"        text NOT NULL,
    "userId"       integer,
    status         text DEFAULT 'PENDING'::text NOT NULL,
    amount         bigint NOT NULL,
    fee            bigint DEFAULT 0 NOT NULL,
    total          bigint NOT NULL,
    "amountToPay"  bigint NOT NULL,
    "qrString"     text,
    "qrImageUrl"   text,
    metadata       jsonb,
    "createdAt"    text NOT NULL,
    "expiresAt"    text NOT NULL,
    "paidAt"       text
);

ALTER TABLE ONLY public.transactions_sandbox
    ADD CONSTRAINT transactions_sandbox_pkey PRIMARY KEY ("trxId");

CREATE INDEX idx_sbx_user ON public.transactions_sandbox USING btree ("userId");

-- =========================================================
-- FEE LOGS
-- =========================================================
CREATE TABLE public.fee_logs (
    id                  integer NOT NULL,
    trx_id              text,
    user_id             integer,
    amount              bigint,
    fee                 bigint,
    merchant_received   bigint,
    created_at          text NOT NULL
);

CREATE SEQUENCE public.fee_logs_id_seq
    AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;

ALTER SEQUENCE public.fee_logs_id_seq OWNED BY public.fee_logs.id;
ALTER TABLE ONLY public.fee_logs ALTER COLUMN id SET DEFAULT nextval('public.fee_logs_id_seq'::regclass);

ALTER TABLE ONLY public.fee_logs
    ADD CONSTRAINT fee_logs_pkey PRIMARY KEY (id);

-- =========================================================
-- GOBIZ HISTORY
-- =========================================================
CREATE TABLE public.gobiz_history (
    "gobizId"       text NOT NULL,
    amount          bigint NOT NULL,
    "time"          text,
    "matchedTrxId"  text,
    raw             jsonb,
    "seenAt"        text NOT NULL
);

ALTER TABLE ONLY public.gobiz_history
    ADD CONSTRAINT gobiz_history_pkey PRIMARY KEY ("gobizId");

CREATE INDEX idx_hist_matched ON public.gobiz_history USING btree ("matchedTrxId");
CREATE INDEX idx_hist_seen    ON public.gobiz_history USING btree ("seenAt" DESC);

-- =========================================================
-- META
-- =========================================================
CREATE TABLE public.meta (
    key    text NOT NULL,
    value  jsonb NOT NULL
);

ALTER TABLE ONLY public.meta
    ADD CONSTRAINT meta_pkey PRIMARY KEY (key);

-- =========================================================
-- WEBHOOK LOGS
-- =========================================================
CREATE TABLE public.webhook_logs (
    id          integer NOT NULL,
    user_id     integer,
    trx_id      text,
    event       text NOT NULL,
    url         text NOT NULL,
    http_status integer,
    latency_ms  integer,
    status      text NOT NULL,
    error       text,
    sent_at     text NOT NULL
);

CREATE SEQUENCE public.webhook_logs_id_seq
    AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;

ALTER SEQUENCE public.webhook_logs_id_seq OWNED BY public.webhook_logs.id;
ALTER TABLE ONLY public.webhook_logs ALTER COLUMN id SET DEFAULT nextval('public.webhook_logs_id_seq'::regclass);

ALTER TABLE ONLY public.webhook_logs
    ADD CONSTRAINT webhook_logs_pkey PRIMARY KEY (id);

CREATE INDEX idx_whlog_user ON public.webhook_logs USING btree (user_id, sent_at DESC);

-- =========================================================
-- WITHDRAWALS
-- =========================================================
CREATE TABLE public.withdrawals (
    id            integer NOT NULL,
    "wdrId"       text NOT NULL,
    "userId"      integer NOT NULL,
    amount        bigint NOT NULL,
    fee           bigint DEFAULT 0 NOT NULL,
    received      bigint NOT NULL,
    bank          text,
    account       text,
    status        text DEFAULT 'PENDING'::text NOT NULL,
    note          text,
    "createdAt"   text NOT NULL,
    "processedAt" text
);

CREATE SEQUENCE public.withdrawals_id_seq
    AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;

ALTER SEQUENCE public.withdrawals_id_seq OWNED BY public.withdrawals.id;
ALTER TABLE ONLY public.withdrawals ALTER COLUMN id SET DEFAULT nextval('public.withdrawals_id_seq'::regclass);

ALTER TABLE ONLY public.withdrawals
    ADD CONSTRAINT withdrawals_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.withdrawals
    ADD CONSTRAINT "withdrawals_wdrId_key" UNIQUE ("wdrId");
ALTER TABLE ONLY public.withdrawals
    ADD CONSTRAINT "withdrawals_userId_fkey" FOREIGN KEY ("userId")
        REFERENCES public.users(id) ON DELETE CASCADE;

CREATE INDEX idx_wdr_status ON public.withdrawals USING btree (status);
CREATE INDEX idx_wdr_user   ON public.withdrawals USING btree ("userId");

-- =========================================================
-- UNIQUE CODE SEQUENCE (standalone)
-- =========================================================
CREATE SEQUENCE public.unique_code_seq
    START WITH 1 INCREMENT BY 1 NO MINVALUE MAXVALUE 9223372036854775806 CACHE 1 CYCLE;

-- =========================================================
-- SEED: Admin User
-- Password hash placeholder — GENERATE ULANG SENDIRI
-- Cara generate: node -e "console.log(require('bcryptjs').hashSync('PASSWORD_KAMU',10))"
-- =========================================================
INSERT INTO public.users (
    id, email, password, name, role, status, "createdAt", balance, "isAdmin", "adminBalance"
) VALUES (
    1,
    'admin@website.com',
    '$2b$10$REPLACE_THIS_WITH_YOUR_OWN_BCRYPT_HASH',
    'Administrator',
    'admin',
    'active',
    to_char(NOW() AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'),
    0,
    true,
    0
);

-- Reset sequences ke posisi aman
SELECT pg_catalog.setval('public.users_id_seq', 1, true);

-- =========================================================
-- SELESAI
-- =========================================================
