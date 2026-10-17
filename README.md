<div align="center">

<img src="https://cdn.phototourl.com/member/2026-10-10-3d7201e5-5784-486d-9f7d-4ff90cc0bdb4.png" width="140" alt="UnoPay Logo">

# UnoPay

### Payment Gateway QRIS untuk Merchant Indonesia 🇮🇩

Self-hosted payment gateway QRIS untuk merchant Indonesia, dibangun di atas GoBiz (GoPay Merchant) milik Gojek. UnoPay adalah software pihak ketiga yang memfasilitasi QRIS dinamis dan auto-matching pembayaran, **bukan PJP resmi**.

<p>
  <a href="https://nuxt.com/">
    <img src="https://img.shields.io/badge/Nuxt%204-00DC82?style=for-the-badge&logo=nuxt.js&logoColor=white" alt="Nuxt 4">
  </a>
  <a href="https://vuejs.org/">
    <img src="https://img.shields.io/badge/Vue%203-4FC08D?style=for-the-badge&logo=vue.js&logoColor=white" alt="Vue 3">
  </a>
  <a href="https://nodejs.org/">
    <img src="https://img.shields.io/badge/Node.js%2022%2B-339933?style=for-the-badge&logo=node.js&logoColor=white" alt="Node.js 22+">
  </a>
  <a href="https://www.postgresql.org/">
    <img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL">
  </a>
  <a href="https://vercel.com/">
    <img src="https://img.shields.io/badge/Vercel-000000?style=for-the-badge&logo=vercel&logoColor=white" alt="Vercel">
  </a>
  <img src="https://img.shields.io/badge/License-MIT-blue?style=for-the-badge" alt="MIT License">
</p>

</div>

---

## ✨ Fitur

| Fitur                          | Deskripsi                                                                                                                                          |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| 💳 **QRIS Dinamis**            | Nominal pembayaran ter-encode di QR dan auto-matching melalui polling GoBiz.                                                                       |
| 📊 **Dashboard Merchant Live** | Grafik volume transaksi 7/30/90 hari, saldo settled/pending, dan notifikasi real-time.                                                             |
| 🔑 **Multi API Key**           | API key terpisah untuk environment production dan sandbox, dengan fitur regenerate dan delete dari dashboard.                                      |
| 🏦 **Penarikan Dana**          | Fee persentase + flat yang dapat dikonfigurasi dari admin panel, bank picker 25+ bank Indonesia dengan logo, serta penyimpanan rekening.           |
| 🔐 **2FA TOTP**                | Two-factor authentication menggunakan Google Authenticator dengan toggle aktif/nonaktif dari profil.                                               |
| 🛡️ **Panel Admin**            | Kelola user, ban/unban, transaksi, approval withdrawal, fee transaksi, minimum/fee withdrawal, branding, maintenance mode, dan override logo bank. |
| 🧪 **Sandbox**                 | API key `rp_test_` menggunakan tabel `transactions_sandbox` terpisah tanpa polling GoBiz dan tanpa uang asli.                                      |
| 📚 **Interactive Docs**        | Dokumentasi interaktif di `/docs` dengan contoh cURL, Node.js, PHP, dan Python serta base URL otomatis dari environment.                           |
| 🔧 **Maintenance Mode**        | Halaman maintenance khusus tanpa menghentikan pembayaran QRIS maupun webhook.                                                                      |
| 🔔 **Notifikasi**              | Notifikasi in-app dan email menggunakan Resend.                                                                                                    |

---

## 🏗️ Arsitektur

```text
┌───────────────────────┐
│    Merchant Server    │
└───────────┬───────────┘
            │
            │ POST /api/v1/qris/create
            │ Authorization: Bearer <API_KEY>
            ▼
┌───────────────────────────────┐
│            UnoPay             │
│         Vercel / VPS          │
│                               │
│    API → Payment Logic → DB   │
└───────────┬───────────────────┘
            │
            │ qr_image
            ▼
┌───────────────────────┐
│   Customer / Buyer    │
│       Scan QRIS       │
└───────────┬───────────┘
            │
            │ Payment
            ▼
┌───────────────────────┐
│         GoBiz         │
│     GoPay Merchant    │
└───────────┬───────────┘
            │
            │ Polling
            ▼
┌───────────────────────────────┐
│        UnoPay Poller          │
│      Auto-match transaksi     │
└───────────┬───────────────────┘
            │
            │ POST callback_url
            │ X-Signature: HMAC-SHA256
            ▼
┌───────────────────────┐
│    Merchant Webhook   │
└───────────────────────┘
```

---

## 🚀 Deploy ke Vercel + Neon (5 menit)

### 1. Buat database PostgreSQL

Buat project PostgreSQL di [Neon](https://neon.tech/) lalu copy connection string yang diberikan.

Import `schema-clean.sql` melalui **Neon SQL Editor**.

### 2. Import repository ke Vercel

Fork repository UnoPay:

```text
https://github.com/RONI-PROJECT/UnoPay
```

Kemudian import repository tersebut ke [Vercel](https://vercel.com/).

### 3. Set environment variables

Masukkan environment variables pada:

```text
Vercel → Project → Settings → Environment Variables
```

Minimal production:

```env
DATABASE_URL=postgresql://...
PUBLIC_URL=https://unopayvip.vercel.app
PUBLIC_API_BASE_URL=https://unopayvip.vercel.app
QRIS_STRING=...
GOPAY_EMAIL=...
GOPAY_PASSWORD=...
API_KEY=rp_live_xxx
WEBHOOK_SECRET=...
ADMIN_USERNAME=...
ADMIN_PASSWORD=...
```

### 4. Deploy

Klik **Deploy** dan tunggu proses build selesai.

Aplikasi:

```text
https://unopayvip.vercel.app
```

Panel admin:

```text
https://unopayvip.vercel.app/panel/login
```

---

## 🖥️ Deploy ke VPS — Ubuntu 22.04

### Install dependency

```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt install -y nodejs postgresql nginx certbot python3-certbot-nginx
```

### Buat database PostgreSQL

```bash
sudo -u postgres psql
```

Kemudian:

```sql
CREATE DATABASE unopay;
CREATE USER uno WITH ENCRYPTED PASSWORD 'GANTI_PASSWORD_DATABASE';
GRANT ALL PRIVILEGES ON DATABASE unopay TO uno;
```

Keluar:

```sql
\q
```

### Clone repository

```bash
cd /var/www
git clone https://github.com/RONI-PROJECT/UnoPay.git
cd UnoPay
```

### Install dependency dan import schema

```bash
npm install
psql "postgresql://uno:GANTI_PASSWORD_DATABASE@localhost/unopay" -f schema-clean.sql
```

### Setup environment

```bash
cp .env.example .env
nano .env
```

Isi seluruh variable sesuai konfigurasi server.

### Build dan jalankan PM2

```bash
npm run build
npm i -g pm2
pm2 start ecosystem.config.cjs
pm2 save
pm2 startup
```

### Nginx reverse proxy

Contoh konfigurasi:

```nginx
server {
    listen 80;
    server_name pay.domainmu.com;

    location / {
        proxy_pass http://127.0.0.1:3000;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Test konfigurasi:

```bash
nginx -t
systemctl reload nginx
```

### SSL dengan Certbot

```bash
certbot --nginx -d pay.domainmu.com
```

---

## ⏰ Cron — Auto-Poll

Untuk production, jalankan polling secara berkala agar transaksi tetap dapat di-match walaupun halaman pembayaran customer tidak sedang dibuka.

| Setting            | Nilai                                    |
| ------------------ | ---------------------------------------- |
| **Method**         | `POST`                                   |
| **Endpoint**       | `/api/admin/poll`                        |
| **Interval**       | Setiap 1 menit                           |
| **Authentication** | `Authorization: Bearer <API_KEY>`        |
| **Tujuan**         | Menjalankan polling GoBiz secara berkala |

Contoh:

```bash
curl -X POST "https://unopayvip.vercel.app/api/admin/poll" \
  -H "Authorization: Bearer ${API_KEY}"
```

### Crontab VPS

Buka crontab:

```bash
crontab -e
```

Tambahkan:

```cron
* * * * * curl -s -X POST "https://unopayvip.vercel.app/api/admin/poll" -H "Authorization: Bearer $API_KEY" >/dev/null 2>&1
```

Tanpa cron, pembayaran tetap dapat terdeteksi ketika customer membuka halaman bayar karena menggunakan **request-driven polling**.

Namun, cron tetap disarankan karena menjamin proses matching tetap berjalan meskipun halaman pembayaran tidak dibuka.

---

## 📚 API v1

### Base URL

Production:

```text
https://unopayvip.vercel.app
```

Semua endpoint API v1 menggunakan authentication header:

```http
Authorization: Bearer <API_KEY>
```

Format key production:

```text
rp_live_xxx
```

Format key sandbox:

```text
rp_test_xxx
```

> API v1 menggunakan endpoint `/api/v1/qris/*`. Endpoint lama tidak digunakan.

---

### 1. POST `/api/v1/qris/create`

Membuat transaksi QRIS dinamis baru.

#### Request

```bash
curl -X POST "https://unopayvip.vercel.app/api/v1/qris/create" \
  -H "Authorization: Bearer rp_live_xxx" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 50000,
    "reference": "ORDER-123",
    "callback_url": "https://toko.com/webhook",
    "expires_minutes": 15,
    "metadata": {}
  }'
```

#### Body

```json
{
  "amount": 50000,
  "reference": "ORDER-123",
  "callback_url": "https://toko.com/webhook",
  "expires_minutes": 15,
  "metadata": {}
}
```

| Field             | Status   | Keterangan                                        |
| ----------------- | -------- | ------------------------------------------------- |
| `amount`          | Wajib    | Nominal pembayaran. Minimum `1000`.               |
| `reference`       | Opsional | Reference unik transaksi.                         |
| `callback_url`    | Opsional | URL webhook merchant. Wajib HTTPS jika digunakan. |
| `expires_minutes` | Opsional | Durasi expiry QRIS.                               |
| `metadata`        | Opsional | Object bebas yang akan dikembalikan pada webhook. |

#### Response `201`

```json
{
  "success": true,
  "data": {
    "reference": "ORDER-123",
    "status": "PENDING",
    "payment_method": "QRIS",
    "amount": 50000,
    "fee": 900,
    "total": 50000,
    "qr_string": "00020101021226...",
    "qr_image": "https://unopayvip.vercel.app/api/v1/qris/ORDER-123/qr",
    "expires_at": "2026-10-15T07:15:00.000Z",
    "created_at": "2026-10-15T07:00:00.000Z"
  }
}
```

#### Error

```json
{
  "success": false,
  "error": "..."
}
```

| HTTP Status | Error                      |
| ----------: | -------------------------- |
|       `400` | `invalid_body`             |
|       `401` | `unauthorized`             |
|       `403` | `key_diblokir`             |
|       `404` | `not_found`                |
|       `409` | `reference_already_exists` |
|       `429` | `rate_limited`             |
|       `500` | Internal server error      |

---

### 2. GET `/api/v1/qris/:reference`

Digunakan untuk mengecek status transaksi berdasarkan reference.

#### Request

```bash
curl "https://unopayvip.vercel.app/api/v1/qris/ORDER-123" \
  -H "Authorization: Bearer rp_live_xxx"
```

#### Status

```text
PENDING → PAID
        ↘ EXPIRED
```

Response menggunakan struktur yang sama seperti create QRIS dengan tambahan:

* `net`
* `paid_at`

Contoh:

```json
{
  "success": true,
  "data": {
    "reference": "ORDER-123",
    "status": "PAID",
    "payment_method": "QRIS",
    "amount": 50000,
    "fee": 900,
    "total": 50000,
    "net": 49100,
    "qr_string": "00020101021226...",
    "qr_image": "https://unopayvip.vercel.app/api/v1/qris/ORDER-123/qr",
    "expires_at": "2026-10-15T07:15:00.000Z",
    "created_at": "2026-10-15T07:00:00.000Z",
    "paid_at": "2026-10-15T07:05:00.000Z"
  }
}
```

Jika reference tidak ditemukan, API mengembalikan `404`.

---

### 3. GET `/api/v1/qris/:reference/qr`

Mengambil QRIS dalam bentuk PNG secara langsung.

```bash
curl "https://unopayvip.vercel.app/api/v1/qris/ORDER-123/qr" \
  -H "Authorization: Bearer rp_live_xxx" \
  --output qris.png
```

Response berupa:

```text
PNG
Cache-Control: immutable
```

QR dapat langsung di-embed:

```html
<img
  src="https://unopayvip.vercel.app/api/v1/qris/ORDER-123/qr"
  alt="QRIS ORDER-123"
/>
```

---

## 🔔 Webhook

Jika `callback_url` diberikan ketika membuat QRIS, UnoPay akan mengirim webhook ketika payment berubah menjadi:

```text
payment.paid
payment.expired
```

Request dikirim ke:

```http
POST https://toko.com/webhook
```

### Payload `payment.paid`

```json
{
  "event": "payment.paid",
  "data": {
    "reference": "ORDER-123",
    "status": "PAID",
    "payment_method": "QRIS",
    "amount": 50000,
    "fee": 900,
    "net": 49100,
    "currency": "IDR",
    "paid_at": "2026-10-15T07:05:00.000Z",
    "metadata": {}
  }
}
```

### Headers

```http
X-Event: payment.paid
X-Reference: ORDER-123
X-Signature: <HMAC-SHA256>
```

`X-Signature` dihitung menggunakan:

```text
HMAC-SHA256(rawBody, WEBHOOK_SECRET)
```

Output signature berupa hexadecimal.

UnoPay akan melakukan retry sebanyak **12 kali** menggunakan exponential backoff.

### Verifikasi Webhook — Node.js

```js
import crypto from 'crypto'

const expected = crypto
  .createHmac('sha256', process.env.WEBHOOK_SECRET)
  .update(req.body)
  .digest('hex')

if (
  !crypto.timingSafeEqual(
    Buffer.from(expected),
    Buffer.from(req.headers['x-signature'] || '')
  )
) {
  return res.status(403).send('invalid signature')
}
```

> **Penting:** gunakan `express.raw({ type: 'application/json' })` agar HMAC dihitung menggunakan raw body yang sama persis dengan body yang dikirim UnoPay.

---

## 📖 Interactive API Docs

Dokumentasi interaktif tersedia di:

```text
https://unopayvip.vercel.app/docs
```

Tersedia contoh integrasi:

```text
cURL
Node.js
PHP
Python
```

Base URL otomatis mengikuti environment aplikasi.

---

## 💻 Contoh Integrasi

Gunakan environment variables berikut:

```env
UNOPAY_URL=https://unopayvip.vercel.app
UNOPAY_API_KEY=rp_live_xxx
```

### PHP

```php
<?php

$baseUrl = getenv('UNOPAY_URL');
$apiKey  = getenv('UNOPAY_API_KEY');

$payload = [
    'amount' => 50000,
    'reference' => 'ORDER-123',
    'callback_url' => 'https://toko.com/webhook',
    'expires_minutes' => 15,
    'metadata' => []
];

$ch = curl_init($baseUrl . '/api/v1/qris/create');

curl_setopt_array($ch, [
    CURLOPT_POST => true,
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTPHEADER => [
        'Authorization: Bearer ' . $apiKey,
        'Content-Type: application/json'
    ],
    CURLOPT_POSTFIELDS => json_encode($payload)
]);

$response = curl_exec($ch);

if ($response === false) {
    throw new Exception(curl_error($ch));
}

curl_close($ch);

$data = json_decode($response, true);

echo $data['data']['qr_image'] ?? '';
```

### Node.js

```js
const baseUrl = process.env.UNOPAY_URL
const apiKey = process.env.UNOPAY_API_KEY

const response = await fetch(`${baseUrl}/api/v1/qris/create`, {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${apiKey}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    amount: 50000,
    reference: 'ORDER-123',
    callback_url: 'https://toko.com/webhook',
    expires_minutes: 15,
    metadata: {}
  })
})

const data = await response.json()

console.log(data)
```

### Python

```python
import os
import requests

base_url = os.environ["UNOPAY_URL"]
api_key = os.environ["UNOPAY_API_KEY"]

payload = {
    "amount": 50000,
    "reference": "ORDER-123",
    "callback_url": "https://toko.com/webhook",
    "expires_minutes": 15,
    "metadata": {}
}

response = requests.post(
    f"{base_url}/api/v1/qris/create",
    headers={
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    },
    json=payload,
    timeout=30
)

response.raise_for_status()

data = response.json()

print(data)
```

---

## ⚙️ Environment Variables

### Wajib ✅

| Variable              | Wajib | Deskripsi                                                    |
| --------------------- | :---: | ------------------------------------------------------------ |
| `DATABASE_URL`        |   ✅   | PostgreSQL connection string untuk Neon atau PostgreSQL VPS. |
| `PUBLIC_URL`          |   ✅   | URL publik aplikasi yang digunakan pada `qr_image` dan docs. |
| `PUBLIC_API_BASE_URL` |   ✅   | Base URL API publik.                                         |
| `QRIS_STRING`         |   ✅   | String QRIS statis GoBiz.                                    |
| `GOPAY_EMAIL`         |   ✅   | Email akun GoBiz.                                            |
| `GOPAY_PASSWORD`      |   ✅   | Password akun GoBiz.                                         |
| `API_KEY`             |   ✅   | Static key fallback.                                         |
| `WEBHOOK_SECRET`      |   ✅   | Secret HMAC untuk verifikasi webhook.                        |
| `ADMIN_USERNAME`      |   ✅   | Username panel admin.                                        |
| `ADMIN_PASSWORD`      |   ✅   | Password panel admin.                                        |

Generate `WEBHOOK_SECRET`:

```bash
openssl rand -hex 32
```

### Opsional ❌

| Variable                         | Wajib | Deskripsi                                                                 |
| -------------------------------- | :---: | ------------------------------------------------------------------------- |
| `GOPAY_MERCHANT_ID`              |   ❌   | Merchant ID GoPay/GoBiz.                                                  |
| `NUXT_PUBLIC_TURNSTILE_SITE_KEY` |   ❌   | Site key Cloudflare Turnstile.                                            |
| `TURNSTILE_SECRET_KEY`           |   ❌   | Secret key Cloudflare Turnstile.                                          |
| `EXPIRE_MINUTES`                 |   ❌   | Durasi expiry default. Default `5`.                                       |
| `POLL_MIN_INTERVAL_MS`           |   ❌   | Interval minimum polling dalam milidetik. Default `7000`, minimum `7000`. |
| `SANDBOX_MODE`                   |   ❌   | Mode sandbox: `0` atau `1`.                                               |
| `TRUST_PROXY`                    |   ❌   | Isi `1` jika aplikasi berada di balik proxy.                              |
| `PORT`                           |   ❌   | Port aplikasi. Default `3000`.                                            |

Contoh `.env`:

```env
DATABASE_URL=postgresql://...

PUBLIC_URL=https://unopayvip.vercel.app
PUBLIC_API_BASE_URL=https://unopayvip.vercel.app

QRIS_STRING=...

GOPAY_EMAIL=...
GOPAY_PASSWORD=...

API_KEY=rp_live_xxx
WEBHOOK_SECRET=...

ADMIN_USERNAME=admin
ADMIN_PASSWORD=...

GOPAY_MERCHANT_ID=...

NUXT_PUBLIC_TURNSTILE_SITE_KEY=...
TURNSTILE_SECRET_KEY=...

EXPIRE_MINUTES=5
POLL_MIN_INTERVAL_MS=7000
SANDBOX_MODE=0
TRUST_PROXY=1
PORT=3000
```

---

## 🧪 Sandbox

UnoPay menyediakan environment sandbox menggunakan API key dengan prefix:

```text
rp_test_
```

Sandbox memiliki karakteristik:

* Menggunakan endpoint yang identik dengan production.
* Data transaksi disimpan pada tabel `transactions_sandbox` yang terpisah.
* Tidak melakukan polling GoBiz.
* Tidak menggunakan uang asli.
* Cocok untuk pengembangan dan pengujian integrasi merchant.

Production:

```text
rp_live_xxx
```

Sandbox:

```text
rp_test_xxx
```

Pemisahan database memastikan transaksi testing tidak tercampur dengan transaksi production.

---

## 🆘 Troubleshooting

| Masalah                                | Solusi                                                                                                           |
| -------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `FUNCTION_INVOCATION_FAILED` di Vercel | Periksa environment variables, terutama `DATABASE_URL` dan `QRIS_STRING`.                                        |
| `unauthorized` pada API v1             | Pastikan API key benar, belum expired, dan masih active. Cek dashboard Kredensial.                               |
| `reference_already_exists`             | Ganti `reference`, atau retry menggunakan header `idempotency-key` yang sama.                                    |
| Pembayaran tidak ke-match              | Pastikan cron polling berjalan dan API key untuk polling sudah benar.                                            |
| Webhook tidak diterima                 | Pastikan `callback_url` adalah HTTPS publik dan verifikasi `X-Signature` menggunakan `WEBHOOK_SECRET` yang sama. |
| Session GoBiz expired                  | Session akan melakukan re-auth otomatis. Cek `/api/health` → `data.session.ok`.                                  |
| Build error di Termux/sdcard           | Pindahkan project ke storage internal karena storage SD card dapat memiliki masalah `noexec`.                    |

Health check:

```text
https://unopayvip.vercel.app/api/health
```

---

## 🗺️ Struktur Proyek

```text
UnoPay/
├── src/
│   ├── app.js                 # Express + route mounting
│   ├── config.js              # Env config
│   ├── security.js            # Bearer auth, rate limit, HMAC, SSRF guard
│   │
│   ├── routes/
│   │   ├── payments.js        # API v1 — /api/v1/qris/*
│   │   ├── public.js          # /api/public/* (settings, stats)
│   │   ├── auth.js            # Login, register, 2FA
│   │   ├── user-payments.js   # Dashboard merchant
│   │   ├── admin.js           # Admin + poll
│   │   └── sandbox.js         # Sandbox
│   │
│   ├── services/
│   │   ├── payments.js        # Business logic transaksi
│   │   ├── poller.js          # GoBiz polling engine
│   │   ├── webhooks.js        # Webhook delivery + retry
│   │   ├── session.js         # GoBiz session manager
│   │   └── notifications.js
│   │
│   └── db/
│
├── web/                       # Nuxt frontend
│   ├── pages/                 # Landing, docs, merchant, panel, pay
│   ├── components/
│   └── composables/
│
└── schema-clean.sql
```

---

## 🤝 Kontribusi

Kontribusi dipersilakan.

1. Fork repository UnoPay.
2. Buat branch baru untuk perubahan.
3. Implementasikan perubahan tanpa merusak API v1 yang sudah ditetapkan.
4. Gunakan sandbox untuk pengujian integrasi.
5. Pastikan perubahan sudah ditest sebelum membuat Pull Request.
6. Buat Pull Request dengan deskripsi perubahan yang jelas.

Repository:

```text
https://github.com/RONI-PROJECT/UnoPay
```

---

## 📜 Lisensi

UnoPay dirilis di bawah lisensi **MIT**.

```text
MIT © 2026 UnoPay
```

---

<div align="center">

Dibuat dengan ❤️ untuk merchant Indonesia

⭐ **Jika UnoPay membantu project kamu, jangan lupa kasih Star di repository.**

</div>
