<template>
  <div class="docs-page">
    <section class="hero">
      <div class="hero-inner">
        <p class="eyebrow">DOKUMENTASI MERCHANT</p>
        <h1>API Reference</h1>
        <p class="lead">TokoPayVIP Payment Gateway — terima pembayaran QRIS dinamis dari GoPay, OVO, DANA, ShopeePay, BCA, Mandiri, BNI, BRI, dan lainnya.</p>
        <div class="tags">
          <span>REST API</span>
          <span>JSON</span>
          <span>Callback Auto-Retry</span>
        </div>
      </div>
    </section>

    <main class="wrap">
      <!-- 00 BASE URL -->
      <section class="sec">
        <div class="sec-head">
          <span class="sec-num">00</span>
          <h2>Base URL</h2>
        </div>
        <p class="desc">Semua endpoint di halaman ini relative ke base URL berikut. Request dan response semuanya pakai JSON.</p>
        <div class="codebox">
          <div class="cb-head">
            <span class="cb-lang">HTTP</span>
            <button class="cb-copy" @click="copy('base', BASE)">{{ copied['base'] ? 'Tercopy' : 'Copy' }}</button>
          </div>
          <pre><code v-html="hlHttp(BASE)"></code></pre>
        </div>
      </section>

      <!-- 01 AUTENTIKASI -->
      <section class="sec">
        <div class="sec-head">
          <span class="sec-num">01</span>
          <h2>Autentikasi</h2>
        </div>
        <p class="desc">API key didapat dari dashboard → menu Kredensial → <b>Buat Key</b>. Format key: prefix <code>tpv_live_</code> (production) atau <code>tpv_test_</code> (sandbox) + 32 karakter random. Key bisa dibuat lebih dari satu dan bisa di-regenerate kapan saja dari dashboard.</p>
        <div class="codebox">
          <div class="cb-head">
            <span class="cb-lang">HTTP</span>
            <button class="cb-copy" @click="copy('auth', AUTH_BLOCK)">{{ copied['auth'] ? 'Tercopy' : 'Copy' }}</button>
          </div>
          <pre><code v-html="hlHttp(AUTH_BLOCK)"></code></pre>
        </div>
        <div class="warn">Jangan pernah taruh API key di frontend (browser / aplikasi mobile). Semua call ke <code>/api/v1/*</code> harus dari server lu.</div>
      </section>

      <!-- 02 MODE -->
      <section class="sec">
        <div class="sec-head">
          <span class="sec-num">02</span>
          <h2>Mode Pembayaran</h2>
        </div>
        <p class="desc">Ada dua mode tergantung key yang lu pakai:</p>
        <div class="modes">
          <div class="mode-card test">
            <h3>SANDBOX</h3>
            <p class="mode-key"><code>tpv_test_xxx</code></p>
            <ul>
              <li>Tanpa dana nyata — simulasi pembayaran</li>
              <li>Aktifin <code>SANDBOX_MODE=1</code> di server</li>
              <li>Transaksi masuk sebagai PENDING, bisa lu settle manual dari dashboard buat tes callback</li>
            </ul>
          </div>
          <div class="mode-card live">
            <h3>PRODUCTION</h3>
            <p class="mode-key"><code>tpv_live_xxx</code></p>
            <ul>
              <li>Dana nyata masuk ke saldo merchant</li>
              <li>Pembayaran terverifikasi otomatis lewat QRIS dinamis</li>
              <li>Narik dana lewat menu Tarik Dana</li>
            </ul>
          </div>
        </div>
        <div class="codebox" style="margin-top:16px">
          <div class="cb-head">
            <span class="cb-lang">ENV</span>
            <button class="cb-copy" @click="copy('env', ENV_BLOCK)">{{ copied['env'] ? 'Tercopy' : 'Copy' }}</button>
          </div>
          <pre><code v-html="hlBash(ENV_BLOCK)"></code></pre>
        </div>
      </section>

      <!-- 03 BUAT PEMBAYARAN -->
      <section class="sec">
        <div class="sec-head">
          <span class="sec-num">03</span>
          <h2>Buat Pembayaran QRIS</h2>
        </div>
        <p class="desc">QRIS dinamis: kode QR berisi nominal, bisa dibayar dari semua e-wallet &amp; mobile banking Indonesia. Pembayaran terdeteksi otomatis.</p>
        <div class="ep"><span class="method post">POST</span><code>{{ EP_CREATE }}</code></div>

        <table class="params">
          <thead>
            <tr><th>Field</th><th>Tipe</th><th>Wajib</th><th>Keterangan</th></tr>
          </thead>
          <tbody>
            <tr><td><code>amount</code></td><td>integer</td><td><span class="yes">Ya</span></td><td>Nominal pembayaran dalam Rupiah</td></tr>
            <tr><td><code>reference</code></td><td>string</td><td><span class="no">Tidak</span></td><td>ID transaksi dari lu, harus unik. Auto-generate <code>TPV-XXXXXX-XXXXXX</code> kalau kosong</td></tr>
            <tr><td><code>callback_url</code></td><td>string</td><td><span class="no">Tidak</span></td><td>URL yang di-POST server gua saat status berubah</td></tr>
            <tr><td><code>expires_minutes</code></td><td>integer</td><td><span class="no">Tidak</span></td><td>Umur QR dalam menit (default 15)</td></tr>
            <tr><td><code>description</code></td><td>string</td><td><span class="no">Tidak</span></td><td>Deskripsi transaksi</td></tr>
            <tr><td><code>metadata</code></td><td>object</td><td><span class="no">Tidak</span></td><td>Data bebas (order_id dll), diteruskan balik ke callback</td></tr>
          </tbody>
        </table>

        <div class="tabs">
          <button :class="{ on: tabCreate === 'req' }" @click="tabCreate = 'req'">REQUEST</button>
          <button :class="{ on: tabCreate === 'res' }" @click="tabCreate = 'res'">RESPONSE</button>
        </div>

        <div v-if="tabCreate === 'req'" class="codebox">
          <div class="cb-head">
            <span class="cb-lang">JSON</span>
            <button class="cb-copy" @click="copy('creq', CREATE_REQ)">{{ copied['creq'] ? 'Tercopy' : 'Copy' }}</button>
          </div>
          <pre><code v-html="hlJson(CREATE_REQ)"></code></pre>
        </div>
        <div v-else class="codebox">
          <div class="cb-head">
            <span class="cb-lang">JSON</span>
            <button class="cb-copy" @click="copy('cres', CREATE_RES)">{{ copied['cres'] ? 'Tercopy' : 'Copy' }}</button>
          </div>
          <pre><code v-html="hlJson(CREATE_RES)"></code></pre>
        </div>

        <div class="codebox" style="margin-top:14px">
          <div class="cb-head">
            <span class="cb-lang">BASH</span>
            <button class="cb-copy" @click="copy('curl', CURL_BLOCK)">{{ copied['curl'] ? 'Tercopy' : 'Copy' }}</button>
          </div>
          <pre><code v-html="hlBash(CURL_BLOCK)"></code></pre>
        </div>
      </section>

      <!-- 04 CEK STATUS -->
      <section class="sec">
        <div class="sec-head">
          <span class="sec-num">04</span>
          <h2>Cek Status Transaksi</h2>
        </div>
        <div class="ep"><span class="method get">GET</span><code>/api/v1/qris/{reference}</code></div>
        <p class="desc" style="margin-top:12px">Status transaksi:</p>
        <div class="badges">
          <span class="badge pending">PENDING</span>
          <span class="badge paid">PAID</span>
          <span class="badge expired">EXPIRED</span>
        </div>
        <div class="flow">
          <span class="step">QR Dibuat</span>
          <span class="arrow">→</span>
          <span class="step">Menunggu Pembayaran</span>
          <span class="arrow">→</span>
          <span class="step paid">PAID</span>
          <span class="arrow">atau</span>
          <span class="step exp">EXPIRED</span>
        </div>
        <div class="codebox" style="margin-top:16px">
          <div class="cb-head">
            <span class="cb-lang">RESPONSE</span>
            <button class="cb-copy" @click="copy('sres', STATUS_RES)">{{ copied['sres'] ? 'Tercopy' : 'Copy' }}</button>
          </div>
          <pre><code v-html="hlJson(STATUS_RES)"></code></pre>
        </div>
        <div class="ep" style="margin-top:14px"><span class="method get">GET</span><code>/api/v1/qris/{reference}/qr</code><span class="ep-note">gambar QR (PNG)</span></div>
      </section>

      <!-- 05 CALLBACK -->
      <section class="sec">
        <div class="sec-head">
          <span class="sec-num">05</span>
          <h2>Callback</h2>
        </div>
        <p class="desc">Pas status transaksi berubah (PAID / EXPIRED), server gua POST JSON ke <code>callback_url</code> lu. Polos tanpa signature, tanpa secret.</p>
        <div class="codebox">
          <div class="cb-head">
            <span class="cb-lang">PAYLOAD</span>
            <button class="cb-copy" @click="copy('cb', CALLBACK_RES)">{{ copied['cb'] ? 'Tercopy' : 'Copy' }}</button>
          </div>
          <pre><code v-html="hlJson(CALLBACK_RES)"></code></pre>
        </div>
        <p class="desc" style="margin-top:12px">Header <code>X-Trx-Id</code> juga ikut dikirim (isinya = reference). Contoh handler di server lu:</p>
        <div class="codebox">
          <div class="cb-head">
            <span class="cb-lang">NODE.JS</span>
            <button class="cb-copy" @click="copy('handler', HANDLER_BLOCK)">{{ copied['handler'] ? 'Tercopy' : 'Copy' }}</button>
          </div>
          <pre><code v-html="hlJs(HANDLER_BLOCK)"></code></pre>
        </div>
        <div class="info">Callback di-retry otomatis selama server lu g balas 200. Buat dobel cek, bandingin <code>reference</code> sama database lu, atau cek status langsung ke <code>GET /api/v1/qris/{reference}</code>.</div>
      </section>

      <!-- 06 FEE -->
      <section class="sec">
        <div class="sec-head">
          <span class="sec-num">06</span>
          <h2>Fee &amp; Penarikan</h2>
        </div>
        <p class="desc">Fee per transaksi 2,9%. Sisanya masuk ke saldo merchant dan bisa ditarik kapan aja lewat menu Tarik Dana di dashboard.</p>
        <table class="params">
          <thead>
            <tr><th>Contoh Nominal</th><th>Fee (2,9%)</th><th>Masuk Saldo</th></tr>
          </thead>
          <tbody>
            <tr><td>Rp 50.000</td><td>Rp 1.450</td><td>Rp 48.550</td></tr>
          </tbody>
        </table>
      </section>
    </main>

    <footer class="foot">
      <p>TokoPayVIP — Payment Gateway QRIS Indonesia</p>
      <p class="small">Masih bingung? Cek <NuxtLink to="/docs">Dokumentasi Publik</NuxtLink> atau hubungi support.</p>
    </footer>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'dashboard' })
const BASE = 'https://tokopayvip.vercel.app'
const EP_CREATE = '/api/v1/qris/create'

const AUTH_BLOCK = `Authorization: Bearer tpv_live_xxx
Content-Type: application/json`

const ENV_BLOCK = `# aktifin mode sandbox di environment server
SANDBOX_MODE=1`

const CREATE_REQ = `{
  "amount": 50000,
  "reference": "TPV-K8M4XQ2R-VN7WZL",
  "callback_url": "https://webstore-kamu.com/callback",
  "expires_minutes": 15,
  "description": "Sepatu Sneakers Putih",
  "metadata": {
    "order_id": "TPV-2043"
  }
}`

const CREATE_RES = `{
  "success": true,
  "data": {
    "reference": "TPV-K8M4XQ2R-VN7WZL",
    "status": "PENDING",
    "amount": 50000,
    "fee": 1450,
    "expires_at": "2026-10-18T01:45:00.000Z",
    "qr_string": "00020101021226580014ID.CO.QRIS.WWW...",
    "qr_image": "https://tokopayvip.vercel.app/api/v1/qris/TPV-K8M4XQ2R-VN7WZL/qr"
  }
}`

const STATUS_RES = `{
  "success": true,
  "data": {
    "reference": "TPV-K8M4XQ2R-VN7WZL",
    "status": "PAID",
    "amount": 50000,
    "fee": 1450,
    "paid_at": "2026-10-18T01:40:12.000Z"
  }
}`

const CALLBACK_RES = `{
  "reference": "TPV-K8M4XQ2R-VN7WZL",
  "status": "PAID",
  "amount": 50000,
  "fee": 1450,
  "paid_at": "2026-10-18T01:40:12.000Z"
}`

const CURL_BLOCK = `curl -X POST https://tokopayvip.vercel.app/api/v1/qris/create \\
  -H 'Authorization: Bearer tpv_live_xxx' \\
  -H 'Content-Type: application/json' \\
  -d '{"amount":50000,"reference":"TPV-K8M4XQ2R-VN7WZL","callback_url":"https://webstore-kamu.com/callback"}'`

const HANDLER_BLOCK = `app.post('/callback/tokopay', (req, res) => {
  const trxId = req.headers['x-trx-id']  // ID transaksi
  const { reference, status, amount } = req.body

  if (status === 'PAID') {
    // tandai transaksi lunas di database lu
  }

  res.sendStatus(200)
})`

const tabCreate = ref<'req' | 'res'>('req')
const copied = reactive<Record<string, boolean>>({})

async function copy(key: string, text: string) {
  try {
    await navigator.clipboard.writeText(text)
  } catch {
    const ta = document.createElement('textarea')
    ta.value = text
    document.body.appendChild(ta)
    ta.select()
    document.execCommand('copy')
    ta.remove()
  }
  copied[key] = true
  setTimeout(() => { copied[key] = false }, 1500)
}

function esc(s: string): string {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
}

function hlJson(src: string): string {
  return esc(src).replace(
    /("(?:[^"\\]|\\.)*")(\s*:)?|\b(true|false|null)\b|(-?\d+(?:\.\d+)?)/g,
    (m: string, str?: string, colon?: string, kw?: string, num?: string) => {
      if (str) return colon ? `<span class="tk-key">${str}</span>${colon}` : `<span class="tk-str">${str}</span>`
      if (kw) return `<span class="tk-kw">${kw}</span>`
      if (num) return `<span class="tk-num">${num}</span>`
      return m
    }
  )
}

function hlHttp(src: string): string {
  return esc(src)
    .replace(/^(POST|GET|PUT|DELETE|PATCH)\b(.*)$/gm, '<span class="tk-kw">$1</span><span class="tk-fn">$2</span>')
    .replace(/^([A-Za-z-]+)(:)(.*)$/gm, '<span class="tk-key">$1</span>$2<span class="tk-str">$3</span>')
}

function hlBash(src: string): string {
  return esc(src)
    .replace(/(#[^\n]*)/g, '<span class="tk-cm">$1</span>')
    .replace(/\b(curl|cd|npm|node|git)\b/g, '<span class="tk-kw">$1</span>')
    .replace(/('[^']*')/g, '<span class="tk-str">$1</span>')
}

function hlJs(src: string): string {
  return esc(src)
    .replace(/(\/\/[^\n]*)/g, '<span class="tk-cm">$1</span>')
    .replace(/\b(const|let|var|function|return|if|else|await|async|require)\b/g, '<span class="tk-kw">$1</span>')
    .replace(/('[^']*')/g, '<span class="tk-str">$1</span>')
}

useHead({
  title: 'Dokumentasi Merchant — TokoPayVIP',
  meta: [{ name: 'description', content: 'API Reference TokoPayVIP — QRIS dinamis untuk merchant Indonesia' }]
})
</script>

<style scoped>
.docs-page {
  min-height: 100vh;
  background: #f6f7fb;
  color: #0f172a;
}

/* NAV */
.nav {
  position: sticky;
  top: 0;
  z-index: 50;
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(12px);
  border-bottom: 1px solid #e2e8f0;
}
.nav-inner {
  max-width: 1080px;
  margin: 0 auto;
  padding: 14px 20px;
  display: flex;
  align-items: center;
  gap: 24px;
}
.brand { display: flex; align-items: center; }
.nav-links { display: flex; gap: 20px; margin-left: 12px; }
.nav-links a {
  font-size: 14px;
  font-weight: 600;
  color: #64748b;
  text-decoration: none;
}
.nav-links a.active, .nav-links a:hover { color: #6d28d9; }
.nav-actions { margin-left: auto; display: flex; gap: 10px; }
.btn-ghost {
  font-size: 13px;
  font-weight: 700;
  padding: 8px 16px;
  border-radius: 10px;
  color: #4f46e5;
  border: 1px solid #c7d2fe;
  text-decoration: none;
}
.btn-solid {
  font-size: 13px;
  font-weight: 700;
  padding: 8px 16px;
  border-radius: 10px;
  color: #fff;
  background: linear-gradient(135deg, #6d28d9, #4f46e5);
  text-decoration: none;
}

/* HERO */
.hero {
  background: linear-gradient(135deg, #0b1220, #14213d);
  color: #fff;
  padding: 64px 20px;
}
.hero-inner { max-width: 860px; margin: 0 auto; }
.eyebrow {
  font-size: 12px;
  font-weight: 800;
  letter-spacing: 2px;
  color: #a5b4fc;
  margin-bottom: 10px;
}
.hero h1 {
  font-size: 40px;
  font-weight: 900;
  margin: 0 0 12px;
}
.lead {
  font-size: 16px;
  color: #cbd5e1;
  max-width: 640px;
  line-height: 1.7;
}
.tags { display: flex; gap: 10px; margin-top: 18px; flex-wrap: wrap; }
.tags span {
  font-size: 12px;
  font-weight: 700;
  padding: 6px 14px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid rgba(255, 255, 255, 0.15);
  color: #e2e8f0;
}

/* WRAP + SECTIONS */
.wrap {
  max-width: 860px;
  margin: -28px auto 0;
  padding: 0 20px 40px;
  position: relative;
  z-index: 2;
}
.sec {
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 16px;
  padding: 28px;
  margin-bottom: 22px;
  box-shadow: 0 4px 16px rgba(15, 23, 42, 0.04);
}
.sec-head { display: flex; align-items: baseline; gap: 12px; margin-bottom: 12px; }
.sec-num {
  font-size: 13px;
  font-weight: 800;
  color: #a78bfa;
  letter-spacing: 1px;
}
.sec h2 { font-size: 20px; font-weight: 800; margin: 0; }
.desc { font-size: 14px; color: #475569; line-height: 1.75; margin: 0 0 14px; }
.desc code, .warn code, .info code {
  background: #eef2ff;
  color: #4338ca;
  padding: 2px 6px;
  border-radius: 6px;
  font-size: 12.5px;
}

/* ENDPOINT ROW */
.ep {
  display: flex;
  align-items: center;
  gap: 10px;
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 10px;
  padding: 10px 14px;
  margin: 12px 0;
}
.ep code { font-size: 13.5px; font-weight: 600; color: #0f172a; }
.ep-note { font-size: 12px; color: #94a3b8; margin-left: auto; }
.method {
  font-size: 11px;
  font-weight: 800;
  letter-spacing: 1px;
  padding: 4px 10px;
  border-radius: 6px;
}
.method.post { background: #dcfce7; color: #166534; }
.method.get { background: #dbeafe; color: #1e40af; }

/* CODEBOX */
.codebox {
  background: #0b1220;
  border: 1px solid #1e293b;
  border-radius: 12px;
  overflow: hidden;
  margin: 14px 0;
}
.cb-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: #111a2e;
  border-bottom: 1px solid #1e293b;
  padding: 8px 14px;
}
.cb-lang {
  font-size: 11px;
  font-weight: 800;
  letter-spacing: 1.5px;
  color: #94a3b8;
}
.cb-copy {
  font-size: 12px;
  font-weight: 700;
  color: #e2e8f0;
  background: #1e293b;
  border: none;
  border-radius: 8px;
  padding: 5px 12px;
  cursor: pointer;
}
.cb-copy:hover { background: #334155; }
.codebox pre {
  margin: 0;
  padding: 16px 18px;
  overflow-x: auto;
}
.codebox code {
  font-family: ui-monospace, 'Cascadia Code', Menlo, Consolas, monospace;
  font-size: 13px;
  line-height: 1.7;
  color: #e2e8f0;
}
.tk-key { color: #93c5fd; }
.tk-str { color: #86efac; }
.tk-num { color: #fcd34d; }
.tk-kw { color: #f472b6; }
.tk-cm { color: #64748b; font-style: italic; }
.tk-fn { color: #c4b5fd; }

/* TABS */
.tabs { display: flex; gap: 8px; margin: 16px 0 0; }
.tabs button {
  font-size: 12px;
  font-weight: 800;
  letter-spacing: 0.5px;
  padding: 7px 16px;
  border-radius: 8px;
  border: none;
  background: #eef2f7;
  color: #475569;
  cursor: pointer;
}
.tabs button.on { background: #4f46e5; color: #fff; }

/* TABLE */
.params {
  width: 100%;
  border-collapse: collapse;
  margin: 14px 0;
}
.params th {
  text-align: left;
  font-size: 11.5px;
  font-weight: 800;
  text-transform: uppercase;
  letter-spacing: 1px;
  color: #64748b;
  background: #f8fafc;
  padding: 10px 12px;
  border-bottom: 1px solid #e2e8f0;
}
.params td {
  padding: 10px 12px;
  border-bottom: 1px solid #eef2f7;
  font-size: 14px;
  color: #334155;
  vertical-align: top;
}
.params td code {
  background: #eef2ff;
  color: #4338ca;
  padding: 2px 6px;
  border-radius: 6px;
  font-size: 12.5px;
}
.yes { color: #059669; font-weight: 700; }
.no { color: #94a3b8; font-weight: 600; }

/* BOXES */
.warn {
  background: #fff7ed;
  border: 1px solid #fdba74;
  color: #9a3412;
  border-radius: 12px;
  padding: 14px 16px;
  font-size: 14px;
  line-height: 1.6;
  margin-top: 14px;
}
.info {
  background: #eff6ff;
  border: 1px solid #93c5fd;
  color: #1e40af;
  border-radius: 12px;
  padding: 14px 16px;
  font-size: 14px;
  line-height: 1.6;
  margin-top: 14px;
}

/* STATUS */
.badges { display: flex; gap: 10px; flex-wrap: wrap; margin: 10px 0 14px; }
.badge {
  font-size: 12px;
  font-weight: 800;
  padding: 4px 14px;
  border-radius: 999px;
}
.badge.pending { background: #fef3c7; color: #b45309; }
.badge.paid { background: #d1fae5; color: #047857; }
.badge.expired { background: #fee2e2; color: #b91c1c; }
.flow {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}
.step {
  font-size: 13px;
  font-weight: 600;
  background: #f1f5f9;
  border: 1px solid #e2e8f0;
  border-radius: 999px;
  padding: 6px 14px;
  color: #334155;
}
.step.paid { background: #d1fae5; border-color: #6ee7b7; color: #047857; }
.step.exp { background: #fee2e2; border-color: #fca5a5; color: #b91c1c; }
.arrow { color: #94a3b8; font-size: 13px; font-weight: 700; }

/* MODES */
.modes {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
  margin: 14px 0;
}
.mode-card {
  border-radius: 14px;
  padding: 20px;
}
.mode-card.test { background: #f0f9ff; border: 1px solid #7dd3fc; }
.mode-card.live { background: #f0fdf4; border: 1px solid #86efac; }
.mode-card h3 {
  font-size: 13px;
  font-weight: 800;
  letter-spacing: 1.5px;
  margin: 0 0 8px;
}
.mode-card.test h3 { color: #0369a1; }
.mode-card.live h3 { color: #15803d; }
.mode-key { margin: 0 0 10px; }
.mode-key code {
  background: #0b1220;
  color: #86efac;
  padding: 4px 10px;
  border-radius: 8px;
  font-size: 12.5px;
}
.mode-card ul { margin: 0; padding-left: 18px; }
.mode-card li { font-size: 13.5px; color: #334155; margin: 6px 0; line-height: 1.6; }
.mode-card li code {
  background: #e0e7ff;
  color: #4338ca;
  padding: 1px 5px;
  border-radius: 5px;
  font-size: 12px;
}

/* FOOT */
.foot {
  text-align: center;
  color: #64748b;
  font-size: 13px;
  padding: 30px 20px 60px;
}
.foot p { margin: 4px 0; }
.foot .small { font-size: 12px; }
.foot a { color: #4f46e5; font-weight: 700; text-decoration: none; }

@media (max-width: 720px) {
  .nav-links { display: none; }
  .hero h1 { font-size: 30px; }
  .wrap { padding: 0 14px 30px; }
  .sec { padding: 20px; }
  .modes { grid-template-columns: 1fr; }
}
</style>
