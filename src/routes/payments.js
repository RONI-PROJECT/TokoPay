import express from 'express';
import QRCode from 'qrcode';
import { config } from '../config.js';
import { log } from '../logger.js';
import { validateWebhookUrl, isAuthenticated } from '../security.js';
import * as transactions from '../db/transactions.js';
import * as webhookStore from '../db/webhooks.js';
import * as payments from '../services/payments.js';
import * as webhooks from '../services/webhooks.js';
import { cycleIfStale } from '../services/poller.js';

const REF_PATTERN = /^[\w.-]{1,64}$/;

const fail = (res, status, error, message) =>
   res.status(status).json({ success: false, error, ...(message ? { message } : {}) });

const wrap = (handler) => (req, res, next) => Promise.resolve(handler(req, res, next)).catch(next);

const baseUrlFor = (req) => config.publicUrl || `${req.protocol}://${req.get('host')}`;

const toInt = (v) => (typeof v === 'number' ? v : /^\s*-?\d+\s*$/.test(String(v)) ? Number(v) : NaN);

function toV1(trx, base) {
   return {
      reference: trx.metadata?.merchant_reference || trx.trxId,
      trx_id: trx.trxId,
      status: trx.status,
      payment_method: 'QRIS',
      amount: Number(trx.amount),
      fee: Number(trx.fee || 0),
      total: Number(trx.amountToPay || trx.amount),
      net: Number(trx.net ?? (Number(trx.amount) - Number(trx.fee || 0))),
      currency: 'IDR',
      qr_string: trx.qrString || null,
      qr_image: `${base}/api/v1/qris/${encodeURIComponent(trx.trxId)}/qr`,
      expires_at: trx.expiresAt || null,
      created_at: trx.createdAt || null,
      paid_at: trx.paidAt || null,
      metadata: trx.metadata || null,
   };
}

async function parseCreateBody(body = {}, headers) {
   const amount = toInt(body.amount);
   if (!Number.isInteger(amount) || amount <= 0 || amount > config.maxAmount) {
      return { error: 'invalid_amount', message: `amount must be an integer between 1 and ${config.maxAmount}` };
   }

   let fee = 0;
   if (body.fee != null) {
      fee = toInt(body.fee);
   } else {
      try {
         const { one } = await import('../db/index.js');
         const row = await one("SELECT value FROM app_settings WHERE key = 'fee_transaction_percent'");
         const pct = parseFloat(row?.value || '0');
         if (pct > 0) fee = Math.round(amount * pct / 100);
      } catch {}
   }
   if (!Number.isInteger(fee) || fee < 0 || fee > config.maxAmount) {
      return { error: 'invalid_fee', message: `fee must be an integer between 0 and ${config.maxAmount}` };
   }

   const expireMinutes = (body.expires_minutes ?? body.expireMinutes) == null
      ? config.expireMinutes
      : toInt(body.expires_minutes ?? body.expireMinutes);
   if (!Number.isInteger(expireMinutes) || expireMinutes <= 0 || expireMinutes > config.maxExpireMinutes) {
      return { error: 'invalid_expires_minutes', message: `expires_minutes must be an integer between 1 and ${config.maxExpireMinutes}` };
   }

   const callbackUrl = typeof (body.callback_url ?? body.callbackUrl) === 'string'
      ? (body.callback_url ?? body.callbackUrl) : null;
   if (callbackUrl) {
      const check = validateWebhookUrl(callbackUrl);
      if (!check.ok) return { error: 'invalid_callback_url', message: check.error };
   }

   let callbackSecret = null;
   const rawSecret = body.callback_secret ?? body.callbackSecret;
   if (rawSecret != null) {
      callbackSecret = String(rawSecret);
      if (callbackSecret.length < 8 || callbackSecret.length > 256) {
         return { error: 'invalid_callback_secret', message: 'callback_secret must be 8-256 chars' };
      }
   }

   let trxId = null;
   const rawRef = body.reference ?? body.trxId;
   if (rawRef != null) {
      trxId = String(rawRef);
      if (!REF_PATTERN.test(trxId)) {
         return { error: 'invalid_reference', message: 'reference must be 1-64 chars: letters, digits, _ . -' };
      }
   }

   const baseMeta = (body.metadata && typeof body.metadata === 'object') ? body.metadata : {};
   const description = body.description ? String(body.description).slice(0, 200) : null;
   const finalMetadata = {
      ...baseMeta,
      merchant_reference: trxId,
      ...(description ? { description } : {}),
   };

   return {
      value: {
         amount,
         fee,
         expireMinutes,
         callbackUrl,
         callbackSecret,
         trxId,
         metadata: finalMetadata,
         paymentMethod: 'QRIS',
         idempotencyKey: headers['idempotency-key'] || body.idempotency_key || body.idempotencyKey || null,
      },
   };
}

async function findByReference(ref) {
   let found = await transactions.get(ref);
   if (found) return found;
   const rows = await transactions.list({ limit: 200, offset: 0 });
   return rows.find((t) => t.metadata?.merchant_reference === ref) || null;
}

export function paymentRoutes(guard, merchant = null) {
   const router = express.Router();

   router.post('/qris/create', guard, wrap(async (req, res) => {
      const { error, message, value } = await parseCreateBody(req.body, req.headers);
      if (error) return fail(res, 400, error, message);

      if (value.idempotencyKey) {
         const existing = await transactions.getByIdempotencyKey(value.idempotencyKey);
         if (existing) {
            return res.json({ success: true, idempotent: true, data: toV1(existing, baseUrlFor(req)) });
         }
      }

      if (value.trxId && await transactions.get(value.trxId)) {
         return fail(res, 409, 'reference_already_exists', 'reference sudah dipakai transaksi lain');
      }

      if (req.apiKeyUserId) value.userId = req.apiKeyUserId;

      try {
         const trx = await payments.create(value);
         res.status(201).json({ success: true, data: toV1(trx, baseUrlFor(req)) });
      } catch (e) {
         if (e.code === 'NO_FREE_CODE') return fail(res, 503, 'service_unavailable', e.message);
         if (e.code === 'DUPLICATE') {
            const existing = value.idempotencyKey
               && await transactions.getByIdempotencyKey(value.idempotencyKey);
            if (existing) {
               return res.json({ success: true, idempotent: true, data: toV1(existing, baseUrlFor(req)) });
            }
            if (value.trxId && await transactions.get(value.trxId)) {
               return fail(res, 409, 'reference_already_exists', 'reference sudah dipakai transaksi lain');
            }
            return fail(res, 503, 'service_unavailable', e.message);
         }
         throw e;
      }
   }));

   router.get('/qris/:reference', wrap(async (req, res) => {
      let found = await findByReference(req.params.reference);
      if (!found) return fail(res, 404, 'not_found', 'Transaksi tidak ditemukan');

      if (merchant && found.status === 'PENDING') {
         await cycleIfStale(merchant, config.pollMinIntervalMs);
         found = (await transactions.get(found.trxId)) || found;
      }

      const trx = await payments.expireIfOverdue(found);
      const full = toV1(trx, baseUrlFor(req));

      if (isAuthenticated(req, config.apiKey) || req.apiKeyUserId) {
         return res.json({ success: true, data: full });
      }
      const { metadata, callbackUrl, webhook, ...payerView } = full;
      res.json({ success: true, data: payerView });
   }));

   router.get('/qris/:reference/qr', wrap(async (req, res) => {
      const trx = await findByReference(req.params.reference);
      if (!trx) {
         res.setHeader('Cache-Control', 'no-store');
         return fail(res, 404, 'not_found', 'Transaksi tidak ditemukan');
      }
      const png = await QRCode.toBuffer(trx.qrString, { scale: 8, errorCorrectionLevel: 'M' });
      res.setHeader('Cache-Control', 'public, max-age=31536000, immutable');
      res.type('png').send(png);
   }));

   router.post('/qris/:reference/cancel', guard, wrap(async (req, res) => {
      const trx = await findByReference(req.params.reference);
      if (!trx) return fail(res, 404, 'not_found', 'Transaksi tidak ditemukan');
      if (trx.status !== 'PENDING') return fail(res, 409, 'cannot_cancel', `cannot cancel ${trx.status} trx`);

      await payments.expire(trx);
      const fresh = (await transactions.get(trx.trxId)) || trx;
      res.json({ success: true, data: toV1(fresh, baseUrlFor(req)) });
   }));

   router.post('/qris/:reference/replay-webhook', guard, wrap(async (req, res) => {
      const trx = await findByReference(req.params.reference);
      if (!trx) return fail(res, 404, 'not_found', 'Transaksi tidak ditemukan');
      if (trx.status === 'PENDING') return fail(res, 409, 'still_pending', 'trx is still PENDING — nothing to replay');

      await webhookStore.owe(trx.trxId);
      try {
         await webhooks.deliver(await transactions.get(trx.trxId));
      } catch (e) {
         log('webhook').error(`${trx.trxId} replay crashed: ${e.message}`);
      }
      const fresh = await transactions.get(trx.trxId);
      res.json({
         success: true,
         data: { reference: trx.metadata?.merchant_reference || trx.trxId, webhook_state: fresh?.webhookState ?? 'PENDING' },
      });
   }));

   return router;
}