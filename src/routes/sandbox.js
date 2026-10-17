/**
 * Sandbox routes — endpoint testing tanpa uang berpindah.
 * Auth: X-API-Key dengan environment = 'sandbox'.
 * Data disimpen di transactions_sandbox (terpisah dari produksi).
 */
import { Router } from 'express';
import crypto from 'node:crypto';
import QRCode from 'qrcode';
import { one, all, sql } from '../db/index.js';

export function sandboxRoutes() {
   const router = Router();

   // Auth: API key environment = sandbox
   async function requireSandboxKey(req, res, next) {
      try {
         const apiKey = req.headers['x-api-key'] || req.headers['X-API-Key'];
         if (!apiKey) return res.status(401).json({ success: false, error: 'unauthorized' });

         const key = await one(
            `SELECT k.*, u.id AS "userId", u.status AS "userStatus"
             FROM api_keys k JOIN users u ON u.id = k."userId"
             WHERE k.key = $1 AND k.status = 'active'`,
            [apiKey]
         );
         if (!key) return res.status(401).json({ success: false, error: 'unauthorized' });
         if (key.environment !== 'sandbox') {
            return res.status(403).json({ success: false, error: 'Bukan sandbox key — pakai tpv_test_*' });
         }
         if (key.userStatus !== 'active') {
            return res.status(403).json({ success: false, error: 'user suspended' });
         }

         req.user = { id: key.userId };
         req.apiKey = key;
         next();
      } catch (e) { next(e); }
   }

   // POST /sandbox/payment/create
   router.post('/payment/create', requireSandboxKey, async (req, res, next) => {
      try {
         const amount = Number(req.body?.amount);
         if (!amount || amount < 1000) return res.status(400).json({ success: false, error: 'amount minimal 1000' });
         if (amount > 100000000) return res.status(400).json({ success: false, error: 'amount maksimal 100 juta' });

         const trxId = 'SBX-' + crypto.randomBytes(8).toString('hex').toUpperCase();
         const now = new Date().toISOString();
         const expiresAt = new Date(Date.now() + 5 * 60 * 1000).toISOString();

         // QR dummy untuk sandbox
         const qrContent = 'SANDBOX|' + trxId + '|' + amount;
         const qrImageUrl = await QRCode.toDataURL(qrContent, {
            width: 400, margin: 2, errorCorrectionLevel: 'M',
            color: { dark: '#171717', light: '#ffffff' },
         });

         await sql(
            `INSERT INTO transactions_sandbox
             ("trxId","userId",status,amount,fee,total,"amountToPay","qrString","qrImageUrl","createdAt","expiresAt")
             VALUES ($1,$2,'PENDING',$3,0,$3,$3,$4,$5,$6,$7)`,
            [trxId, req.user.id, amount, qrContent, qrImageUrl, now, expiresAt]
         );

         res.json({
            success: true,
            data: {
               trxId,
               status: 'PENDING',
               amount,
               amountToPay: amount,
               qrString: qrContent,
               qrImageUrl,
               createdAt: now,
               expiresAt,
               sandbox: true,
            },
         });
      } catch (e) { next(e); }
   });

   // GET /sandbox/payment/:trxId
   router.get('/payment/:trxId', requireSandboxKey, async (req, res, next) => {
      try {
         const trx = await one(
            `SELECT * FROM transactions_sandbox WHERE "trxId" = $1 AND "userId" = $2`,
            [req.params.trxId, req.user.id]
         );
         if (!trx) return res.status(404).json({ success: false, error: 'not found' });
         res.json({ success: true, data: trx });
      } catch (e) { next(e); }
   });

   // GET /sandbox/payments
   router.get('/payments', requireSandboxKey, async (req, res, next) => {
      try {
         const rows = await all(
            `SELECT * FROM transactions_sandbox WHERE "userId" = $1 ORDER BY "createdAt" DESC LIMIT 50`,
            [req.user.id]
         );
         res.json({ success: true, data: rows });
      } catch (e) { next(e); }
   });

   // POST /sandbox/payment/:trxId/paid — tandai lunas manual (khusus sandbox)
   router.post('/payment/:trxId/paid', requireSandboxKey, async (req, res, next) => {
      try {
         const r = await sql(
            `UPDATE transactions_sandbox SET status = 'PAID', "paidAt" = $1
             WHERE "trxId" = $2 AND "userId" = $3 AND status = 'PENDING'
             RETURNING "trxId", status, "paidAt"`,
            [new Date().toISOString(), req.params.trxId, req.user.id]
         );
         if (r.rows.length === 0) return res.status(404).json({ success: false, error: 'not found or already settled' });
         res.json({ success: true, data: r.rows[0] });
      } catch (e) { next(e); }
   });

   // GET /sandbox/health
   router.get('/health', (req, res) => {
      res.json({ success: true, data: { sandbox: true, time: new Date().toISOString() } });
   });

   return router;
}
