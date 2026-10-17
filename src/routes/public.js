import { Router } from 'express';
import { one, all, sql } from '../db/index.js';

export function publicRoutes() {
   const router = Router();

   router.get('/settings', async (req, res, next) => {
      try {
         const rows = await all('SELECT key, value FROM app_settings');
         const map = {};
         rows.forEach(r => { map[r.key] = r.value; });
         res.json({ success: true, data: {
            maintenance: map.maintenance_mode === 'true',
            maintenance_mode: map.maintenance_mode || 'false',
            maintenance_message: map.maintenance_message || '',
            maintenance_eta: map.maintenance_eta || '',
            message: map.maintenance_message || '',
            site_name: map.site_name || 'UnoPay',
            site_title: map.site_title || 'UnoPay — Payment Gateway QRIS',
            site_description: map.site_description || '',
            site_keywords: map.site_keywords || '',
            logo_url: map.logo_url || '',
            favicon_url: map.favicon_url || '',
            hero_title: map.hero_title || '',
            hero_lead: map.hero_lead || '',
            marquee_text: map.marquee_text || '',
            marquee_items: map.marquee_items || '',
            footer_text: map.footer_text || '',
            footer_copyright: map.footer_copyright || '',
            wd_min: Number(map.wd_min || 65000),
            wd_fee_percent: Number(map.wd_fee_percent || 2.5),
            wd_fee_flat: Number(map.wd_fee_flat || 4500),
            fee_transaction_percent: Number(map.fee_transaction_percent || 1.8),
         }});
      } catch (e) { next(e); }
   });

   let statsCache = null;
   let statsCacheAt = 0;

   router.get('/stats', async (req, res, next) => {
      try {
         const now = Date.now();
         if (statsCache && now - statsCacheAt < 10000) {
            return res.json({ success: true, data: statsCache });
         }
         const row = await one("SELECT COUNT(*) FILTER (WHERE status = $1) AS paid, COUNT(*) AS total, COALESCE(SUM(amount) FILTER (WHERE status = $1), 0) AS \"totalVolume\" FROM transactions", ['PAID']);
         const merchants = await one('SELECT COUNT(*) AS c FROM users');
         const data = {
            paid: Number(row.paid),
            total: Number(row.total),
            totalVolume: Number(row.totalVolume),
            activeMerchants: Number(merchants.c),
         };
         statsCache = data;
         statsCacheAt = now;
         res.json({ success: true, data });
      } catch (e) { next(e); }
   });

   router.get('/live', async (req, res, next) => {
      try {
         const rows = await all('SELECT RIGHT("trxId", 6) AS id, amount, status FROM transactions ORDER BY "createdAt" DESC LIMIT 5');
         res.json({ success: true, data: rows.map(r => ({
            id: r.id,
            amount: Number(r.amount),
            status: r.status === 'PAID' ? 'paid' : (r.status === 'PENDING' ? 'yellow' : 'gray'),
         }))});
      } catch (e) { next(e); }
   });

   router.get('/payment/:trxId', async (req, res, next) => {
      try {
         const trx = await one('SELECT "trxId", status, amount, fee, "payAmount", "qrString", "createdAt", "expiresAt", "paidAt", metadata FROM transactions WHERE "trxId" = $1', [req.params.trxId]);
         if (!trx) return res.status(404).json({ error: 'Transaksi tidak ditemukan' });
         if (trx.status === 'PENDING' && new Date(trx.expiresAt).getTime() <= Date.now()) {
            await sql('UPDATE transactions SET status = $1 WHERE "trxId" = $2 AND status = $3', ['EXPIRED', req.params.trxId, 'PENDING']);
            trx.status = 'EXPIRED';
         }
         res.json({ success: true, data: trx });
      } catch (e) { next(e); }
   });

   return router;
}