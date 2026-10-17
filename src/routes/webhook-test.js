import { Router } from 'express';
import crypto from 'node:crypto';
import { one, sql } from '../db/index.js';
import { getSession } from '../services/auth.js';

export function webhookTestRoutes() {
   const router = Router();

   async function requireUser(req, res, next) {
      try {
         const token = req.cookies?.session || req.headers['x-session-token'];
         const s = await getSession(token);
         if (!s) return res.status(401).json({ error: 'Login required' });
         req.user = { id: s.userId };
         next();
      } catch (e) { next(e); }
   }

   router.post('/test', requireUser, async (req, res, next) => {
      try {
         const user = await one(
            'SELECT "webhookUrl", "webhookSecret" FROM users WHERE id = $1',
            [req.user.id]
         );
         if (!user?.webhookUrl) return res.status(400).json({ error: 'Webhook URL belum di-set' });
         if (!user?.webhookSecret) return res.status(400).json({ error: 'Webhook secret belum di-set' });

         const payload = {
            event: 'webhook.test',
            trxId: 'TRX-TEST-' + Date.now(),
            status: 'PAID',
            amount: 10000,
            amountToPay: 10042,
            paidAt: new Date().toISOString(),
            metadata: { test: true },
         };
         const rawBody = JSON.stringify(payload);
         const signature = 'sha256=' + crypto
            .createHmac('sha256', user.webhookSecret)
            .update(rawBody)
            .digest('hex');

         const started = Date.now();
         let status = 0;
         let errorMsg = null;
         let success = false;

         try {
            const controller = new AbortController();
            const timeout = setTimeout(() => controller.abort(), 10_000);

            const r = await fetch(user.webhookUrl, {
               method: 'POST',
               headers: {
                  'Content-Type': 'application/json',
                  'X-Signature': signature,
                  'X-Event': 'webhook.test',
                  'X-Trx-Id': payload.trxId,
               },
               body: rawBody,
               signal: controller.signal,
            });
            clearTimeout(timeout);
            status = r.status;
            await r.text();
            success = status >= 200 && status < 300;
            if (!success) errorMsg = `HTTP ${status}`;
         } catch (e) {
            errorMsg = e.name === 'AbortError' ? 'Timeout 10s' : (e.cause?.code || e.message);
         }

         const latencyMs = Date.now() - started;

         // Simpan log
         try {
            await sql(
               `INSERT INTO webhook_logs
                (user_id, trx_id, event, url, http_status, latency_ms, status, error, sent_at)
                VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)`,
               [
                  req.user.id,
                  payload.trxId,
                  'webhook.test',
                  user.webhookUrl,
                  status || null,
                  latencyMs,
                  success ? 'delivered' : 'failed',
                  errorMsg,
                  new Date().toISOString(),
               ]
            );
         } catch (logErr) {
            console.error('[webhook-test] gagal simpan log:', logErr.message);
         }

         if (!success) {
            return res.json({
               success: false,
               error: errorMsg || 'Gagal kirim',
               url: user.webhookUrl,
               latencyMs,
            });
         }

         res.json({
            success: true,
            data: {
               url: user.webhookUrl,
               status,
               durationMs: latencyMs,
               signature,
               payload,
            },
         });
      } catch (e) { next(e); }
   });

   return router;
}
