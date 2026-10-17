<template>
  <div class="docs-page">
    <div class="wrap">
      <div class="hero">
        <div class="hero-eyebrow">
          <span class="hero-dot"></span>
          Dokumentasi Merchant
        </div>
        <h1>API Reference</h1>
        <p class="hero-sub">{{ siteName }} Payment Gateway — QRIS dinamis untuk merchant Indonesia.</p>
        <div class="hero-tags">
          <span class="hero-tag">REST API</span>
          <span class="hero-tag">JSON</span>
          <span class="hero-tag">Callback Auto-Retry</span>
        </div>
      </div>

      <!-- BASE + AUTH -->
      <div class="info-box">
        <div class="info-col">
          <div class="info-label">Base URL</div>
          <div class="info-value-wrap">
            <code class="info-value">{{ apiBase }}</code>
            <button class="info-copy" @click="copyText(apiBase, 'baseurl')" :class="{ copied: copiedKey === 'baseurl' }" aria-label="Copy base URL">
              <svg v-if="copiedKey !== 'baseurl'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
              <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
            </button>
          </div>
        </div>
        <div class="info-col">
          <div class="info-label">Autentikasi</div>
          <div class="info-value-wrap">
            <code class="info-value">Authorization: Bearer tpv_live_xxx</code>
            <button class="info-copy" @click="copyText('Authorization: Bearer tpv_live_xxx', 'auth')" :class="{ copied: copiedKey === 'auth' }" aria-label="Copy auth header">
              <svg v-if="copiedKey !== 'auth'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
              <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
            </button>
          </div>
        </div>
      </div>

      <!-- DAFTAR ENDPOINT -->
      <div class="card open">
        <div class="card-head static">
          <h2><span class="num">01</span> Daftar Endpoint</h2>
        </div>
        <div class="card-body">
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
                  <td><code>{{ EP_CANCEL.replace(':reference', '{reference}') }}</code></td>
                  <td>Batalkan transaksi PENDING</td>
                </tr>
                <tr>
                  <td><span class="method post">POST</span></td>
                  <td><code>{{ EP_REPLAY.replace(':reference', '{reference}') }}</code></td>
                  <td>Kirim ulang callback manual</td>
                </tr>
                <tr>
                  <td><span class="method post">POST</span></td>
                  <td><code>callback_url kamu</code></td>
                  <td>Callback payment.paid / payment.expired</td>
                </tr>
              </tbody>
            </table>
          </div>
          <p>Semua request &amp; response memakai format <code>JSON</code>. Rate limit berlaku per API key.</p>
        </div>
      </div>

      <!-- AUTENTIKASI -->
      <div class="card open">
        <div class="card-head static">
          <h2><span class="num">02</span> Autentikasi</h2>
        </div>
        <div class="card-body">
          <p>Semua endpoint diautentikasi pakai <strong>API key</strong> via header <code>Authorization: Bearer</code> (atau <code>X-API-Key</code>). API key dibuat &amp; di-rotate dari halaman <NuxtLink to="/merchant/api-key" class="link">Kredensial API</NuxtLink> — bisa banyak key untuk isolasi per project.</p>
          <div class="codebox">
            <div class="codebox-head">
              <span class="cb-lang">HTTP</span>
              <button class="cb-copy" @click="copyText('Authorization: Bearer tpv_live_xxx', 'code-auth')" :class="{ copied: copiedKey === 'code-auth' }">
                <svg v-if="copiedKey !== 'code-auth'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                <span>{{ copiedKey === 'code-auth' ? 'Copied!' : 'Copy' }}</span>
              </button>
            </div>
            <pre class="cb-body" v-html="hlHttp(`Authorization: Bearer tpv_live_xxx
Content-Type: application/json`)"></pre>
          </div>
          <div class="warn-box">
            <strong>Jangan pernah</strong> taruh API key di frontend (browser / aplikasi mobile). Semua pemanggilan <code>/api/v1/*</code> harus dari server kamu.
          </div>
        </div>
      </div>

      <!-- BUAT PEMBAYARAN -->
      <div class="card open">
        <div class="card-head static">
          <h2><span class="num">03</span> Buat Pembayaran QRIS</h2>
        </div>
        <div class="card-body">
          <p class="ep"><span class="method post">POST</span> <code>{{ EP_CREATE }}</code></p>

          <div class="sub-label">Body Request</div>
          <div class="codebox">
            <div class="codebox-head">
              <span class="cb-lang">JSON</span>
              <button class="cb-copy" @click="copyText(bodyCreate, 'code-create-body')" :class="{ copied: copiedKey === 'code-create-body' }">
                <svg v-if="copiedKey !== 'code-create-body'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                <span>{{ copiedKey === 'code-create-body' ? 'Copied!' : 'Copy' }}</span>
              </button>
            </div>
            <pre class="cb-body" v-html="hlJson(bodyCreate)"></pre>
          </div>

          <div class="sub-label">Parameter</div>
          <div class="table-wrap">
            <table>
              <thead><tr><th>Parameter</th><th>Wajib</th><th>Keterangan</th></tr></thead>
              <tbody>
                <tr><td><code>amount</code></td><td><span class="req">Ya</span></td><td>Nominal pembayaran (integer Rp)</td></tr>
                <tr><td><code>reference</code></td><td>—</td><td>ID order kamu, unik per transaksi (1–64 karakter: huruf, angka, <code>_</code> <code>.</code> <code>-</code>)</td></tr>
                <tr><td><code>expires_minutes</code></td><td>—</td><td>Masa berlaku QR dalam menit (default dari server)</td></tr>
                <tr><td><code>callback_url</code></td><td>—</td><td>URL callback khusus transaksi ini (HTTPS)</td></tr>
                <tr><td><code>description</code></td><td>—</td><td>Deskripsi produk, maks 200 karakter</td></tr>
                <tr><td><code>metadata</code></td><td>—</td><td>Object bebas, dibalikin apa adanya</td></tr>
                <tr><td><code>idempotency_key</code></td><td>—</td><td>Cegah duplikat saat retry (atau header <code>Idempotency-Key</code>)</td></tr>
              </tbody>
            </table>
          </div>

          <div class="sub-label">Contoh cURL</div>
          <div class="codebox">
            <div class="codebox-head">
              <span class="cb-lang">BASH</span>
              <button class="cb-copy" @click="copyText(curlCreate, 'code-curl-create')" :class="{ copied: copiedKey === 'code-curl-create' }">
                <svg v-if="copiedKey !== 'code-curl-create'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                <span>{{ copiedKey === 'code-curl-create' ? 'Copied!' : 'Copy' }}</span>
              </button>
            </div>
            <pre class="cb-body" v-html="hlBash(curlCreate)"></pre>
          </div>

          <div class="sub-label">Response <span class="ok-code">201</span></div>
          <div class="codebox tall">
            <div class="codebox-head">
              <span class="cb-lang">JSON</span>
              <button class="cb-copy" @click="copyText(responseCreate, 'code-res-create')" :class="{ copied: copiedKey === 'code-res-create' }">
                <svg v-if="copiedKey !== 'code-res-create'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                <span>{{ copiedKey === 'code-res-create' ? 'Copied!' : 'Copy' }}</span>
              </button>
            </div>
            <pre class="cb-body" v-html="hlJson(responseCreate)"></pre>
          </div>

          <div class="warn-box">
            <code>fee</code> &amp; <code>net</code> otomatis dihitung dari setting fee (persen) — nominal yang diterima merchant = <code>amount - fee</code>. Customer bayar persis <code>amount</code>.
          </div>
        </div>
      </div>

      <!-- CEK STATUS -->
      <div class="card">
        <button class="card-head" @click="toggle('status')">
          <h2><span class="num">04</span> Cek Status Pembayaran</h2>
          <span class="chev">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4"><polyline points="6 9 12 15 18 9"/></svg>
          </span>
        </button>
        <div v-show="openSection === 'status'" class="card-body">
          <p class="ep"><span class="method get">GET</span> <code>{{ EP_STATUS }}</code></p>
          <p>Untuk polling status atau konfirmasi akhir setelah callback. Status yang mungkin: <code>PENDING</code> · <code>PAID</code> · <code>EXPIRED</code>.</p>
          <div class="codebox tall">
            <div class="codebox-head">
              <div class="cb-tabs">
                <button class="cb-tab" :class="{ on: boxTab.status === 'req' }" @click="boxTab.status = 'req'">REQUEST</button>
                <button class="cb-tab" :class="{ on: boxTab.status === 'res' }" @click="boxTab.status = 'res'">RESPONSE <span class="cb-code">200</span></button>
              </div>
              <button class="cb-copy" @click="copyText(boxTab.status === 'req' ? curlStatus : responseStatus, 'cb-status')" :class="{ copied: copiedKey === 'cb-status' }">
                <svg v-if="copiedKey !== 'cb-status'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                <span>{{ copiedKey === 'cb-status' ? 'Copied!' : 'Copy' }}</span>
              </button>
            </div>
            <pre v-if="boxTab.status === 'req'" class="cb-body" v-html="hlBash(curlStatus)"></pre>
            <pre v-else class="cb-body" v-html="hlJson(responseStatus)"></pre>
          </div>
        </div>
      </div>

      <!-- CANCEL & REPLAY -->
      <div class="card">
        <button class="card-head" @click="toggle('cancel')">
          <h2><span class="num">05</span> Cancel &amp; Replay Callback</h2>
          <span class="chev">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4"><polyline points="6 9 12 15 18 9"/></svg>
          </span>
        </button>
        <div v-show="openSection === 'cancel'" class="card-body">
          <p class="ep"><span class="method post">POST</span> <code>{{ EP_CANCEL }}</code></p>
          <p>Batalkan transaksi yang masih <code>PENDING</code> — statusnya langsung jadi <code>EXPIRED</code> dan QR-nya tidak bisa dipakai lagi. Sudah <code>PAID</code>? Nggak bisa dibatalkan.</p>

          <p class="ep" style="margin-top:18px"><span class="method post">POST</span> <code>{{ EP_REPLAY }}</code></p>
          <p>Kirim ulang callback terakhir secara manual — berguna kalau server kamu sempat down dan mau memastikan notifikasi sampai. Transaksi masih <code>PENDING</code> nggak ada yang bisa dikirim.</p>
          <div class="codebox">
            <div class="codebox-head">
              <span class="cb-lang">BASH</span>
              <button class="cb-copy" @click="copyText(curlReplay, 'code-replay')" :class="{ copied: copiedKey === 'code-replay' }">
                <svg v-if="copiedKey !== 'code-replay'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                <span>{{ copiedKey === 'code-replay' ? 'Copied!' : 'Copy' }}</span>
              </button>
            </div>
            <pre class="cb-body" v-html="hlBash(curlReplay)"></pre>
          </div>
        </div>
      </div>

      <!-- CALLBACK -->
      <div class="card open">
        <div class="card-head static">
          <h2><span class="num">06</span> Callback Pembayaran</h2>
        </div>
        <div class="card-body">
          <p>Saat pembayaran lunas atau kadaluarsa, server kirim <code>POST</code> JSON langsung ke <code>callback_url</code> kamu — <strong>tanpa signature</strong>, tinggal cocokkan <code>data.reference</code> dengan order kamu. Balas <code>2xx</code> biar retry berhenti.</p>

          <div class="sub-label">Event payment.paid</div>
          <div class="codebox">
            <div class="codebox-head">
              <span class="cb-lang">JSON</span>
              <button class="cb-copy" @click="copyText(payloadPaid, 'code-wh-paid')" :class="{ copied: copiedKey === 'code-wh-paid' }">
                <svg v-if="copiedKey !== 'code-wh-paid'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                <span>{{ copiedKey === 'code-wh-paid' ? 'Copied!' : 'Copy' }}</span>
              </button>
            </div>
            <pre class="cb-body" v-html="hlJson(payloadPaid)"></pre>
          </div>

          <div class="sub-label">Event payment.expired</div>
          <div class="codebox">
            <div class="codebox-head">
              <span class="cb-lang">JSON</span>
              <button class="cb-copy" @click="copyText(payloadExpired, 'code-wh-exp')" :class="{ copied: copiedKey === 'code-wh-exp' }">
                <svg v-if="copiedKey !== 'code-wh-exp'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                <span>{{ copiedKey === 'code-wh-exp' ? 'Copied!' : 'Copy' }}</span>
              </button>
            </div>
            <pre class="cb-body" v-html="hlJson(payloadExpired)"></pre>
          </div>

          <div class="sub-label">Headers</div>
          <div class="table-wrap">
            <table>
              <thead><tr><th>Header</th><th>Keterangan</th></tr></thead>
              <tbody>
                <tr><td><code>Content-Type</code></td><td><code>application/json</code></td></tr>
                <tr><td><code>X-Event</code></td><td><code>payment.paid</code> / <code>payment.expired</code></td></tr>
                <tr><td><code>X-Trx-Id</code></td><td>ID transaksi (sama dengan reference)</td></tr>
              </tbody>
            </table>
          </div>

          <div class="sub-label">Handler Callback (Node.js)</div>
          <div class="codebox">
            <div class="codebox-head">
              <span class="cb-lang">JAVASCRIPT</span>
              <button class="cb-copy" @click="copyText(codeHandlerNode, 'code-handler')" :class="{ copied: copiedKey === 'code-handler' }">
                <svg v-if="copiedKey !== 'code-handler'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                <span>{{ copiedKey === 'code-handler' ? 'Copied!' : 'Copy' }}</span>
              </button>
            </div>
            <pre class="cb-body" v-html="hlGeneric(codeHandlerNode)"></pre>
          </div>

          <p>Retry otomatis: kalau gagal (timeout / non-2xx) dicoba ulang maksimal <strong>12x</strong> dengan jarak makin lama (30 detik → 15 menit), timeout per request 10 detik. Riwayat pengiriman keliatan di halaman <NuxtLink to="/merchant/webhook" class="link">Webhook</NuxtLink>.</p>
          <p>Alamat tujuan callback, urutannya: <code>callback_url</code> per transaksi → URL webhook yang diisi di dashboard → env <code>WEBHOOK_URL</code>. Kalau nggak ada satupun, callback nggak dikirim — pakai polling <code>GET</code> status aja.</p>
        </div>
      </div>

      <!-- CONTOH LENGKAP -->
      <div class="card">
        <button class="card-head" @click="toggle('contoh')">
          <h2><span class="num">07</span> Contoh Integrasi — PHP</h2>
          <span class="chev">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4"><polyline points="6 9 12 15 18 9"/></svg>
          </span>
        </button>
        <div v-show="openSection === 'contoh'" class="card-body">
          <div class="sub-label">1. Buat Pembayaran (checkout)</div>
          <div class="codebox">
            <div class="codebox-head">
              <span class="cb-lang">PHP</span>
              <button class="cb-copy" @click="copyText(codeCheckoutPhp, 'code-php-1')" :class="{ copied: copiedKey === 'code-php-1' }">
                <svg v-if="copiedKey !== 'code-php-1'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                <span>{{ copiedKey === 'code-php-1' ? 'Copied!' : 'Copy' }}</span>
              </button>
            </div>
            <pre class="cb-body" v-html="hlGeneric(codeCheckoutPhp)"></pre>
          </div>

          <div class="sub-label">2. Callback Handler</div>
          <div class="codebox">
            <div class="codebox-head">
              <span class="cb-lang">PHP</span>
              <button class="cb-copy" @click="copyText(codeCallbackPhp, 'code-php-2')" :class="{ copied: copiedKey === 'code-php-2' }">
                <svg v-if="copiedKey !== 'code-php-2'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                <span>{{ copiedKey === 'code-php-2' ? 'Copied!' : 'Copy' }}</span>
              </button>
            </div>
            <pre class="cb-body" v-html="hlGeneric(codeCallbackPhp)"></pre>
          </div>

          <div class="sub-label">3. Tampilkan QR</div>
          <div class="codebox">
            <div class="codebox-head">
              <span class="cb-lang">HTML</span>
              <button class="cb-copy" @click="copyText(codeQrHtml, 'code-qr')" :class="{ copied: copiedKey === 'code-qr' }">
                <svg v-if="copiedKey !== 'code-qr'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                <span>{{ copiedKey === 'code-qr' ? 'Copied!' : 'Copy' }}</span>
              </button>
            </div>
            <pre class="cb-body" v-html="hlGeneric(codeQrHtml)"></pre>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const config = useRuntimeConfig()
const { siteName } = useSiteSettings()

const apiBase = computed(() => {
  const url = config.public.publicUrl || config.public.apiBaseUrl || ''
  if (url) return String(url).replace(/\/+$/, '')
  if (typeof window !== 'undefined') return window.location.origin
  return ''
})

// ── ENDPOINT — sesuai implementasi API ──
const EP_CREATE = '/api/v1/qris/create'
const EP_STATUS = '/api/v1/qris/:reference'
const EP_QR     = '/api/v1/qris/:reference/qr'
const EP_CANCEL = '/api/v1/qris/:reference/cancel'
const EP_REPLAY = '/api/v1/qris/:reference/replay-webhook'

const openSection = ref<string | null>(null)
const copiedKey = ref<string | null>(null)
const boxTab = reactive<Record<string, 'req' | 'res'>>({ status: 'req' })

function toggle(name: string) {
  openSection.value = openSection.value === name ? null : name
}

async function copyText(text: string, key: string) {
  try {
    await navigator.clipboard.writeText(text)
    copiedKey.value = key
    setTimeout(() => { if (copiedKey.value === key) copiedKey.value = null }, 1800)
  } catch {
    const ta = document.createElement('textarea')
    ta.value = text
    document.body.appendChild(ta)
    ta.select()
    try { document.execCommand('copy') } catch {}
    document.body.removeChild(ta)
    copiedKey.value = key
    setTimeout(() => { if (copiedKey.value === key) copiedKey.value = null }, 1800)
  }
}

// ── SYNTAX HIGHLIGHT ──
function esc(s: string) {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
}

function hlJson(src: string | Record<string, unknown>) {
  const raw = typeof src === 'string' ? src : JSON.stringify(src, null, 2)
  return esc(raw).replace(
    /("(?:\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(?:\s*:)?|\b(?:true|false|null)\b|-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?)/g,
    (m) => {
      let cls = 'tk-num'
      if (m.startsWith('&quot;') || m.startsWith('"')) cls = m.endsWith(':') || m.endsWith('&quot;:') ? 'tk-key' : 'tk-str'
      else if (m === 'true' || m === 'false') cls = 'tk-bool'
      else if (m === 'null') cls = 'tk-nil'
      return `<span class="${cls}">${m}</span>`
    }
  )
}

function hlHttp(src: string) {
  return esc(src)
    .replace(/^([A-Za-z-]+):/gm, '<span class="tk-key">$1</span>:')
    .replace(/(Bearer)([^\n<]*)/g, '<span class="tk-str">$1$2</span>')
}

function hlBash(src: string | Record<string, unknown>) {
  const raw = typeof src === 'string' ? src : JSON.stringify(src, null, 2)
  return esc(raw)
    .replace(/(&#39;|')([^']*?)\1/g, (m) => `<span class="tk-str">${m}</span>`)
    .replace(/(\\)(?=\n)/g, '<span class="tk-pn">\\</span>')
    .replace(/(-X|-H|-d)(?=\s)/g, '<span class="tk-key">$1</span>')
    .replace(/(^curl)/gm, '<span class="tk-fn">curl</span>')
}

function hlGeneric(src: string | Record<string, unknown>) {
  const raw = typeof src === 'string' ? src : JSON.stringify(src, null, 2)
  return esc(raw)
    .replace(/(^|[^:'"])\/\/[^\n]*/g, (m, p) => `${p}<span class="tk-cm">//${m.slice(p.length + 2)}</span>`)
    .replace(/('(?:[^'\\\n]|\\.)*')/g, '<span class="tk-str">$1</span>')
    .replace(/(&quot;.*?&quot;)/g, '<span class="tk-str">$1</span>')
    .replace(/\b(const|let|var|function|return|await|async|if|else|new|throw|require|import|from|export|true|false|null)\b/g, '<span class="tk-kw">$1</span>')
}

// ── CONTOH VALUES ──
const REF     = 'TPV-K8M4XQ2R-VN7WZL'
const AMOUNT  = 50000
const FEE     = 1450   // 2.9% dari setting fee_transaction_percent
const NET     = AMOUNT - FEE

const bodyCreate = `{
  "amount": ${AMOUNT},
  "reference": "${REF}",
  "callback_url": "https://webstore-kamu.com/webhook/tokopay",
  "expires_minutes": 15,
  "description": "Sepatu Sneakers Putih",
  "metadata": {
    "order_id": "TPV-2043",
    "product": "Sepatu Sneakers Putih"
  }
}`

const curlCreate = computed(() => `curl -X POST ${apiBase.value}${EP_CREATE} \\
  -H "Authorization: Bearer tpv_live_xxx" \\
  -H "Content-Type: application/json" \\
  -d '{
    "amount": ${AMOUNT},
    "reference": "${REF}",
    "callback_url": "https://webstore-kamu.com/webhook/tokopay",
    "expires_minutes": 15,
    "metadata": { "order_id": "TPV-2043" }
  }'`)

const responseCreate = computed(() => `{
  "success": true,
  "data": {
    "reference": "${REF}",
    "trx_id": "${REF}",
    "status": "PENDING",
    "payment_method": "QRIS",
    "amount": ${AMOUNT},
    "fee": ${FEE},
    "total": ${AMOUNT},
    "net": ${NET},
    "currency": "IDR",
    "qr_string": "00020101021226580014ID.CO.QRIS.WWW...",
    "qr_image": "${apiBase.value}/api/v1/qris/${REF}/qr",
    "expires_at": "2026-10-18T02:30:00.000Z",
    "created_at": "2026-10-18T02:15:00.000Z"
  }
}`)

const curlStatus = computed(() => `curl ${apiBase.value}/api/v1/qris/${REF} \\
  -H "Authorization: Bearer tpv_live_xxx"`)

const responseStatus = computed(() => `{
  "success": true,
  "data": {
    "reference": "${REF}",
    "trx_id": "${REF}",
    "status": "PAID",
    "payment_method": "QRIS",
    "amount": ${AMOUNT},
    "fee": ${FEE},
    "total": ${AMOUNT},
    "net": ${NET},
    "currency": "IDR",
    "paid_at": "2026-10-18T02:21:00.000Z",
    "expires_at": "2026-10-18T02:30:00.000Z"
  }
}`)

const curlReplay = computed(() => `curl -X POST ${apiBase.value}/api/v1/qris/${REF}/replay-webhook \\
  -H "Authorization: Bearer tpv_live_xxx"`)

const payloadPaid = computed(() => `{
  "event": "payment.paid",
  "success": true,
  "data": {
    "reference": "${REF}",
    "status": "PAID",
    "paymentMethod": "QRIS",
    "amount": ${AMOUNT},
    "fee": ${FEE},
    "net": ${NET},
    "amountToPay": ${AMOUNT},
    "currency": "IDR",
    "customerName": "Budi",
    "customerEmail": "budi@mail.com",
    "description": "Sepatu Sneakers Putih",
    "createdAt": "2026-10-18T02:15:00.000Z",
    "expiresAt": "2026-10-18T02:30:00.000Z",
    "paidAt": "2026-10-18T02:21:00.000Z"
  }
}`)

const payloadExpired = computed(() => `{
  "event": "payment.expired",
  "success": true,
  "data": {
    "reference": "${REF}",
    "status": "EXPIRED",
    "paymentMethod": "QRIS",
    "amount": ${AMOUNT},
    "fee": ${FEE},
    "net": ${NET},
    "amountToPay": ${AMOUNT},
    "currency": "IDR",
    "customerName": null,
    "customerEmail": null,
    "description": "Sepatu Sneakers Putih",
    "createdAt": "2026-10-18T02:15:00.000Z",
    "expiresAt": "2026-10-18T02:30:00.000Z",
    "paidAt": null
  }
}`)

const codeHandlerNode = `// Express — handler callback TokoPay
app.post('/webhook/tokopay', express.json(), (req, res) => {
  const event = req.headers['x-event']   // payment.paid / payment.expired
  const trxId = req.headers['x-trx-id']  // ID transaksi
  const data  = req.body.data            // { reference, status, amount, fee, net, ... }

  if (event === 'payment.paid') {
    // tandai order lunas: data.reference, data.amount, data.net
  }
  if (event === 'payment.expired') {
    // tandai order kadaluarsa
  }

  // WAJIB balas 2xx biar retry berhenti
  res.status(200).json({ received: true })
})`

const codeCheckoutPhp = computed(() => `<?php
// ============================================
// 1. BUAT PEMBAYARAN — dipanggil saat checkout
// ============================================
 $apiKey  = getenv('API_KEY');
 $baseUrl = '${apiBase.value}';

function createQrisPayment(string $apiKey, string $baseUrl, array $order): array
{
    $payload = json_encode([
        'amount'          => $order['amount'],
        'reference'       => $order['reference'],
        'callback_url'    => 'https://webstore-kamu.com/webhook/tokopay',
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

    if ($code !== 201 && $code !== 200) {
        throw new RuntimeException("Gagal membuat pembayaran (HTTP $code): $body");
    }

    return json_decode($body, true)['data'];
}

// --- contoh pemanggilan ---
 $payment = createQrisPayment($apiKey, $baseUrl, [
    'id'        => 'TPV-2043',
    'reference' => '${REF}',
    'amount'    => ${AMOUNT},
    'product'   => 'Sepatu Sneakers Putih',
]);

// simpan reference untuk pencocokan callback
// UPDATE orders SET reference = ? WHERE id = ?
echo $payment['qr_image'];`)

const codeCallbackPhp = `<?php
// ==================================================
// 2. CALLBACK HANDLER — https://webstore-kamu.com/webhook/tokopay
//    Simpan file ini sebagai webhook/tokopay/index.php
// ==================================================

 $rawBody = file_get_contents('php://input');
 $event   = json_decode($rawBody, true);

if (json_last_error() !== JSON_ERROR_NONE) {
    http_response_code(400);
    exit;
}

// ── 1. Baca event dari header ──
 $eventName = $_SERVER['HTTP_X_EVENT'] ?? '';   // payment.paid / payment.expired
 $reference = $event['data']['reference'] ?? '';

// ── 2. Proses berdasarkan event ──
switch ($eventName) {
    case 'payment.paid':
        // UPDATE orders SET status = 'PAID' WHERE reference = ?
        break;

    case 'payment.expired':
        // UPDATE orders SET status = 'EXPIRED' WHERE reference = ?
        break;
}

// ── 3. WAJIB balas 2xx biar retry berhenti ──
http_response_code(200);
echo 'OK';`

const codeQrHtml = `<img src="{qr_image dari response}" alt="QRIS" width="280">`
</script>

<style scoped>
.docs-page { min-height: 100vh; background: #f7f6fb; color: #241f35; font-family: ui-sans-serif, system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif; }
.docs-page a { color: inherit; }
.docs-page ::selection { background: rgba(124,58,237,.18); }
.docs-page .wrap { max-width: 1060px; margin: 0 auto; padding: 40px 20px 80px; }

/* HERO */
.docs-page .hero { text-align: center; margin-bottom: 30px; }
.docs-page .hero-eyebrow { display: inline-flex; align-items: center; gap: 8px; font-size: 12.5px; font-weight: 700; letter-spacing: .12em; text-transform: uppercase; color: #7c3aed; background: rgba(124,58,237,.07); border: 1px solid rgba(124,58,237,.22); padding: 6px 14px; border-radius: 999px; }
.docs-page .hero-dot { width: 7px; height: 7px; border-radius: 50%; background: #7c3aed; box-shadow: 0 0 0 3px rgba(124,58,237,.15); }
.docs-page .hero h1 { font-size: clamp(32px, 5.5vw, 48px); font-weight: 800; letter-spacing: -.04em; margin: 18px 0 10px; color: #1c1730; }
.docs-page .hero-sub { color: #6f6a85; font-size: 16px; }
.docs-page .hero-tags { display: flex; gap: 8px; justify-content: center; margin-top: 16px; flex-wrap: wrap; }
.docs-page .hero-tag { font-size: 12px; font-weight: 650; color: #55506e; background: #fff; border: 1px solid #e5e1f2; padding: 5px 12px; border-radius: 999px; }

/* INFO BOX */
.docs-page .info-box { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin: 6px 0 22px; }
.docs-page .info-col { background: #fff; border: 1px solid #e9e5f4; border-radius: 16px; padding: 16px 18px; }
.docs-page .info-label { font-size: 11px; font-weight: 750; letter-spacing: .14em; text-transform: uppercase; color: #8d88a6; margin-bottom: 8px; }
.docs-page .info-value-wrap { display: flex; align-items: center; gap: 10px; }
.docs-page .info-value { font-family: ui-monospace, 'SF Mono', Menlo, Consolas, monospace; font-size: 13px; color: #6d28d9; word-break: break-all; flex: 1; font-weight: 650; }
.docs-page .info-copy { flex: none; width: 30px; height: 30px; display: grid; place-items: center; border-radius: 8px; border: 1px solid #e5e1f2; background: #faf9fe; color: #6f6a85; cursor: pointer; }
.docs-page .info-copy svg { width: 14px; height: 14px; }
.docs-page .info-copy.copied { color: #059669; border-color: rgba(5,150,105,.4); }

/* CARDS / SECTIONS */
.docs-page .card { background: #fff; border: 1px solid #e9e5f4; border-radius: 18px; margin-bottom: 16px; overflow: hidden; }
.docs-page .card-head { width: 100%; display: flex; align-items: center; justify-content: space-between; padding: 18px 22px; background: none; border: none; cursor: pointer; text-align: left; }
.docs-page .card-head.static { cursor: default; }
.docs-page .card-head h2 { font-size: 17px; font-weight: 800; color: #1c1730; display: flex; align-items: center; gap: 12px; margin: 0; }
.docs-page .num { font-size: 12px; font-weight: 800; color: #7c3aed; background: rgba(124,58,237,.08); border: 1px solid rgba(124,58,237,.22); padding: 4px 9px; border-radius: 8px; }
.docs-page .chev { color: #8d88a6; }
.docs-page .chev svg { width: 18px; height: 18px; }
.docs-page .card-body { padding: 4px 22px 22px; }
.docs-page .card-body > p { font-size: 14px; line-height: 1.75; color: #55506e; margin: 10px 0; }
.docs-page .card-body code { font-family: ui-monospace, Menlo, Consolas, monospace; font-size: 12.5px; background: rgba(124,58,237,.07); color: #6d28d9; padding: 2px 7px; border-radius: 6px; font-weight: 650; }
.docs-page .ep { display: flex; align-items: center; gap: 10px; margin: 12px 0; }
.docs-page .ep code { font-size: 13.5px; background: #14101f; border: 1px solid #2a2338; color: #7dd3fc; }
.docs-page .link { color: #7c3aed; font-weight: 650; }
.docs-page .method { font-size: 11px; font-weight: 800; letter-spacing: .06em; padding: 4px 10px; border-radius: 7px; }
.docs-page .method.post { background: rgba(124,58,237,.08); color: #7c3aed; border: 1px solid rgba(124,58,237,.25); }
.docs-page .method.get { background: rgba(5,150,105,.08); color: #059669; border: 1px solid rgba(5,150,105,.25); }
.docs-page .sub-label { font-size: 11.5px; font-weight: 800; letter-spacing: .12em; text-transform: uppercase; color: #8d88a6; margin: 20px 0 10px; }
.docs-page .req { color: #059669; font-weight: 700; font-size: 12px; }
.docs-page .ok-code { font-size: 10px; font-weight: 800; color: #34d399; background: rgba(52,211,153,.12); padding: 1px 6px; border-radius: 6px; margin-left: 4px; }
.docs-page .warn-box { background: rgba(217,119,6,.06); border: 1px solid rgba(217,119,6,.28); border-radius: 12px; padding: 12px 16px; font-size: 13.5px; line-height: 1.7; color: #92400e; margin: 14px 0; }
.docs-page .warn-box code { background: rgba(217,119,6,.1); color: #b45309; }

/* CODEBOX — dark */
.docs-page .codebox { background: #14101f; border: 1px solid #2a2338; border-radius: 14px; overflow: hidden; margin: 12px 0; box-shadow: 0 12px 34px -14px rgba(76,29,149,.45); }
.docs-page .codebox.tall pre.cb-body { max-height: 480px; overflow: auto; }
.docs-page .codebox-head { display: flex; align-items: center; justify-content: space-between; gap: 12px; padding: 9px 14px; background: rgba(255,255,255,.03); border-bottom: 1px solid #241d33; }
.docs-page .cb-tabs { display: flex; gap: 4px; }
.docs-page .cb-tab { font-size: 11px; font-weight: 800; letter-spacing: .1em; color: #8d84a3; background: none; border: 1px solid transparent; padding: 6px 12px; border-radius: 8px; cursor: pointer; }
.docs-page .cb-tab:hover { color: #d9d2ea; }
.docs-page .cb-tab.on { color: #cdb6ff; background: rgba(124,58,237,.2); border-color: rgba(124,58,237,.4); }
.docs-page .cb-code { font-size: 10px; font-weight: 800; color: #34d399; background: rgba(52,211,153,.12); padding: 1px 6px; border-radius: 6px; margin-left: 4px; }
.docs-page .cb-lang { font-size: 11px; font-weight: 800; letter-spacing: .1em; color: #8d84a3; }
.docs-page .cb-copy { display: inline-flex; align-items: center; gap: 6px; font-size: 11.5px; font-weight: 700; color: #b6aecd; background: rgba(255,255,255,.05); border: 1px solid #2f2840; padding: 5px 11px; border-radius: 8px; cursor: pointer; }
.docs-page .cb-copy svg { width: 13px; height: 13px; }
.docs-page .cb-copy:hover { color: #e4dbf5; border-color: rgba(124,58,237,.45); }
.docs-page .cb-copy.copied { color: #34d399; border-color: rgba(52,211,153,.4); }
.docs-page pre.cb-body { margin: 0; padding: 16px 18px; overflow-x: auto; font-family: ui-monospace, 'SF Mono', Menlo, Consolas, monospace; font-size: 12.8px; line-height: 1.7; color: #d4cce6; white-space: pre; }

/* TOKENS */
.docs-page .tk-key { color: #7dd3fc; }
.docs-page .tk-str { color: #86efac; }
.docs-page .tk-num { color: #fbbf24; }
.docs-page .tk-bool { color: #f472b6; }
.docs-page .tk-nil { color: #f472b6; }
.docs-page .tk-cm { color: #6f6a85; font-style: italic; }
.docs-page .tk-kw { color: #cdb6ff; }
.docs-page .tk-fn { color: #a78bfa; font-weight: 700; }
.docs-page .tk-pn { color: #55506e; }

/* TABLE */
.docs-page .table-wrap { overflow-x: auto; border: 1px solid #e9e5f4; border-radius: 12px; margin: 10px 0; }
.docs-page table { width: 100%; border-collapse: collapse; font-size: 13px; }
.docs-page th { text-align: left; font-size: 11px; font-weight: 800; letter-spacing: .1em; text-transform: uppercase; color: #8d88a6; background: #faf9fe; padding: 11px 14px; }
.docs-page td { padding: 11px 14px; border-top: 1px solid #efecf8; color: #3d3757; vertical-align: top; }

@media (max-width: 720px) {
  .docs-page .info-box { grid-template-columns: 1fr; }
  .docs-page .card-head, .docs-page .card-body { padding-left: 16px; padding-right: 16px; }
  .docs-page pre.cb-body { font-size: 11.5px; }
}
</style>
