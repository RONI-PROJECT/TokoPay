<template>
  <div class="docs">
    <div class="hero">
      <div class="hero-eyebrow">
        <span class="hero-dot"></span>
        Dokumentasi
      </div>
      <h1>API Reference</h1>
      <p class="hero-sub">{{ siteName }} Payment Gateway — QRIS dinamis untuk merchant Indonesia.</p>
      <div class="hero-tags">
        <span class="hero-tag">REST API</span>
        <span class="hero-tag">JSON</span>
        <span class="hero-tag">Signed Webhook</span>
      </div>
    </div>

    <div class="info-box">
      <div class="info-col">
        <div class="info-label">Base URL</div>
        <div class="info-value-wrap">
          <code class="info-value">{{ apiBase }}</code>
          <button class="info-copy" @click="copyText(apiBase, 'baseurl')" :class="{ copied: copiedKey === 'baseurl' }" aria-label="Copy base URL">
            <svg v-if="copiedKey !== 'baseurl'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <rect x="9" y="9" width="13" height="13" rx="2" ry="2"/>
              <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/>
            </svg>
            <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
              <polyline points="20 6 9 17 4 12"/>
            </svg>
          </button>
        </div>
      </div>
      <div class="info-col">
        <div class="info-label">Autentikasi</div>
        <div class="info-value-wrap">
          <code class="info-value">Authorization: Bearer &lt;API_KEY&gt;</code>
          <button class="info-copy" @click="copyText('Authorization: Bearer <API_KEY_KAMU>', 'auth')" :class="{ copied: copiedKey === 'auth' }" aria-label="Copy auth header">
            <svg v-if="copiedKey !== 'auth'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <rect x="9" y="9" width="13" height="13" rx="2" ry="2"/>
              <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/>
            </svg>
            <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
              <polyline points="20 6 9 17 4 12"/>
            </svg>
          </button>
        </div>
      </div>
    </div>

    <div class="card" :class="{ open: openSection === 'endpoints' }">
      <button class="card-head" @click="toggle('endpoints')">
        <h2><span class="num">01</span> Daftar Endpoint</h2>
        <span class="chev">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4">
            <polyline points="6 9 12 15 18 9"/>
          </svg>
        </span>
      </button>
      <div v-show="openSection === 'endpoints'" class="card-body">
        <div class="table-wrap">
          <table>
            <thead><tr><th>Method</th><th>Endpoint</th><th>Keterangan</th></tr></thead>
            <tbody>
              <tr>
                <td><span class="method post">POST</span></td>
                <td><code>{{ EP_CREATE }}</code></td>
                <td>Buat QRIS pembayaran baru</td>
              </tr>
              <tr>
                <td><span class="method get">GET</span></td>
                <td><code>{{ EP_STATUS.replace(':reference', '{reference}') }}</code></td>
                <td>Cek status pembayaran</td>
              </tr>
              <tr>
                <td><span class="method get">GET</span></td>
                <td><code>{{ EP_QR.replace(':reference', '{reference}') }}</code></td>
                <td>Ambil gambar QR (PNG)</td>
              </tr>
              <tr>
                <td><span class="method post">POST</span></td>
                <td><code>callback_url kamu</code></td>
                <td>Webhook payment.paid / payment.expired</td>
              </tr>
            </tbody>
          </table>
        </div>
        <p>Semua request &amp; response memakai format <code>JSON</code>. Rate limit berlaku per API key.</p>
      </div>
    </div>

    <div class="card" :class="{ open: openSection === 'auth' }">
      <button class="card-head" @click="toggle('auth')">
        <h2><span class="num">02</span> Autentikasi</h2>
        <span class="chev">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4">
            <polyline points="6 9 12 15 18 9"/>
          </svg>
        </span>
      </button>
      <div v-show="openSection === 'auth'" class="card-body">
        <p>Semua endpoint diautentikasi pakai <strong>API key</strong> via header <code>Authorization: Bearer</code>. API key bisa dilihat dan dibuat di halaman <NuxtLink to="/merchant/api-key" class="link">Kredensial</NuxtLink> — bisa banyak key (multi key) dan di-rotate kapan saja.</p>
        <div class="code-wrap">
          <div class="code-head">
            <span class="code-lang">http</span>
            <button class="btn-copy" @click="copyText('Authorization: Bearer <API_KEY_KAMU>', 'code-auth')" :class="{ copied: copiedKey === 'code-auth' }">
              <span>{{ copiedKey === 'code-auth' ? 'Copied!' : 'Copy' }}</span>
            </button>
          </div>
          <pre>Authorization: Bearer &lt;API_KEY_KAMU&gt;
Content-Type: application/json</pre>
        </div>
        <div class="warn-box">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/>
            <line x1="12" y1="9" x2="12" y2="13"/>
            <line x1="12" y1="17" x2="12.01" y2="17"/>
          </svg>
          <div>
            <strong>Jangan pernah expose API key di client-side.</strong> Simpan di environment variable server kamu. Key bocor = dana bisa dibelokkan.
          </div>
        </div>
      </div>
    </div>

    <div class="card" :class="{ open: openSection === 'create' }">
      <button class="card-head" @click="toggle('create')">
        <h2><span class="num">03</span> Buat Pembayaran QRIS</h2>
        <span class="chev">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4">
            <polyline points="6 9 12 15 18 9"/>
          </svg>
        </span>
      </button>
      <div v-show="openSection === 'create'" class="card-body">
        <p class="ep"><span class="method post">POST</span> <code>{{ EP_CREATE }}</code></p>

        <p>Metode pembayaran yang digunakan adalah <strong>QRIS</strong> (Quick Response Code Indonesian Standard) — satu QR kode yang bisa dibayar dari semua aplikasi mobile banking dan e-wallet yang tergabung dalam standar QRIS (GoPay, OVO, DANA, ShopeePay, BCA, Mandiri, BNI, BRI, dll). QR dibuat dinamis dengan nominal ter-encode, sehingga pembayaran terdeteksi otomatis.</p>

        <div class="sub-label">Body Request</div>
        <div class="code-wrap">
          <div class="code-head">
            <span class="code-lang">json</span>
            <button class="btn-copy" @click="copyText(bodyCreate, 'code-create-body')" :class="{ copied: copiedKey === 'code-create-body' }">
              <span>{{ copiedKey === 'code-create-body' ? 'Copied!' : 'Copy' }}</span>
            </button>
          </div>
          <pre>{{ bodyCreate }}</pre>
        </div>

        <div class="sub-label">Parameter</div>
        <div class="table-wrap">
          <table>
            <thead><tr><th>Field</th><th>Wajib</th><th>Keterangan</th></tr></thead>
            <tbody>
              <tr><td><code>amount</code></td><td><span class="req">Ya</span></td><td>Nominal pembayaran (Rp), min. Rp 1.000</td></tr>
              <tr><td><code>reference</code></td><td>—</td><td>ID order kamu. Auto-generate kalau kosong</td></tr>
              <tr><td><code>callback_url</code></td><td>—</td><td>Webhook URL khusus transaksi ini</td></tr>
              <tr><td><code>expires_minutes</code></td><td>—</td><td>Masa berlaku QR (menit). Default 15</td></tr>
              <tr><td><code>metadata</code></td><td>—</td><td>Object bebas, dibalikin apa adanya di webhook</td></tr>
            </tbody>
          </table>
        </div>

        <div class="sub-label">Contoh cURL</div>
        <div class="code-wrap">
          <div class="code-head">
            <span class="code-lang">bash</span>
            <button class="btn-copy" @click="copyText(curlCreate, 'code-create-curl')" :class="{ copied: copiedKey === 'code-create-curl' }">
              <span>{{ copiedKey === 'code-create-curl' ? 'Copied!' : 'Copy' }}</span>
            </button>
          </div>
          <pre>{{ curlCreate }}</pre>
        </div>

        <div class="sub-label">Response</div>
        <div class="code-wrap">
          <div class="code-head">
            <span class="code-lang">json</span>
            <button class="btn-copy" @click="copyText(responseCreate, 'code-create-res')" :class="{ copied: copiedKey === 'code-create-res' }">
              <span>{{ copiedKey === 'code-create-res' ? 'Copied!' : 'Copy' }}</span>
            </button>
          </div>
          <pre>{{ responseCreate }}</pre>
        </div>

        <div class="sub-label">Menampilkan QR ke Customer</div>
        <p>Response sudah menyertakan <code>qr_image</code> (URL gambar QR siap tampil). Cukup render:</p>
        <div class="code-wrap">
          <div class="code-head">
            <span class="code-lang">html</span>
            <button class="btn-copy" @click="copyText(codeQrHtml, 'code-qr-html')" :class="{ copied: copiedKey === 'code-qr-html' }">
              <span>{{ copiedKey === 'code-qr-html' ? 'Copied!' : 'Copy' }}</span>
            </button>
          </div>
          <pre>{{ codeQrHtml }}</pre>
        </div>
      </div>
    </div>

    <div class="card" :class="{ open: openSection === 'status' }">
      <button class="card-head" @click="toggle('status')">
        <h2><span class="num">04</span> Cek Status Pembayaran</h2>
        <span class="chev">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4">
            <polyline points="6 9 12 15 18 9"/>
          </svg>
        </span>
      </button>
      <div v-show="openSection === 'status'" class="card-body">
        <p class="ep"><span class="method get">GET</span> <code>{{ EP_STATUS }}</code></p>
        <div class="code-wrap">
          <div class="code-head">
            <span class="code-lang">bash</span>
            <button class="btn-copy" @click="copyText(curlStatus, 'code-status-curl')" :class="{ copied: copiedKey === 'code-status-curl' }">
              <span>{{ copiedKey === 'code-status-curl' ? 'Copied!' : 'Copy' }}</span>
            </button>
          </div>
          <pre>{{ curlStatus }}</pre>
        </div>
        <p>Status: <code>PENDING</code> · <code>PAID</code> · <code>EXPIRED</code></p>
      </div>
    </div>

    <div class="card" :class="{ open: openSection === 'webhook' }">
      <button class="card-head" @click="toggle('webhook')">
        <h2><span class="num">05</span> Webhook</h2>
        <span class="chev">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4">
            <polyline points="6 9 12 15 18 9"/>
          </svg>
        </span>
      </button>
      <div v-show="openSection === 'webhook'" class="card-body">
        <p>Saat pembayaran lunas atau kadaluarsa, kami kirim <code>POST</code> ke <code>callback_url</code> kamu dengan body JSON berikut. Verifikasi header <code>X-Signature</code> sebelum memproses.</p>

        <div class="sub-label">payment.paid</div>
        <div class="code-wrap">
          <div class="code-head">
            <span class="code-lang">json</span>
            <button class="btn-copy" @click="copyText(payloadPaid, 'code-wh-paid')" :class="{ copied: copiedKey === 'code-wh-paid' }">
              <span>{{ copiedKey === 'code-wh-paid' ? 'Copied!' : 'Copy' }}</span>
            </button>
          </div>
          <pre>{{ payloadPaid }}</pre>
        </div>

        <div class="sub-label">payment.expired</div>
        <div class="code-wrap">
          <div class="code-head">
            <span class="code-lang">json</span>
            <button class="btn-copy" @click="copyText(payloadExpired, 'code-wh-exp')" :class="{ copied: copiedKey === 'code-wh-exp' }">
              <span>{{ copiedKey === 'code-wh-exp' ? 'Copied!' : 'Copy' }}</span>
            </button>
          </div>
          <pre>{{ payloadExpired }}</pre>
        </div>

        <div class="sub-label">Headers</div>
        <div class="table-wrap">
          <table>
            <thead><tr><th>Header</th><th>Keterangan</th></tr></thead>
            <tbody>
              <tr><td><code>Content-Type</code></td><td><code>application/json</code></td></tr>
              <tr><td><code>X-Event</code></td><td><code>payment.paid</code> / <code>payment.expired</code></td></tr>
              <tr><td><code>X-Reference</code></td><td>Reference transaksi</td></tr>
              <tr><td><code>X-Signature</code></td><td><code>hash_hmac('sha256', raw_body, webhook_secret)</code></td></tr>
            </tbody>
          </table>
        </div>

        <p>Retry otomatis: webhook yang gagal (timeout / non-2xx) dicoba ulang hingga 5 kali dengan jarak yang makin lama. Pastikan endpoint kamu balas <code>200 OK</code> secepatnya — proses bisnis di belakang boleh async.</p>
      </div>
    </div>

    <div class="card" :class="{ open: openSection === 'php' }">
      <button class="card-head" @click="toggle('php')">
        <h2><span class="num">06</span> Contoh Integrasi — PHP</h2>
        <span class="chev">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4">
            <polyline points="6 9 12 15 18 9"/>
          </svg>
        </span>
      </button>
      <div v-show="openSection === 'php'" class="card-body">
        <div class="sub-label">1. Buat Pembayaran (checkout)</div>
        <div class="code-wrap">
          <div class="code-head">
            <span class="code-lang">php</span>
            <button class="btn-copy" @click="copyText(codeCheckoutPhp, 'code-php-1')" :class="{ copied: copiedKey === 'code-php-1' }">
              <span>{{ copiedKey === 'code-php-1' ? 'Copied!' : 'Copy' }}</span>
            </button>
          </div>
          <pre>{{ codeCheckoutPhp }}</pre>
        </div>

        <div class="sub-label">2. Callback Handler (webhook)</div>
        <div class="code-wrap">
          <div class="code-head">
            <span class="code-lang">php</span>
            <button class="btn-copy" @click="copyText(codeCallbackPhp, 'code-php-2')" :class="{ copied: copiedKey === 'code-php-2' }">
              <span>{{ copiedKey === 'code-php-2' ? 'Copied!' : 'Copy' }}</span>
            </button>
          </div>
          <pre>{{ codeCallbackPhp }}</pre>
        </div>
      </div>
    </div>

    <div class="card" :class="{ open: openSection === 'js' }">
      <button class="card-head" @click="toggle('js')">
        <h2><span class="num">07</span> Contoh Integrasi — Node.js</h2>
        <span class="chev">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4">
            <polyline points="6 9 12 15 18 9"/>
          </svg>
        </span>
      </button>
      <div v-show="openSection === 'js'" class="card-body">
        <div class="sub-label">1. Buat Pembayaran + Express Webhook</div>
        <div class="code-wrap">
          <div class="code-head">
            <span class="code-lang">javascript</span>
            <button class="btn-copy" @click="copyText(codeNode, 'code-node')" :class="{ copied: copiedKey === 'code-node' }">
              <span>{{ copiedKey === 'code-node' ? 'Copied!' : 'Copy' }}</span>
            </button>
          </div>
          <pre>{{ codeNode }}</pre>
        </div>
      </div>
    </div>

    <div class="card" :class="{ open: openSection === 'errors' }">
      <button class="card-head" @click="toggle('errors')">
        <h2><span class="num">08</span> Error Codes</h2>
        <span class="chev">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4">
            <polyline points="6 9 12 15 18 9"/>
          </svg>
        </span>
      </button>
      <div v-show="openSection === 'errors'" class="card-body">
        <div class="table-wrap">
          <table>
            <thead><tr><th>Code</th><th>Artinya</th></tr></thead>
            <tbody>
              <tr><td><code>400</code></td><td>Body tidak valid / amount kurang dari minimum</td></tr>
              <tr><td><code>401</code></td><td>API key tidak ada atau salah</td></tr>
              <tr><td><code>403</code></td><td>API key diblokir / nonaktif</td></tr>
              <tr><td><code>404</code></td><td>Transaksi tidak ditemukan</td></tr>
              <tr><td><code>409</code></td><td>Reference sudah dipakai transaksi lain</td></tr>
              <tr><td><code>429</code></td><td>Terlalu banyak request — coba lagi nanti</td></tr>
              <tr><td><code>500</code></td><td>Error server, coba lagi atau hubungi support</td></tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'dashboard' })

const config = useRuntimeConfig()
const { siteName } = useSiteSettings()

// Base URL dari env: NUXT_PUBLIC_PUBLIC_URL → NUXT_PUBLIC_API_BASE_URL → window origin
const apiBase = computed(() => {
  const url = config.public.publicUrl || config.public.apiBaseUrl || ''
  if (url) return String(url).replace(/\/+$/, '')
  if (typeof window !== 'undefined') return window.location.origin
  return ''
})

// ── ENDPOINT — ganti di satu tempat, semua contoh ikut ──
const EP_CREATE = '/api/v1/qris/create'
const EP_STATUS = '/api/v1/qris/:reference'
const EP_QR     = '/api/v1/qris/:reference/qr'

const openSection = ref<string | null>('endpoints')
const copiedKey = ref<string | null>(null)

function toggle(name: string) {
  openSection.value = openSection.value === name ? null : name
}

async function copyText(text: string, key: string) {
  try {
    await navigator.clipboard.writeText(text)
    copiedKey.value = key
    setTimeout(() => {
      if (copiedKey.value === key) copiedKey.value = null
    }, 1800)
  } catch {
    const ta = document.createElement('textarea')
    ta.value = text
    document.body.appendChild(ta)
    ta.select()
    try { document.execCommand('copy') } catch {}
    document.body.removeChild(ta)
    copiedKey.value = key
    setTimeout(() => {
      if (copiedKey.value === key) copiedKey.value = null
    }, 1800)
  }
}

const bodyCreate = `{
  "amount": 50000,
  "reference": "ORDER-10001",
  "callback_url": "https://toko-kamu.com/webhook",
  "expires_minutes": 15,
  "metadata": {
    "order_id": 10001,
    "product": "Kaos Polos Hitam"
  }
}`

const curlCreate = computed(() => `curl -X POST ${apiBase.value}${EP_CREATE} \\
  -H "Authorization: Bearer <API_KEY_KAMU>" \\
  -H "Content-Type: application/json" \\
  -d '{
    "amount": 50000,
    "reference": "ORDER-10001",
    "callback_url": "https://toko-kamu.com/webhook",
    "expires_minutes": 15
  }'`)

const responseCreate = computed(() => `{
  "success": true,
  "data": {
    "reference": "ORDER-10001",
    "status": "PENDING",
    "payment_method": "QRIS",
    "amount": 50000,
    "fee": 900,
    "total": 50000,
    "qr_string": "00020101021226580014ID.CO.QRIS.WWW...",
    "qr_image": "${apiBase.value}/api/v1/qris/ORDER-10001/qr",
    "expires_at": "2026-10-09T07:15:00.000Z",
    "created_at": "2026-10-09T07:00:00.000Z"
  }
}`)

const curlStatus = computed(() => `curl ${apiBase.value}/api/v1/qris/ORDER-10001 \\
  -H "Authorization: Bearer <API_KEY_KAMU>"`)

const payloadPaid = computed(() => `{
  "event": "payment.paid",
  "data": {
    "reference": "ORDER-10001",
    "status": "PAID",
    "payment_method": "QRIS",
    "amount": 50000,
    "fee": 900,
    "net": 49100,
    "currency": "IDR",
    "paid_at": "2026-10-09T07:05:00.000Z",
    "metadata": {
      "order_id": 10001,
      "product": "Kaos Polos Hitam"
    }
  }
}`)

const payloadExpired = computed(() => `{
  "event": "payment.expired",
  "data": {
    "reference": "ORDER-10001",
    "status": "EXPIRED",
    "payment_method": "QRIS",
    "amount": 50000,
    "currency": "IDR",
    "expires_at": "2026-10-09T07:15:00.000Z",
    "metadata": {
      "order_id": 10001,
      "product": "Kaos Polos Hitam"
    }
  }
}`)

const codeQrHtml = `<img src="{qr_image dari response}" alt="QRIS" width="280">`

const codeCheckoutPhp = computed(() => `<?php
// ============================================
// BUAT PEMBAYARAN — dipanggil saat checkout
// ============================================
 $apiKey  = getenv('UNOPAY_API_KEY');
 $baseUrl = '${apiBase.value}';

function createQrisPayment(string $apiKey, string $baseUrl, array $order): array
{
    $payload = json_encode([
        'amount'          => $order['amount'],
        'reference'       => $order['reference'],
        'callback_url'    => 'https://toko-kamu.com/webhook/unopay',
        'expires_minutes' => 15,
        'metadata'        => [
            'order_id' => $order['id'],
            'product'  => $order['product'],
        ],
    ]);

    $ch = curl_init($baseUrl . '/api/v1/qris/create');
    curl_setopt_array($ch, [
        CURLOPT_POST           => true,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT        => 15,
        CURLOPT_HTTPHEADER     => [
            'Authorization: Bearer ' . $apiKey,
            'Content-Type: application/json',
        ],
        CURLOPT_POSTFIELDS     => $payload,
    ]);

    $body = curl_exec($ch);
    $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    if ($code !== 200) {
        throw new RuntimeException("Gagal membuat pembayaran (HTTP $code): $body");
    }

    return json_decode($body, true)['data'];
}

// --- contoh pemanggilan ---
 $payment = createQrisPayment($apiKey, $baseUrl, [
    'id'        => 10001,
    'reference' => 'ORDER-10001',
    'amount'    => 50000,
    'product'   => 'Kaos Polos Hitam',
]);

// simpan reference untuk pencocokan webhook:
// UPDATE orders SET reference = ? WHERE id = ?
echo $payment['qr_image'];`)

const codeCallbackPhp = `<?php
// ==================================================
// CALLBACK HANDLER — https://toko-kamu.com/webhook/unopay
// ==================================================

 $webhookSecret = getenv('UNOPAY_WEBHOOK_SECRET');
 $rawBody       = file_get_contents('php://input');

// ── 1. Verifikasi signature (WAJIB, jangan skip) ──
 $expectedSig = hash_hmac('sha256', $rawBody, $webhookSecret);
 $receivedSig = $_SERVER['HTTP_X_SIGNATURE'] ?? '';

if (!hash_equals($expectedSig, $receivedSig)) {
    http_response_code(403);
    error_log('[unopay] signature invalid');
    exit;
}

// ── 2. Parse payload ──
 $event = json_decode($rawBody, true);
if (json_last_error() !== JSON_ERROR_NONE) {
    http_response_code(400);
    exit;
}

 $reference = $event['data']['reference'] ?? null;
 $status    = $event['data']['status']    ?? null;
 $amount    = $event['data']['amount']    ?? 0;
 $net       = $event['data']['net']       ?? 0;
 $metadata  = $event['data']['metadata']  ?? [];
 $orderId   = $metadata['order_id']       ?? null;

// ── 3. Idempotency — webhook bisa datang lebih dari sekali ──
// SELECT 1 FROM processed_webhooks WHERE reference = ?
// → kalau sudah ada, langsung balas 200 tanpa proses ulang

if ($event['event'] === 'payment.paid') {
    // ── 4. PENTING: cocokkan nominal dengan order di database kamu ──
    // SELECT amount FROM orders WHERE id = ?
    // if ((int)$amount !== (int)$orderAmount) { log & reject; }

    // Tandai lunas dalam TRANSACTION:
    // BEGIN;
    // UPDATE orders SET status='paid', paid_at=NOW() WHERE id = ? AND status != 'paid';
    // UPDATE wallet SET balance = balance + ? WHERE user_id = ?;  // $net
    // INSERT INTO processed_webhooks (reference) VALUES (?);
    // COMMIT;

    error_log("[unopay] PAID ref=$reference orderId=$orderId net=$net");

} elseif ($event['event'] === 'payment.expired') {
    // UPDATE orders SET status='expired' WHERE id = ? AND status = 'pending';
    error_log("[unopay] EXPIRED ref=$reference");
}

// ── 5. Selalu balas 200 cepat — retry akan berhenti ──
http_response_code(200);
echo 'OK';`

const codeNode = computed(() => `// ============================================
// 1. Buat pembayaran
// ============================================
const API_KEY = process.env.UNOPAY_API_KEY;
const BASE_URL = '${apiBase.value}';

async function createQrisPayment({ amount, reference, metadata }) {
  const res = await fetch(BASE_URL + '/api/v1/qris/create', {
    method: 'POST',
    headers: {
      'Authorization': \`Bearer \${API_KEY}\`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      amount,
      reference,
      callback_url: 'https://toko-kamu.com/webhook/unopay',
      expires_minutes: 15,
      metadata,
    }),
  });

  if (!res.ok) {
    throw new Error(\`Gagal membuat pembayaran: \${res.status} \${await res.text()}\`);
  }

  const { data } = await res.json();
  return data; // { reference, qr_image, qr_string, expires_at, ... }
}

// --- contoh di Express route checkout ---
app.post('/checkout', async (req, res) => {
  const payment = await createQrisPayment({
    amount: 50000,
    reference: 'ORDER-' + Date.now(),
    metadata: { order_id: req.body.orderId },
  });

  // simpan payment.reference ke order kamu, lalu render halaman bayar
  res.render('pay', { payment });
});

// ============================================
// 2. Webhook handler — verifikasi HMAC
// ============================================
import crypto from 'node:crypto';

app.post('/webhook/unopay',
  express.raw({ type: 'application/json' }), // WAJIB raw biar HMAC match
  (req, res) => {
    const expected = crypto
      .createHmac('sha256', process.env.UNOPAY_WEBHOOK_SECRET)
      .update(req.body)
      .digest('hex');

    const received = req.headers['x-signature'];
    if (!crypto.timingSafeEqual(
      Buffer.from(expected),
      Buffer.from(received || ''),
    )) {
      return res.status(403).send('invalid signature');
    }

    const event = JSON.parse(req.body.toString());

    if (event.event === 'payment.paid') {
      const { reference, amount, net, metadata } = event.data;
      // tandai lunas, cocokkan amount dengan order kamu dulu
      console.log('PAID', reference, amount, net, metadata);
    }

    res.status(200).send('OK');
  }
);`)

useHead({ title: 'Dokumentasi API — ' + (siteName.value || 'UnoPay') })
</script>

<style scoped>
* { box-sizing: border-box; }
.docs { width: 100%; max-width: 1200px; margin: 0 auto; padding: 0 0 60px; color: var(--txt, #16121f); font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif; }

.hero { margin-bottom: 26px; padding: 8px 0 0; }
.hero-eyebrow { display: inline-flex; align-items: center; gap: 8px; font-size: 10.5px; font-weight: 800; letter-spacing: 0.16em; text-transform: uppercase; color: var(--vio, #7c3aed); margin-bottom: 12px; padding: 6px 12px; background: rgba(124,58,237,0.06); border: 1px solid rgba(124,58,237,0.18); border-radius: 999px; }
.hero-dot { width: 6px; height: 6px; border-radius: 50%; background: var(--vio, #7c3aed); box-shadow: 0 0 0 3px rgba(124,58,237,0.15); }
.hero h1 { font-size: 32px; font-weight: 800; letter-spacing: -0.03em; color: var(--txt, #16121f); line-height: 1.15; }
.hero-sub { font-size: 14px; color: var(--dim, #6f6a80); margin-top: 10px; line-height: 1.6; max-width: 640px; }
.hero-tags { display: flex; gap: 6px; flex-wrap: wrap; margin-top: 16px; }
.hero-tag { padding: 4px 10px; background: var(--bg-soft, #f9f8fc); border: 1px solid var(--line, #eceaf4); border-radius: 999px; font-size: 11px; font-weight: 700; color: var(--dim, #6f6a80); font-family: ui-monospace, monospace; }

.info-box { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; background: var(--bg-soft, #f9f8fc); border: 1px solid var(--line, #eceaf4); border-radius: 16px; padding: 18px 20px; margin-bottom: 22px; }
@media (max-width: 640px) { .info-box { grid-template-columns: 1fr; } }
.info-col { display: flex; flex-direction: column; gap: 8px; min-width: 0; }
.info-label { font-size: 10.5px; font-weight: 800; letter-spacing: 0.12em; text-transform: uppercase; color: var(--dim, #6f6a80); }
.info-value-wrap { display: flex; gap: 6px; align-items: stretch; min-width: 0; }
.info-value { flex: 1; background: #ffffff; border: 1px solid var(--line-2, #ddd9ee); border-radius: 9px; padding: 9px 12px; font-size: 12.5px; font-family: ui-monospace, monospace; color: var(--vio-deep, #5b21b6); word-break: break-all; display: block; min-width: 0; line-height: 1.5; white-space: pre-line; font-weight: 700; }
.info-copy { width: 38px; flex-shrink: 0; background: #ffffff; border: 1px solid var(--line, #eceaf4); border-radius: 9px; color: var(--dim, #6f6a80); display: flex; align-items: center; justify-content: center; cursor: pointer; transition: all 0.18s; }
.info-copy svg { width: 14px; height: 14px; }
.info-copy:hover { border-color: var(--vio-2, #a78bfa); color: var(--vio, #7c3aed); }
.info-copy.copied { background: var(--grad, linear-gradient(135deg, #7c3aed, #d946ef)); border-color: transparent; color: #ffffff; }

.warn-box { display: flex; gap: 10px; align-items: flex-start; margin-top: 14px; padding: 12px 14px; background: rgba(245, 158, 11, 0.06); border: 1px solid rgba(245, 158, 11, 0.25); border-radius: 10px; font-size: 12.5px; line-height: 1.6; color: #92400e; }
.warn-box svg { width: 16px; height: 16px; flex-shrink: 0; margin-top: 1px; color: #d97706; }
.warn-box strong { color: #b45309; }

.card { background: #ffffff; border: 1px solid var(--line, #eceaf4); border-radius: 16px; margin-bottom: 12px; overflow: hidden; transition: border-color 0.2s; box-shadow: 0 1px 2px rgba(88,60,160,0.04), 0 4px 14px rgba(88,60,160,0.05); }
.card.open { border-color: rgba(124,58,237,0.3); }
.card-head { width: 100%; display: flex; justify-content: space-between; align-items: center; gap: 12px; padding: 20px 22px; background: transparent; border: none; cursor: pointer; font-family: inherit; text-align: left; transition: background 0.15s; -webkit-tap-highlight-color: transparent; }
.card-head:hover { background: var(--bg-soft, #f9f8fc); }
.card h2 { display: flex; align-items: center; gap: 12px; font-size: 15.5px; font-weight: 750; color: var(--txt, #16121f); margin: 0; }
.card h2 .num { display: inline-flex; align-items: center; justify-content: center; width: 32px; height: 32px; border-radius: 9px; background: rgba(124,58,237,0.07); border: 1px solid rgba(124,58,237,0.15); color: var(--vio, #7c3aed); font-size: 11.5px; font-weight: 800; font-family: ui-monospace, monospace; flex-shrink: 0; transition: all 0.2s; }
.card.open h2 .num { background: var(--grad, linear-gradient(135deg, #7c3aed, #d946ef)); border-color: transparent; color: #ffffff; }
.chev { display: inline-flex; align-items: center; justify-content: center; width: 28px; height: 28px; border-radius: 8px; background: var(--bg-soft, #f9f8fc); border: 1px solid var(--line, #eceaf4); color: var(--dim, #6f6a80); flex-shrink: 0; transition: transform 0.28s cubic-bezier(0.22,1,0.36,1), all 0.2s; }
.chev svg { width: 15px; height: 15px; }
.card.open .chev { transform: rotate(180deg); background: rgba(124,58,237,0.08); border-color: rgba(124,58,237,0.25); color: var(--vio, #7c3aed); }
.card-body { padding: 4px 22px 22px; border-top: 1px solid var(--line, #eceaf4); }
.card p { font-size: 13.5px; color: var(--dim, #6f6a80); line-height: 1.7; margin: 14px 0; }
.link { color: var(--vio, #7c3aed); text-decoration: underline; }

.sub-label { font-size: 10.5px; font-weight: 800; color: var(--vio, #7c3aed); text-transform: uppercase; letter-spacing: 0.12em; margin: 20px 0 10px; }
.sub-label:first-child { margin-top: 14px; }

.code-wrap { margin: 10px 0; border-radius: 12px; overflow: hidden; border: 1px solid #2a2338; }
.code-head { display: flex; justify-content: space-between; align-items: center; padding: 8px 14px; background: #17131f; border-bottom: 1px solid #2a2338; }
.code-lang { font-size: 10.5px; font-weight: 800; color: #8d84a3; letter-spacing: 0.1em; text-transform: uppercase; font-family: ui-monospace, monospace; }
.btn-copy { display: inline-flex; align-items: center; gap: 6px; padding: 5px 11px; background: rgba(255,255,255,0.05); border: 1px solid #2f2840; border-radius: 7px; font-size: 11px; font-weight: 700; color: #b6aecd; cursor: pointer; font-family: inherit; transition: all 0.18s; }
.btn-copy:hover { background: rgba(124,58,237,0.2); border-color: rgba(124,58,237,0.4); color: #e4dbf5; }
.btn-copy.copied { background: rgba(124,58,237,0.3); border-color: rgba(124,58,237,0.5); color: #cdb6ff; }

pre { background: #17131f; color: #d4cce6; padding: 14px 16px; font-size: 12px; overflow-x: auto; font-family: ui-monospace, 'SF Mono', Menlo, monospace; line-height: 1.7; margin: 0; white-space: pre-wrap; word-break: break-word; }
code { background: rgba(124,58,237,0.07); border: 1px solid rgba(124,58,237,0.15); padding: 2px 7px; border-radius: 5px; font-size: 12px; font-family: ui-monospace, monospace; color: var(--vio-deep, #5b21b6); font-weight: 700; }
.ep { display: flex; align-items: center; gap: 10px; margin: 14px 0; flex-wrap: wrap; }
.ep code { font-size: 13px; }
.method { padding: 4px 10px; border-radius: 6px; font-size: 10px; font-weight: 800; letter-spacing: 0.08em; text-transform: uppercase; flex-shrink: 0; }
.method.post { background: rgba(124,58,237,0.1); border: 1px solid rgba(124,58,237,0.25); color: var(--vio, #7c3aed); }
.method.get { background: rgba(13,148,136,0.08); border: 1px solid rgba(13,148,136,0.22); color: #0d9488; }

.table-wrap { overflow-x: auto; margin: 10px 0 4px; border-radius: 12px; border: 1px solid var(--line, #eceaf4); -webkit-overflow-scrolling: touch; }
table { width: 100%; border-collapse: collapse; font-size: 13px; min-width: 480px; }
th { text-align: left; padding: 12px 14px; border-bottom: 1px solid var(--line, #eceaf4); color: var(--dim, #6f6a80); font-size: 10.5px; font-weight: 800; text-transform: uppercase; letter-spacing: 0.1em; white-space: nowrap; background: var(--bg-soft, #f9f8fc); }
td { padding: 13px 14px; border-bottom: 1px solid var(--line, #eceaf4); color: var(--txt, #16121f); line-height: 1.55; vertical-align: top; background: #ffffff; }
tr:last-child td { border-bottom: none; }
tr:hover td { background: var(--bg-soft, #f9f8fc); }
td code { color: var(--vio-deep, #5b21b6); font-weight: 700; white-space: nowrap; }
.req { display: inline-block; padding: 2px 8px; border-radius: 999px; font-size: 10px; font-weight: 800; background: rgba(225,29,72,0.07); border: 1px solid rgba(225,29,72,0.2); color: var(--bad, #e11d48); letter-spacing: 0.04em; }

@media (max-width: 640px) {
  .docs { padding: 0 0 40px; }
  .hero h1 { font-size: 26px; }
  .hero-sub { font-size: 13px; }
  .card-head { padding: 16px; }
  .card-body { padding: 4px 16px 18px; }
  .card h2 { font-size: 14.5px; gap: 10px; }
  .card h2 .num { width: 28px; height: 28px; font-size: 10.5px; }
  pre { font-size: 11px; padding: 12px 13px; line-height: 1.65; }
  .code-head { padding: 7px 12px; }
  .btn-copy { padding: 4px 9px; font-size: 10.5px; }
  .info-box { padding: 16px; gap: 12px; }
  table { font-size: 12px; min-width: 440px; }
  th, td { padding: 10px 12px; }
}
</style>