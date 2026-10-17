# Ronipaygate — Integrasi PHP

Template integrasi payment gateway Ronipaygate dalam PHP.

## Isi

- config.php — Konfigurasi API & database
- checkout.php — Bikin transaksi + redirect ke halaman pembayaran
- callback.php — Terima webhook dari Ronipaygate
- index.php — Demo form checkout
- schema.sql — Schema tabel orders

## Setup

### 1. Edit config.php

Sesuaikan dengan kredensial kamu:

- RPG_API_URL — domain Ronipaygate
- RPG_API_KEY — dari Dashboard → Kredensial
- RPG_WEBHOOK_SECRET — dari Dashboard → Callback
- DB_* — koneksi MySQL kamu

### 2. Bikin tabel database

mysql -u root -p tokoku < schema.sql

### 3. Upload ke server

Upload semua file ke public_html (atau folder web root).

### 4. Set callback URL

Buka Dashboard Ronipaygate - Callback - isi:

https://tokoku.com/callback.php

### 5. Tes

Buka https://tokoku.com/index.php, isi nominal, klik Bayar.

## Alur

1. User isi form checkout
2. checkout.php panggil API Ronipaygate
3. Dapat paymentUrl, redirect user ke situ
4. User scan QRIS dan bayar
5. Ronipaygate POST ke callback.php saat lunas
6. callback.php update order di database

## Verifikasi Signature

Setiap webhook dikirim dengan header X-Signature berisi HMAC-SHA256 dari raw body.

    $expected = 'sha256=' . hash_hmac('sha256', $rawBody, RPG_WEBHOOK_SECRET);
    if (!hash_equals($expected, $signature)) {
        exit('Invalid signature');
    }

Jangan pakai JSON.parse lalu stringify ulang — signature dihitung dari raw body persis.

## Debugging

Semua webhook masuk dilog ke webhook.log.

## Lisensi

MIT
