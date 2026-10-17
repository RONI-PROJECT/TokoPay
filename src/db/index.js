let client = null;
let connecting = null;

export function withVerifiedSsl(raw) {
   try {
      const url = new URL(raw);
      const mode = url.searchParams.get('sslmode');
      if (mode && mode !== 'disable' && mode !== 'verify-full') {
         url.searchParams.set('sslmode', 'verify-full');
      }
      return url.toString();
   } catch { return raw; }
}

export function sslOption(raw) {
   let host = '';
   try { host = new URL(raw).hostname; } catch {}
   return ['localhost', '127.0.0.1', '[::1]'].includes(host) ? false : { rejectUnauthorized: true };
}

async function connect() {
   if (process.env.DATABASE_URL) {
      const { default: pg } = await import('pg');
      pg.types.setTypeParser(20, Number);
      return new pg.Pool({
         connectionString: withVerifiedSsl(process.env.DATABASE_URL),
         max: 3,
         idleTimeoutMillis: 30000,
         connectionTimeoutMillis: 30000,
         ssl: sslOption(process.env.DATABASE_URL),
         keepAlive: true,
         keepAliveInitialDelayMillis: 10000,
      });
   }
   const pgliteModule = '@electric-sql/pglite';
   const { PGlite } = await import(/* @vite-ignore */ pgliteModule);
   const db = await PGlite.create(process.env.PGLITE_DIR || undefined);
   return { query: (text, params) => db.query(text, params), _pglite: db };
}

const TRANSIENT = new Set(['ETIMEDOUT', 'ECONNRESET', 'ECONNREFUSED', 'EPIPE', 'ENOTFOUND', 'EAI_AGAIN', '57P01', '57P03', '08006', '08001', '08004']);
const isTransient = (e) => TRANSIENT.has(e?.code) || (Array.isArray(e?.errors) && e.errors.some(isTransient));
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function open() {
   connecting ??= connect().then((c) => (client = c), (e) => { connecting = null; throw e; });
   await connecting;
}

export async function sql(text, params = []) {
   let lastError;
   for (let attempt = 1; attempt <= 3; attempt++) {
      try {
         if (!client) await open();
         return await client.query(text, params);
      } catch (e) {
         lastError = e;
         if (!isTransient(e)) throw e;
         const dead = client;
         client = null;
         connecting = null;
         dead?.end?.().catch?.(() => {});
         if (attempt < 3) await sleep(attempt * 400);
      }
   }
   throw lastError;
}

export const one = async (text, params) => (await sql(text, params)).rows[0] ?? null;
export const all = async (text, params) => (await sql(text, params)).rows;
export const changed = async (text, params) => {
   const res = await sql(text, params);
   return res.rowCount ?? res.affectedRows ?? 0;
};

export async function close() {
   const c = client;
   client = null;
   connecting = null;
   if (c?.end) await c.end();
   else if (c?._pglite) await c._pglite.close();
}

const SCHEMA = `
   CREATE TABLE IF NOT EXISTS users (
      id                TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
      email             TEXT UNIQUE NOT NULL,
      password          TEXT NOT NULL,
      name              TEXT,
      phone             TEXT,
      role              TEXT NOT NULL DEFAULT 'user',
      status            TEXT NOT NULL DEFAULT 'active',
      balance           BIGINT NOT NULL DEFAULT 0,
      "webhookUrl"      TEXT,
      "webhookSecret"   TEXT,
      "createdAt"       TEXT NOT NULL,
      "lastLoginAt"     TEXT,
      totp_enabled      BOOLEAN DEFAULT false,
      totp_secret       TEXT,
      totp_backup_codes TEXT,
      totp_verified_at  TEXT,
      "isAdmin"         BOOLEAN DEFAULT false,
      "adminBalance"    BIGINT NOT NULL DEFAULT 0
   );

   CREATE TABLE IF NOT EXISTS transactions (
      "trxId"            TEXT PRIMARY KEY,
      "userId"           TEXT,
      status             TEXT NOT NULL,
      amount             BIGINT NOT NULL,
      fee                BIGINT NOT NULL DEFAULT 0,
      net                BIGINT NOT NULL DEFAULT 0,
      "merchantAmount"   BIGINT NOT NULL DEFAULT 0,
      "feePercent"       NUMERIC NOT NULL DEFAULT 0,
      total              BIGINT NOT NULL,
      "payAmount"        BIGINT NOT NULL,
      "qrString"         TEXT NOT NULL,
      "qrImageUrl"       TEXT,
      "callbackUrl"      TEXT,
      "callbackSecret"   TEXT,
      "idempotencyKey"   TEXT,
      metadata           JSONB,
      "createdAt"        TEXT NOT NULL,
      "expiresAt"        TEXT NOT NULL,
      "paidAt"           TEXT,
      entry              JSONB,
      "webhookState"     TEXT,
      "webhookAttempts"  INTEGER NOT NULL DEFAULT 0,
      "webhookNextAt"    TEXT,
      "webhookLastError" TEXT
   );
   CREATE INDEX IF NOT EXISTS idx_status ON transactions(status);
   CREATE INDEX IF NOT EXISTS idx_created ON transactions("createdAt" DESC);
   CREATE INDEX IF NOT EXISTS idx_pay_amount ON transactions("payAmount");
   CREATE UNIQUE INDEX IF NOT EXISTS idx_idempotency ON transactions("idempotencyKey") WHERE "idempotencyKey" IS NOT NULL;
   CREATE INDEX IF NOT EXISTS idx_webhook_due ON transactions("webhookNextAt") WHERE "webhookState" = 'PENDING';
   CREATE INDEX IF NOT EXISTS idx_pending_expiry ON transactions("expiresAt") WHERE status = 'PENDING';

   CREATE TABLE IF NOT EXISTS gobiz_history (
      "gobizId"      TEXT PRIMARY KEY,
      amount         BIGINT NOT NULL,
      time           TEXT,
      "matchedTrxId" TEXT,
      raw            JSONB,
      "seenAt"       TEXT NOT NULL
   );
   CREATE INDEX IF NOT EXISTS idx_hist_matched ON gobiz_history("matchedTrxId");
   CREATE INDEX IF NOT EXISTS idx_hist_seen ON gobiz_history("seenAt" DESC);

   CREATE TABLE IF NOT EXISTS meta (
      key   TEXT PRIMARY KEY,
      value JSONB NOT NULL
   );

   CREATE TABLE IF NOT EXISTS sessions (
      token       TEXT PRIMARY KEY,
      "userId"    TEXT NOT NULL,
      "createdAt" TEXT NOT NULL,
      "expiresAt" TEXT NOT NULL,
      "ipAddress" TEXT,
      "userAgent" TEXT
   );
   CREATE INDEX IF NOT EXISTS idx_sessions_user ON sessions("userId");
   CREATE INDEX IF NOT EXISTS idx_sessions_expires ON sessions("expiresAt");

   CREATE TABLE IF NOT EXISTS api_keys (
      id           TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
      "userId"     TEXT NOT NULL,
      name         TEXT,
      key          TEXT UNIQUE NOT NULL,
      secret       TEXT,
      status       TEXT NOT NULL DEFAULT 'active',
      environment  TEXT NOT NULL DEFAULT 'production',
      "lastUsedAt" TEXT,
      "createdAt"  TEXT NOT NULL
   );
   CREATE INDEX IF NOT EXISTS idx_api_keys_user ON api_keys("userId");

   CREATE TABLE IF NOT EXISTS withdrawals (
      id            TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
      "wdrId"       TEXT UNIQUE NOT NULL,
      "userId"      TEXT NOT NULL,
      amount        BIGINT NOT NULL,
      fee           BIGINT NOT NULL DEFAULT 0,
      received      BIGINT NOT NULL,
      bank          TEXT,
      account       TEXT,
      status        TEXT NOT NULL DEFAULT 'PENDING',
      note          TEXT,
      "createdAt"   TEXT NOT NULL,
      "processedAt" TEXT
   );

   CREATE TABLE IF NOT EXISTS notifications (
      id          TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
      "userId"    TEXT NOT NULL,
      type        TEXT,
      title       TEXT,
      body        TEXT,
      data        JSONB,
      read        BOOLEAN NOT NULL DEFAULT false,
      "createdAt" TEXT NOT NULL
   );
   CREATE INDEX IF NOT EXISTS idx_notif_user ON notifications("userId", "createdAt" DESC);

   CREATE TABLE IF NOT EXISTS webhook_logs (
      id          TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
      user_id     TEXT,
      trx_id      TEXT,
      event       TEXT,
      url         TEXT,
      http_status INTEGER,
      latency_ms  INTEGER,
      status      TEXT,
      error       TEXT,
      sent_at     TEXT
   );
   CREATE INDEX IF NOT EXISTS idx_wh_logs_trx ON webhook_logs(trx_id);

   CREATE TABLE IF NOT EXISTS app_settings (
      key   TEXT PRIMARY KEY,
      value TEXT
   );
`;

export async function migrate() {
   for (const statement of SCHEMA.split(';')) {
      if (statement.trim()) await sql(statement);
   }
}
