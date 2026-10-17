
<div align="center">

# <span style="color:#00DC82">TokoPayVIP</span>

### QRIS PAYMENT GATEWAY

**Infrastruktur pembayaran digital untuk integrasi bisnis modern.**

API pembayaran QRIS dengan pengelolaan transaksi, merchant API key, dan webhook callback.

<br/>

[![Website](https://img.shields.io/badge/WEBSITE-tokopayvip.vercel.app-00DC82?style=for-the-badge&logo=vercel&logoColor=white)](https://tokopayvip.vercel.app)
[![Dokumentasi](https://img.shields.io/badge/API_DOCS-Baca_Dokumentasi-1687FF?style=for-the-badge&logo=readthedocs&logoColor=white)](https://tokopayvip.vercel.app/docs)
[![Repository](https://img.shields.io/badge/GITHUB-Source_Code-24292F?style=for-the-badge&logo=github&logoColor=white)](https://github.com/RONI-PROJECT/TokoPay)

<br/>

[![Stars](https://img.shields.io/github/stars/RONI-PROJECT/TokoPay?style=social)](https://github.com/RONI-PROJECT/TokoPay/stargazers)
[![Forks](https://img.shields.io/github/forks/RONI-PROJECT/TokoPay?style=social)](https://github.com/RONI-PROJECT/TokoPay/forks)
[![Issues](https://img.shields.io/github/issues/RONI-PROJECT/TokoPay?style=social)](https://github.com/RONI-PROJECT/TokoPay/issues)

</div>

---

## Tentang TokoPayVIP

TokoPayVIP adalah payment gateway QRIS yang menggunakan Nuxt 3 untuk frontend, Express.js untuk backend, serta PostgreSQL melalui Neon sebagai database.

Sistem menyediakan endpoint transaksi QRIS, autentikasi API, pengelolaan API key merchant, callback webhook, dan fitur pendukung administrasi sesuai implementasi proyek.

## Informasi Proyek

| Informasi | Detail |
|---|---|
| Nama | TokoPayVIP |
| Repository | [RONI-PROJECT/TokoPay](https://github.com/RONI-PROJECT/TokoPay) |
| Website | [tokopayvip.vercel.app](https://tokopayvip.vercel.app) |
| Dokumentasi | [tokopayvip.vercel.app/docs](https://tokopayvip.vercel.app/docs) |
| Frontend | Nuxt 3 |
| Backend | Express.js ESM |
| Database | PostgreSQL Neon |
| QR Generator | `qrcode` |
| Process Manager | PM2 |
| Frontend Hosting | Vercel |

## Technology Stack

<div align="center">

[![Nuxt](https://img.shields.io/badge/Nuxt_3-00DC82?style=for-the-badge&logo=nuxt.js&logoColor=white)](https://nuxt.com/)
[![Express](https://img.shields.io/badge/Express.js-111111?style=for-the-badge&logo=express&logoColor=white)](https://expressjs.com/)
[![Node](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://nodejs.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Vercel](https://img.shields.io/badge/Vercel-000000?style=for-the-badge&logo=vercel&logoColor=white)](https://vercel.com/)
[![PM2](https://img.shields.io/badge/PM2-2B037A?style=for-the-badge&logo=pm2&logoColor=white)](https://pm2.keymetrics.io/)
[![QR Code](https://img.shields.io/badge/QR_Code-qrcode-333333?style=for-the-badge)](https://www.npmjs.com/package/qrcode)

</div>

## Fitur

### Payment API

- Pembuatan transaksi QRIS.
- Reference transaksi otomatis.
- Pengambilan detail transaksi.
- QR string dan QR image.
- Perhitungan biaya transaksi.
- Pengaturan masa berlaku.
- Pembatalan transaksi.
- Replay webhook.
- Idempotency key.
- Metadata transaksi.

### Merchant Dashboard

- Dashboard merchant.
- Dokumentasi API.
- Pengelolaan API key.
- Environment live dan test.
- Pengaturan QRIS.
- Konfigurasi webhook.
- Pengaturan akun.
- Halaman penarikan dana.

### Admin Panel

- Pengelolaan pengguna.
- Pengelolaan transaksi.
- Pengelolaan penarikan.
- Pengaturan sistem.
- Pengelolaan logo bank.

### Infrastruktur

- Frontend Nuxt 3.
- Backend Express.js.
- PostgreSQL melalui Neon.
- QR code menggunakan package `qrcode`.
- Pengelolaan proses menggunakan PM2.
- Deployment frontend melalui Vercel.

## Arsitektur Sistem

Arsitektur aplikasi menggunakan alur sederhana berikut:

```text
Merchant / Pengguna
        |
        v
  Nuxt 3 Frontend
        |
        v
   Express.js API
        |
        +---- Autentikasi dan Validasi
        |
        +---- Payment Routes
        |          |
        |          v
        |     Payment Service
        |          |
        |          +---- PostgreSQL Neon
        |          |
        |          +---- QR Code Generator
        |
        +---- Webhook Service
                   |
                   v
           Merchant Callback URL
```

Diagram teks ini sengaja digunakan agar ringan, cepat dimuat, dan mudah dibaca melalui browser HP tanpa renderer diagram tambahan.

## Struktur Proyek

```text
TokoPay/
├── web/
│   ├── pages/
│   │   ├── index.vue
│   │   ├── docs/
│   │   ├── login.vue
│   │   ├── register.vue
│   │   ├── tos.vue
│   │   ├── privacy.vue
│   │   ├── disclaimer.vue
│   │   ├── maintenance.vue
│   │   ├── pay/
│   │   ├── merchant/
│   │   └── panel/
│   ├── layouts/
│   ├── components/
│   ├── composables/
│   ├── middleware/
│   └── plugins/
├── src/
│   ├── app.js
│   ├── config.js
│   ├── security.js
│   ├── db/
│   │   └── index.js
│   ├── routes/
│   │   ├── payments.js
│   │   ├── sandbox.js
│   │   ├── auth.js
│   │   ├── user-extra.js
│   │   ├── admin-panel.js
│   │   └── system.js
│   └── services/
│       ├── payments.js
│       ├── webhooks.js
│       ├── auth.js
│       ├── notifications.js
│       └── poller.js
├── ecosystem.config.cjs
├── package.json
└── README.md
```

## Instalasi

### Persyaratan

- Node.js yang kompatibel dengan dependensi proyek.
- npm.
- Database PostgreSQL atau Neon.
- Git.

### 1. Clone Repository

```bash
git clone https://github.com/RONI-PROJECT/TokoPay.git
cd TokoPay
```

### 2. Install Backend

```bash
npm install
```

### 3. Install Frontend

```bash
cd web
npm install
```

## Konfigurasi Environment

Backend menggunakan konfigurasi dari `src/config.js`.

Contoh konfigurasi database dan autentikasi:

```env
DATABASE_URL=postgresql://USER:PASSWORD@HOST/DATABASE?sslmode=require
API_KEY=GANTI_DENGAN_MASTER_API_KEY
SANDBOX_MODE=false
```

Konfigurasi lain mencakup URL publik, batas nominal, dan masa berlaku transaksi. Isi nama serta nilai environment sesuai implementasi aktual di `src/config.js`.

**Penting:** Jangan menyimpan master API key atau password database di repository publik.

## Menjalankan Aplikasi

### Backend

Jalankan script yang tersedia dalam `package.json`.

```bash
npm run dev
```

### Frontend

```bash
cd web
npm run dev
```

### Build Frontend

```bash
cd web
npm run build
```

### PM2

Jika konfigurasi `ecosystem.config.cjs` sudah tersedia:

```bash
pm2 start ecosystem.config.cjs
pm2 status
pm2 logs
pm2 save
```

## API Reference

**Base URL**

```text
https://tokopayvip.vercel.app
```

**API Prefix**

```text
/api/v1
```

| Method | Endpoint | Keterangan |
|---|---|---|
| `POST` | `/api/v1/qris/create` | Membuat transaksi QRIS |
| `GET` | `/api/v1/qris/:reference` | Mengambil detail transaksi |
| `GET` | `/api/v1/qris/:reference/qr` | Mengambil QR image |
| `POST` | `/api/v1/qris/:reference/cancel` | Meminta pembatalan |
| `POST` | `/api/v1/qris/:reference/replay-webhook` | Meminta replay webhook |

## Autentikasi

Endpoint API menggunakan header:

```http
Authorization: Bearer YOUR_API_KEY
```

Backend menerima master API key dari konfigurasi atau API key merchant yang terdaftar pada tabel `api_keys`. Pencocokan key dilakukan menggunakan nilai yang sama persis.

## Membuat Transaksi QRIS

**Endpoint**

```http
POST /api/v1/qris/create
```

**Request body**

```json
{
  "amount": 10000,
  "reference": "ORDER-001",
  "description": "Pembayaran pesanan",
  "callback_url": "https://merchant.example.com/callback",
  "expires_minutes": 15,
  "metadata": {
    "order_id": "ORDER-001"
  }
}
```

### Parameter Request

| Field | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `amount` | Integer | Ya | Nominal transaksi |
| `reference` | String | Tidak | Reference merchant, 1–64 karakter |
| `callback_url` | String | Tidak | URL callback tervalidasi |
| `callback_secret` | String | Tidak | Panjang 8–256 karakter |
| `expires_minutes` | Integer | Tidak | Masa berlaku transaksi |
| `fee` | Number | Tidak | Biaya transaksi |
| `description` | String | Tidak | Maksimal 200 karakter |
| `metadata` | Object | Tidak | Metadata tambahan |
| `idempotency_key` | String | Tidak | Kunci idempotensi |

### Ketentuan

- `amount` wajib berupa integer dari `1` hingga `maxAmount`.
- `reference` hanya menerima karakter yang cocok dengan `[\w.-]`.
- Jika reference tidak diberikan, sistem membuat reference otomatis berformat `TPV-XXXXXX-XXXXXX`.
- `callback_url` harus melewati validasi backend.
- `callback_secret` bersifat opsional.
- `description` maksimal 200 karakter.
- `metadata` harus berupa object.
- Masa berlaku transaksi mengikuti konfigurasi backend.
- Fee kosong dihitung berdasarkan `fee_transaction_percent` dari `app_settings`, dengan default 2,9% jika pengaturan tidak tersedia.
- Field `product` tidak didukung oleh endpoint ini.

### Contoh Response

HTTP `201 Created`

```json
{
  "success": true,
  "data": {
    "reference": "ORDER-001",
    "trx_id": "INTERNAL_TRANSACTION_ID",
    "status": "PENDING",
    "payment_method": "QRIS",
    "amount": 10000,
    "fee": 290,
    "total": 10290,
    "net": 10000,
    "currency": "IDR",
    "qr_string": "QRIS_STRING",
    "qr_image": "/api/v1/qris/INTERNAL_TRANSACTION_ID/qr",
    "expires_at": "2026-10-18T03:00:00.000Z",
    "created_at": "2026-10-18T02:45:00.000Z",
    "paid_at": null,
    "metadata": {
      "order_id": "ORDER-001"
    }
  }
}
```

Nilai di atas adalah contoh struktur response, bukan data transaksi aktif.

### Response Fields

| Field | Keterangan |
|---|---|
| `success` | Status request |
| `data.reference` | Reference transaksi |
| `data.trx_id` | ID internal transaksi |
| `data.status` | Status transaksi |
| `data.payment_method` | Metode pembayaran |
| `data.amount` | Nominal transaksi |
| `data.fee` | Biaya transaksi |
| `data.total` | Total transaksi |
| `data.net` | Nilai net |
| `data.currency` | Mata uang |
| `data.qr_string` | Data QRIS |
| `data.qr_image` | Path QR image |
| `data.expires_at` | Waktu kedaluwarsa |
| `data.created_at` | Waktu pembuatan |
| `data.paid_at` | Waktu pembayaran |
| `data.metadata` | Metadata transaksi |

## Memeriksa Transaksi

**Endpoint**

```http
GET /api/v1/qris/:reference
```

Contoh:

```bash
curl \
  -H "Authorization: Bearer YOUR_API_KEY" \
  "https://tokopayvip.vercel.app/api/v1/qris/ORDER-001"
```

Pencarian menerima ID internal transaksi atau `metadata.merchant_reference` sesuai implementasi backend.

## Mengambil QR Image

**Endpoint**

```http
GET /api/v1/qris/:reference/qr
```

Contoh:

```bash
curl \
  -H "Authorization: Bearer YOUR_API_KEY" \
  "https://tokopayvip.vercel.app/api/v1/qris/INTERNAL_TRANSACTION_ID/qr"
```

Path QR image tersedia melalui field `qr_image` pada response create.

## Membatalkan Transaksi

**Endpoint**

```http
POST /api/v1/qris/:reference/cancel
```

Contoh:

```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  "https://tokopayvip.vercel.app/api/v1/qris/INTERNAL_TRANSACTION_ID/cancel"
```

Hasil pembatalan mengikuti status transaksi dan aturan backend.

## Replay Webhook

**Endpoint**

```http
POST /api/v1/qris/:reference/replay-webhook
```

Contoh:

```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  "https://tokopayvip.vercel.app/api/v1/qris/INTERNAL_TRANSACTION_ID/replay-webhook"
```

Endpoint ini meminta pengiriman ulang webhook sesuai implementasi service webhook.

## Status Transaksi

| Status | Keterangan |
|---|---|
| `PENDING` | Menunggu pembayaran |
| `PAID` | Pembayaran berhasil |
| `EXPIRED` | Transaksi kedaluwarsa |

## Webhook Callback

Jika transaksi memiliki `callback_url`, backend mengirim HTTP `POST` dengan JSON polos.

### Payload

```json
{
  "reference": "ORDER-001",
  "status": "PAID",
  "amount": 10000,
  "fee": 290,
  "paid_at": "2026-10-18T02:50:00.000Z"
}
```

### Header

```http
Content-Type: application/json
X-Trx-Id: ORDER-001
```

`X-Trx-Id` berisi nilai `reference`.

### Perilaku Webhook

- Callback menggunakan HTTP `POST`.
- Body berupa JSON polos.
- Secara default tidak memerlukan signature atau secret.
- Pengiriman dicoba ulang sampai merchant memberikan respons HTTP `200`.

Merchant disarankan memproses callback secara idempoten dan memverifikasi transaksi sebelum memenuhi pesanan.

## Merchant API Keys

Format prefix API key merchant:

| Environment | Prefix |
|---|---|
| Live | `tpv_live_` |
| Test | `tpv_test_` |

Key menggunakan UUID acak tanpa tanda strip setelah prefix.

Contoh format:

```text
tpv_live_0123456789abcdef0123456789abcdef
tpv_test_0123456789abcdef0123456789abcdef
```

Contoh di atas bukan API key aktif.

Format identifikasi lainnya:

| Jenis | Format |
|---|---|
| Merchant code | `MRC-` diikuti 6 karakter |
| Withdrawal ID | `WDR-...` |
| Sandbox reference | `SBX-...` |

## Sandbox

Backend menyediakan route sandbox sesuai implementasi proyek.

Autentikasi sandbox memeriksa header `x-api-key` terhadap data pada tabel `api_keys`.

```http
x-api-key: YOUR_SANDBOX_API_KEY
```

Gunakan key dan environment yang sesuai untuk pengujian.

## Database

TokoPayVIP menggunakan PostgreSQL melalui Neon. Koneksi database dikonfigurasi melalui `DATABASE_URL` dan SSL sesuai pengaturan backend.

Modul database:

```text
src/db/index.js
```

Modul tersebut menginisialisasi tabel menggunakan `CREATE TABLE IF NOT EXISTS`.

| Tabel | Kegunaan |
|---|---|
| `users` | Data pengguna |
| `api_keys` | API key merchant |
| `transactions` | Data transaksi |
| `webhooks` | Data webhook |
| `app_settings` | Pengaturan aplikasi |

Tabel tambahan mengikuti implementasi aktual database.

## Deployment

### Frontend — Vercel

1. Import repository ke Vercel.
2. Atur Root Directory menjadi `web`.
3. Pastikan konfigurasi Nuxt sesuai.
4. Atur environment variable frontend yang diperlukan.
5. Jalankan deployment.
6. Aktifkan auto-deploy dari `main` jika integrasi Git sudah dikonfigurasi.

Website: [tokopayvip.vercel.app](https://tokopayvip.vercel.app)

### Backend — Node.js dan PM2

1. Siapkan server Node.js.
2. Clone repository dan install dependensi.
3. Konfigurasikan environment backend.
4. Verifikasi koneksi database Neon.
5. Periksa `ecosystem.config.cjs`.
6. Jalankan backend menggunakan PM2.
7. Atur HTTPS dan reverse proxy sesuai kebutuhan.

## Keamanan

- Jangan publikasikan master API key.
- Jangan commit file `.env`.
- Lindungi kredensial database.
- Gunakan HTTPS.
- Validasi callback URL.
- Verifikasi pembayaran sebelum memenuhi pesanan.
- Terapkan idempotensi pada callback.
- Batasi akses panel admin.
- Pantau kegagalan webhook.
- Pisahkan kredensial live dan sandbox.

## Kontribusi

Kontribusi dapat diajukan melalui GitHub.

1. Fork repository.
2. Buat branch baru.
3. Implementasikan perubahan.
4. Uji perubahan.
5. Ajukan pull request dengan deskripsi yang jelas.

```bash
git checkout -b feature/nama-perubahan
git add .
git commit -m "feat: deskripsi perubahan"
git push origin feature/nama-perubahan
```

Pastikan dokumentasi selalu sesuai dengan implementasi backend.

## Lisensi

Gunakan lisensi yang tercantum pada file `LICENSE` jika tersedia. Jika file lisensi tidak tersedia, jangan mengasumsikan proyek menggunakan lisensi MIT atau lisensi open-source lainnya.

---

<div align="center">

# <span style="color:#00DC82">TokoPayVIP</span>

**QRIS Payment Gateway**

[Website](https://tokopayvip.vercel.app) · [Dokumentasi](https://tokopayvip.vercel.app/docs) · [Repository](https://github.com/RONI-PROJECT/TokoPay)

<sub>Nuxt 3 · Express.js · PostgreSQL · QRIS</sub>

</div>
