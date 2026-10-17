import bcrypt from 'bcryptjs';
import crypto from 'node:crypto';
import { sql, one } from '../db/index.js';

export const hashPassword = (plain) => bcrypt.hash(plain, 10);
export const verifyPassword = (plain, hash) => bcrypt.compare(plain, hash);
export const generateToken = (bytes = 32) => crypto.randomBytes(bytes).toString('hex');

export async function createSession(userId, ip, ua) {
   const token = generateToken();
   const now = new Date().toISOString();
   const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString();
   await sql(
      `INSERT INTO sessions (token, "userId", "createdAt", "expiresAt", "ipAddress", "userAgent")
       VALUES ($1,$2,$3,$4,$5,$6)`,
      [token, userId, now, expiresAt, ip, ua]
   );
   return { token, expiresAt };
}

export async function getSession(token) {
   if (!token) return null;
   return await one(
      `SELECT s.*, u.email, u.name, u.role, u.status AS "userStatus"
       FROM sessions s JOIN users u ON u.id = s."userId"
       WHERE s.token = $1 AND s."expiresAt" > $2`,
      [token, new Date().toISOString()]
   );
}

export async function deleteSession(token) {
   await sql('DELETE FROM sessions WHERE token = $1', [token]);
}

function genMerchantCode() {
   const ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
   let s = '';
   for (let i = 0; i < 6; i++) s += ALPHABET[Math.floor(Math.random() * ALPHABET.length)];
   return 'MRC-' + s;
}

export async function createUser({ email, password, name, phone, role = 'user' }) {
   const hash = await hashPassword(password);
   const now = new Date().toISOString();

   // Generate merchant_code unik (retry kalau bentrok)
   let merchantCode = null;
   for (let tries = 0; tries < 10; tries++) {
      const code = genMerchantCode();
      const exists = await one('SELECT id FROM users WHERE merchant_code = $1', [code]);
      if (!exists) { merchantCode = code; break; }
   }

   return await one(
      `INSERT INTO users (email, password, name, phone, role, merchant_code, "createdAt")
       VALUES ($1,$2,$3,$4,$5,$6,$7)
       RETURNING id, email, name, phone, role, merchant_code, "createdAt"`,
      [email.toLowerCase(), hash, name, phone || null, role, merchantCode, now]
   );
}
