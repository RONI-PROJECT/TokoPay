<template>
  <div class="docs-page">
    <main class="content">
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
          <span class="hero-tag">Callback Auto-Retry</span>
        </div>
      </div>

      <!-- TAB NAV -->
      <div class="sec-tabs">
        <a v-for="t in secTabs" :key="t.id" :href="'#' + t.id" class="sec-tab" :class="{ on: activeTab === t.id }" @click="activeTab = t.id">{{ t.label }}</a>
      </div>

      <!-- BASE + AUTH -->
      <div id="pengenalan" class="info-box">
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
            <code class="info-value">Authorization: Bearer tpv_live_xxx</code>
            <button class="info-copy" @click="copyText('Authorization: Bearer tpv_live_xxx', 'auth')" :class="{ copied: copiedKey === 'auth' }" aria-label="Copy auth header">
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

      <!-- ALUR STATUS -->
      <div class="flow-box">
        <div class="flow-label">Alur Status Transaksi</div>
        <div class="flow-chips">
          <span class="chip c-info">QR Dibuat</span>
          <span class="flow-arrow">→</span>
          <span class="chip c-warn">Menunggu Pembayaran</span>
          <span class="flow-arrow">→</span>
          <span class="chip c-ok">PAID</span>
          <span class="flow-or">atau</span>
          <span class="chip c-bad">EXPIRED</span>
        </div>
      </div>

      <!-- SANDBOX VS PRODUCTION -->
      <div id="sandbox" class="mode-grid">
        <div class="mode-card test">
          <div class="mode-head">
            <span class="mode-icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14.7 6.3a5 5 0 1 1-9.4 2.4A7 7 0 1 0 14.7 6.3z"/><circle cx="17" cy="17" r="3"/></svg>
            </span>
            <div>
              <div class="mode-title">SANDBOX — Testing</div>
              <div class="mode-sub">Simulasi pembayaran, tanpa uang asli</div>
            </div>
          </div>
          <div class="mode-key"><code>Authorization: Bearer tpv_test_xxx</code></div>
          <p>Set <code>SANDBOX_MODE=1</code>. Transaksi dibuat dengan status <code>PENDING</code>, lalu bisa dilunasi manual dari dashboard untuk menguji webhook end-to-end.</p>
        </div>
        <div class="mode-card live">
          <div class="mode-head">
            <span class="mode-icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4.5 16.5c-1.5 1.26-2 5-2 5s3.74-.5 5-2c.71-.84.7-2.13-.09-2.91a2.18 2.18 0 0 0-2.91-.09z"/><path d="M12 15l-3-3a22 22 0 0 1 2-3.95A12.88 12.88 0 0 1 22 2c0 2.72-.78 7.5-6 11a22.35 22.35 0 0 1-4 2z"/><path d="M9 12H4s.55-3.03 2-4c1.62-1.08 5 0 5 0"/><path d="M12 15v5s3.03-.55 4-2c1.08-1.62 0-5 0-5"/></svg>
            </span>
            <div>
              <div class="mode-title">PRODUCTION — Live</div>
              <div class="mode-sub">Dana asli masuk ke saldo merchant</div>
            </div>
          </div>
          <div class="mode-key"><code>Authorization: Bearer tpv_live_xxx</code></div>
          <p>Key produksi otomatis memverifikasi pembayaran lewat QRIS dinamis. Uang masuk ke saldo, lalu bisa ditarik via menu Tarik Dana.</p>
        </div>
      </div>

      <!-- DAFTAR ENDPOINT -->
      <div id="endpoints" class="card open">
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
                  <td><code>callback_url kamu</code></td>
                  <td>Callback payment.paid / payment.expired</td>
                </tr>
                <tr>
                  <td><span class="method post">POST</span></td>
                  <td><code>/api/v1/qris/:reference/cancel</code></td>
                  <td>Batalkan transaksi PENDING</td>
                </tr>
                <tr>
                  <td><span class="method post">POST</span></td>
                  <td><code>/api/v1/qris/:reference/replay-webhook</code></td>
                  <td>Kirim ulang callback manual</td>
                </tr>
              </tbody>
            </table>
          </div>
          <p>Semua request &amp; response memakai format <code>JSON</code>. Rate limit berlaku per API key.</p>
        </div>
      </div>

      <!-- AUTENTIKASI -->
      <div id="autentikasi" class="card open">
        <div class="card-head static">
          <h2><span class="num">02</span> Autentikasi</h2>
        </div>
        <div class="card-body">
          <p>Semua endpoint diautentikasi pakai <strong>API key</strong> via header <code>Authorization: Bearer</code>. API key didapat setelah daftar di <NuxtLink to="/register" class="link">Register</NuxtLink> — bisa dibuat banyak (multi key) dan di-rotate kapan saja dari dashboard.</p>
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

        </div>
      </div>

      <!-- BUAT PEMBAYARAN -->
      <div id="buat-qris" class="card open">
        <div class="card-head static">
          <h2><span class="num">03</span> Buat Pembayaran QRIS</h2>
        </div>
        <div class="card-body">
          <p class="ep"><span class="method post">POST</span> <code>{{ EP_CREATE }}</code></p>

          <p>Metode pembayaran yang digunakan adalah <strong>QRIS</strong> — satu QR kode yang bisa dibayar dari semua mobile banking dan e-wallet (GoPay, OVO, DANA, ShopeePay, BCA, Mandiri, BNI, BRI, dll). QR dibuat dinamis dengan nominal ter-encode, sehingga pembayaran terdeteksi otomatis.</p>

          <div class="codebox tall">
            <div class="codebox-head">
              <div class="cb-tabs">
                <button class="cb-tab" :class="{ on: boxTab.create === 'req' }" @click="boxTab.create = 'req'">REQUEST</button>
                <button class="cb-tab" :class="{ on: boxTab.create === 'res' }" @click="boxTab.create = 'res'">RESPONSE <span class="cb-code">201</span></button>
              </div>
              <button class="cb-copy" @click="copyText(boxTab.create === 'req' ? curlCreate : responseCreate, 'cb-create')" :class="{ copied: copiedKey === 'cb-create' }">
                <svg v-if="copiedKey !== 'cb-create'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                <span>{{ copiedKey === 'cb-create' ? 'Copied!' : 'Copy' }}</span>
              </button>
            </div>
            <pre v-if="boxTab.create === 'req'" class="cb-body" v-html="hlBash(curlCreate)"></pre>
            <pre v-else class="cb-body" v-html="hlJson(responseCreate)"></pre>
          </div>

          <div class="sub-label">Parameter Body</div>
          <div class="table-wrap">
            <table>
              <thead><tr><th>Field</th><th>Wajib</th><th>Keterangan</th></tr></thead>
              <tbody>
                <tr><td><code>amount</code></td><td><span class="req">Ya</span></td><td>Nominal pembayaran (Rp), min. Rp 1.000</td></tr>
                <tr><td><code>reference</code></td><td>—</td><td>ID order kamu. Auto-generate (format <code>TRX-XXXXXXXXXXXX</code>) kalau kosong</td></tr>
                <tr><td><code>callback_url</code></td><td>—</td><td>Webhook URL khusus transaksi ini</td></tr>
                <tr><td><code>expires_minutes</code></td><td>—</td><td>Masa berlaku QR (menit). Default 15</td></tr>
                <tr><td><code>metadata</code></td><td>—</td><td>Object bebas, dibalikin apa adanya di webhook</td></tr>
              </tbody>
            </table>
          </div>

          <div class="sub-label">Menampilkan QR ke Customer</div>
          <p>Response sudah menyertakan <code>qr_image</code> (URL gambar QR siap tampil). Cukup render:</p>
          <div class="codebox">
            <div class="codebox-head">
              <span class="cb-lang">HTML</span>
              <button class="cb-copy" @click="copyText(codeQrHtml, 'code-qr-html')" :class="{ copied: copiedKey === 'code-qr-html' }">
                <svg v-if="copiedKey !== 'code-qr-html'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                <span>{{ copiedKey === 'code-qr-html' ? 'Copied!' : 'Copy' }}</span>
              </button>
            </div>
            <pre class="cb-body" v-html="hlGeneric(codeQrHtml)"></pre>
          </div>
        </div>
      </div>

      <!-- CEK STATUS -->
      <div id="cek-status" class="card open">
        <div class="card-head static">
          <h2><span class="num">04</span> Cek Status Pembayaran</h2>
        </div>
        <div class="card-body">
          <p class="ep"><span class="method get">GET</span> <code>{{ EP_STATUS }}</code></p>
          <p>Gunakan endpoint ini untuk polling status atau konfirmasi akhir setelah webhook. Status yang mungkin: <code>PENDING</code> · <code>PAID</code> · <code>EXPIRED</code>.</p>

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
      <!-- WEBHOOK -->
      <div id="webhook" class="card open">
        <div class="card-head static">
          <h2><span class="num">05</span> Webhook</h2>
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
              <button class="cb-copy" @click="copyText(codeVerifyNode, 'code-verify')" :class="{ copied: copiedKey === 'code-verify' }">
                <svg v-if="copiedKey !== 'code-verify'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                <span>{{ copiedKey === 'code-verify' ? 'Copied!' : 'Copy' }}</span>
              </button>
            </div>
            <pre class="cb-body" v-html="hlGeneric(codeVerifyNode)"></pre>
          </div>

          <p>Retry otomatis: kalau gagal (timeout / non-2xx) dicoba ulang maksimal <strong>12x</strong> dengan jarak makin lama (30 detik → 15 menit), timeout per request 10 detik. Proses bisnis boleh async — yang penting balas <code>2xx</code> secepatnya.</p>
          <p>Alamat tujuan callback, urutannya: <code>callback_url</code> per transaksi → URL webhook yang diisi di dashboard → env <code>WEBHOOK_URL</code>. Kalau nggak ada satupun, callback nggak dikirim — pakai polling <code>GET</code> status aja. Callback gagal kirim? Kirim ulang manual: <code>POST /api/v1/qris/:reference/replay-webhook</code>.</p>
        </div>
      </div>

      <!-- PHP -->
      <div id="contoh-php" class="card">
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

          <div class="sub-label">2. Halaman Bayar (tampilkan QR)</div>
          <div class="codebox">
            <div class="codebox-head">
              <span class="cb-lang">PHP</span>
              <button class="cb-copy" @click="copyText(codePayPagePhp, 'code-php-2')" :class="{ copied: copiedKey === 'code-php-2' }">
                <svg v-if="copiedKey !== 'code-php-2'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                <span>{{ copiedKey === 'code-php-2' ? 'Copied!' : 'Copy' }}</span>
              </button>
            </div>
            <pre class="cb-body" v-html="hlGeneric(codePayPagePhp)"></pre>
          </div>

          <div class="sub-label">3. Callback Handler (webhook)</div>
          <div class="codebox">
            <div class="codebox-head">
              <span class="cb-lang">PHP</span>
              <button class="cb-copy" @click="copyText(codeCallbackPhp, 'code-php-3')" :class="{ copied: copiedKey === 'code-php-3' }">
                <svg v-if="copiedKey !== 'code-php-3'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                <span>{{ copiedKey === 'code-php-3' ? 'Copied!' : 'Copy' }}</span>
              </button>
            </div>
            <pre class="cb-body" v-html="hlGeneric(codeCallbackPhp)"></pre>
          </div>
        </div>
      </div>

      <!-- NODE.JS -->
      <div id="contoh-node" class="card">
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
          <div class="codebox">
            <div class="codebox-head">
              <span class="cb-lang">JAVASCRIPT</span>
              <button class="cb-copy" @click="copyText(codeNode, 'code-node')" :class="{ copied: copiedKey === 'code-node' }">
                <svg v-if="copiedKey !== 'code-node'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                <span>{{ copiedKey === 'code-node' ? 'Copied!' : 'Copy' }}</span>
              </button>
            </div>
            <pre class="cb-body" v-html="hlGeneric(codeNode)"></pre>
          </div>
        </div>
      </div>

      <!-- ERROR CODES -->
      <div id="error-codes" class="card">
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

      <div class="footer-links">
        <NuxtLink to="/tos">Syarat &amp; Ketentuan →</NuxtLink>
        <NuxtLink to="/privacy">Kebijakan Privasi →</NuxtLink>
        <NuxtLink to="/disclaimer">Disclaimer →</NuxtLink>
      </div>
    </main>

    <SiteCopyright />
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

const openSection = ref<string | null>(null)
const copiedKey = ref<string | null>(null)
const activeTab = ref('pengenalan')

const secTabs = [
  { id: 'pengenalan', label: 'Pengenalan' },
  { id: 'autentikasi', label: 'Autentikasi' },
  { id: 'sandbox', label: 'Sandbox vs Production' },
  { id: 'buat-qris', label: 'Buat QRIS' },
  { id: 'webhook', label: 'Webhook' },
  { id: 'contoh-php', label: 'Contoh Kode' },
]

const boxTab = reactive<Record<string, 'req' | 'res'>>({ create: 'req', status: 'req' })

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
    .replace(/(Bearer|tpv_live_|tpv_test_|rp_live_|rp_test_)([^\n<]*)/g, '<span class="tk-str">$1$2</span>')
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

// ── CONTOH VALUES (TokoPayVIP) ──
const REF     = 'TPV-K8M4XQ2R-VN7WZL'
const AMOUNT  = 50000
const FEE     = 1450   // 2.9% sesuai setting fee_transaction_percent
const NET     = AMOUNT - FEE

const curlCreate = computed(() => `curl -X POST ${apiBase.value}${EP_CREATE} \\
  -H "Authorization: Bearer tpv_live_xxx" \\
  -H "Content-Type: application/json" \\
  -d '{
    "amount": ${AMOUNT},
    "reference": "${REF}",
    "callback_url": "https://webstore-kamu.com/webhook/tokopay",
    "expires_minutes": 15,
    "metadata": {
      "order_id": "TPV-2043",
      "product": "Sepatu Sneakers Putih"
    }
  }'`)

const responseCreate = computed(() => `{
  "success": true,
  "data": {
    "reference": "${REF}",
    "trx_id": "TRX-7HKM4XQ2R9VZ",
    "status": "PENDING",
    "payment_method": "QRIS",
    "amount": ${AMOUNT},
    "fee": ${FEE},
    "total": ${AMOUNT},
    "net": ${NET},
    "currency": "IDR",
    "qr_string": "00020101021226580014ID.CO.QRIS.WWW...",
    "qr_image": "${apiBase.value}/api/v1/qris/TRX-7HKM4XQ2R9VZ/qr",
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
    "trx_id": "TRX-7HKM4XQ2R9VZ",
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

const codeVerifyNode = `// Express — handler callback TokoPay
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

const codeQrHtml = `<img src="{qr_image dari response}" alt="QRIS" width="280">`

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

    if ($code !== 200) {
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

// simpan reference untuk pencocokan webhook
// UPDATE orders SET reference = ? WHERE id = ?
echo $payment['qr_image'];`)

const codePayPagePhp = computed(() => `<?php
// ============================================
// 2. HALAMAN BAYAR — tampilkan QR ke customer
//    $payment = hasil dari createQrisPayment()
// ============================================
 $expiresAt = new DateTime($payment['expires_at']);
 $now       = new DateTime('now', new DateTimeZone('UTC'));
 $minutesLeft = max(0, $expiresAt->getTimestamp() - $now->getTimestamp()) / 60;
?>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Selesaikan Pembayaran</title>
  <style>
    body { font-family: sans-serif; display: flex; justify-content: center;
           align-items: center; min-height: 100vh; margin: 0; background: #f5f5f5; }
    .pay-card { background: #fff; padding: 32px; border-radius: 16px;
                text-align: center; box-shadow: 0 8px 30px rgba(0,0,0,.08); }
    .amount  { font-size: 28px; font-weight: 800; margin: 8px 0 4px; }
    .countdown { color: #d97706; font-weight: 700; font-size: 14px; }
    .qr { margin: 20px 0; }
    .hint { color: #666; font-size: 13px; line-height: 1.6; }
  </style>
</head>
<body>
  <div class="pay-card">
    <h2>Scan QRIS untuk Bayar</h2>
    <div class="amount">Rp <?= number_format($payment['amount'], 0, ',', '.') ?></div>
    <div class="countdown">Berlaku <?= floor($minutesLeft) ?> menit</div>
    <div class="qr">
      <img src="<?= htmlspecialchars($payment['qr_image']) ?>"
           alt="QRIS" width="280" height="280">
    </div>
    <p class="hint">
      Buka aplikasi mobile banking / e-wallet apa pun<br>
      yang mendukung QRIS, lalu scan kode di atas.
    </p>
  </div>

  <script>
    // polling status tiap 3 detik — atau andalkan webhook di server
    setInterval(async () => {
      try {
        const r = await fetch('/check-status.php?ref=<?= $payment['reference'] ?>');
        const j = await r.json();
        if (j?.data?.status === 'PAID') {
          location.href = '/success?ref=<?= $payment['reference'] ?>';
        }
      } catch (e) { /* biarin retry di tick berikutnya */ }
    }, 3000);
  <\/script>
</body>
</html>`)

const codeCallbackPhp = `<?php
// ==================================================
// 3. CALLBACK HANDLER — https://webstore-kamu.com/webhook/tokopay
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
        // UPDATE saldo merchant, kirim barang, dll
        break;

    case 'payment.expired':
        // UPDATE orders SET status = 'EXPIRED' WHERE reference = ?
        break;
}

// ── 3. WAJIB balas 2xx biar retry berhenti ──
http_response_code(200);
echo 'OK';`

const codeNode = computed(() => `const express = require('express')
const app = express()

const TOKOPAY_URL = '${apiBase.value}'
const API_KEY = process.env.API_KEY

// 1. Buat pembayaran QRIS
async function createQris(amount, reference, metadata) {
  const r = await fetch(TOKOPAY_URL + '/api/v1/qris/create', {
    method: 'POST',
    headers: {
      'Authorization': 'Bearer ' + API_KEY,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ amount, reference, metadata, expires_minutes: 15 }),
  })
  const j = await r.json()
  if (!j.success) throw new Error(j.message)
  return j.data // { reference, qr_string, qr_image, expires_at, ... }
}

// 2. Callback handler — baca X-Event, cocokkan reference, balas 2xx
app.post('/webhook/tokopay', express.json(), (req, res) => {
  const event = req.headers['x-event']   // payment.paid / payment.expired
  const data  = req.body.data

  if (event === 'payment.paid') {
    // tandai order lunas: data.reference, data.amount, data.net
  }

  res.status(200).json({ received: true })
})

app.listen(3000)`)
</script>

<style>
.docs-page { min-height: 100vh; background: #f7f6fb; color: #241f35; font-family: ui-sans-serif, system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif; }
.docs-page a { color: inherit; }
.docs-page ::selection { background: rgba(124,58,237,.18); }

/* NAV */
.docs-page .nav { position: sticky; top: 0; z-index: 50; backdrop-filter: blur(14px); background: rgba(255,255,255,.82); border-bottom: 1px solid #eae6f4; }
.docs-page .nav-inner { max-width: 1060px; margin: 0 auto; padding: 14px 20px; display: flex; align-items: center; gap: 18px; }
.docs-page .brand { display: flex; align-items: center; }
.docs-page .brand img { height: 30px; }
.docs-page .nav-links { display: flex; gap: 16px; margin-left: 8px; font-size: 14px; color: #6f6a85; }
.docs-page .nav-links a:hover { color: #241f35; }
.docs-page .nav-links a.active { color: #7c3aed; font-weight: 700; }
.docs-page .nav-actions { margin-left: auto; display: flex; gap: 10px; }
.docs-page .btn-ghost { font-size: 13.5px; font-weight: 650; padding: 8px 16px; border-radius: 10px; border: 1px solid #e0dcf0; color: #3d3757; background: #fff; }
.docs-page .btn-grad { font-size: 13.5px; font-weight: 700; padding: 8px 16px; border-radius: 10px; background: linear-gradient(135deg, #7c3aed, #a855f7); color: #fff; box-shadow: 0 6px 20px -6px rgba(124,58,237,.5); }

/* HERO */
.docs-page .content { max-width: 1060px; margin: 0 auto; padding: 44px 20px 80px; }
.docs-page .hero { text-align: center; margin-bottom: 30px; }
.docs-page .hero-eyebrow { display: inline-flex; align-items: center; gap: 8px; font-size: 12.5px; font-weight: 700; letter-spacing: .12em; text-transform: uppercase; color: #7c3aed; background: rgba(124,58,237,.07); border: 1px solid rgba(124,58,237,.22); padding: 6px 14px; border-radius: 999px; }
.docs-page .hero-dot { width: 7px; height: 7px; border-radius: 50%; background: #7c3aed; box-shadow: 0 0 0 3px rgba(124,58,237,.15); }
.docs-page .hero h1 { font-size: clamp(34px, 6vw, 52px); font-weight: 800; letter-spacing: -.04em; margin: 18px 0 10px; color: #1c1730; }
.docs-page .hero-sub { color: #6f6a85; font-size: 16px; }
.docs-page .hero-tags { display: flex; gap: 8px; justify-content: center; margin-top: 16px; flex-wrap: wrap; }
.docs-page .hero-tag { font-size: 12px; font-weight: 650; color: #55506e; background: #fff; border: 1px solid #e5e1f2; padding: 5px 12px; border-radius: 999px; }

/* SECTION TABS */
.docs-page .sec-tabs { display: flex; gap: 6px; overflow-x: auto; padding: 10px 2px 18px; scrollbar-width: none; }
.docs-page .sec-tabs::-webkit-scrollbar { display: none; }
.docs-page .sec-tab { flex: none; font-size: 13px; font-weight: 650; color: #55506e; padding: 8px 16px; border-radius: 10px; border: 1px solid #e5e1f2; background: #fff; white-space: nowrap; transition: all .15s; }
.docs-page .sec-tab:hover { color: #7c3aed; border-color: rgba(124,58,237,.35); }
.docs-page .sec-tab.on { color: #fff; background: linear-gradient(135deg, #7c3aed, #a855f7); border-color: transparent; }

/* INFO BOX */
.docs-page .info-box { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin: 6px 0 22px; }
.docs-page .info-col { background: #fff; border: 1px solid #e9e5f4; border-radius: 16px; padding: 16px 18px; }
.docs-page .info-label { font-size: 11px; font-weight: 750; letter-spacing: .14em; text-transform: uppercase; color: #8d88a6; margin-bottom: 8px; }
.docs-page .info-value-wrap { display: flex; align-items: center; gap: 10px; }
.docs-page .info-value { font-family: ui-monospace, 'SF Mono', Menlo, Consolas, monospace; font-size: 13px; color: #6d28d9; word-break: break-all; flex: 1; font-weight: 650; }
.docs-page .info-copy { flex: none; width: 30px; height: 30px; display: grid; place-items: center; border-radius: 8px; border: 1px solid #e5e1f2; background: #faf9fe; color: #6f6a85; cursor: pointer; }
.docs-page .info-copy svg { width: 14px; height: 14px; }
.docs-page .info-copy.copied { color: #059669; border-color: rgba(5,150,105,.4); }

/* FLOW */
.docs-page .flow-box { background: #fff; border: 1px solid #e9e5f4; border-radius: 16px; padding: 16px 18px; margin-bottom: 22px; }
.docs-page .flow-label { font-size: 11px; font-weight: 750; letter-spacing: .14em; text-transform: uppercase; color: #8d88a6; margin-bottom: 10px; }
.docs-page .flow-chips { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
.docs-page .chip { font-size: 12px; font-weight: 750; padding: 5px 12px; border-radius: 999px; }
.docs-page .chip.c-info { background: rgba(14,165,233,.08); color: #0284c7; border: 1px solid rgba(14,165,233,.25); }
.docs-page .chip.c-warn { background: rgba(217,119,6,.08); color: #b45309; border: 1px solid rgba(217,119,6,.25); }
.docs-page .chip.c-ok { background: rgba(5,150,105,.08); color: #059669; border: 1px solid rgba(5,150,105,.3); }
.docs-page .chip.c-bad { background: rgba(225,29,72,.07); color: #e11d48; border: 1px solid rgba(225,29,72,.22); }
.docs-page .flow-arrow { color: #b0abc5; font-weight: 700; }
.docs-page .flow-or { font-size: 12px; color: #8d88a6; font-style: italic; }

/* MODE CARDS */
.docs-page .mode-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 26px; }
.docs-page .mode-card { border-radius: 18px; padding: 18px 20px; border: 1px solid #e9e5f4; background: #fff; }
.docs-page .mode-card.live { background: linear-gradient(160deg, rgba(124,58,237,.07), #fff 60%); border-color: rgba(124,58,237,.3); }
.docs-page .mode-head { display: flex; gap: 12px; align-items: flex-start; margin-bottom: 12px; }
.docs-page .mode-icon { flex: none; width: 38px; height: 38px; display: grid; place-items: center; border-radius: 12px; background: rgba(124,58,237,.09); color: #7c3aed; }
.docs-page .mode-card.test .mode-icon { background: rgba(14,165,233,.08); color: #0284c7; }
.docs-page .mode-icon svg { width: 19px; height: 19px; }
.docs-page .mode-title { font-size: 14.5px; font-weight: 800; letter-spacing: .02em; color: #1c1730; }
.docs-page .mode-sub { font-size: 12px; color: #8d88a6; margin-top: 2px; }
.docs-page .mode-key { background: #14101f; border: 1px solid #2a2338; border-radius: 10px; padding: 10px 12px; margin-bottom: 10px; }
.docs-page .mode-key code { font-family: ui-monospace, Menlo, Consolas, monospace; font-size: 12px; color: #7dd3fc; }
.docs-page .mode-card p { font-size: 13px; line-height: 1.65; color: #55506e; }
.docs-page .mode-card p code { color: #6d28d9; font-weight: 650; }

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

/* CODEBOX — dark, gaya contoh */
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

/* FOOTER */
.docs-page .footer-links { display: flex; gap: 20px; justify-content: center; margin-top: 34px; font-size: 13.5px; }
.docs-page .footer-links a { color: #6f6a85; }
.docs-page .footer-links a:hover { color: #7c3aed; }

@media (max-width: 720px) {
  .docs-page .info-box, .docs-page .mode-grid { grid-template-columns: 1fr; }
  .docs-page .nav-links { display: none; }
  .docs-page .card-head, .docs-page .card-body { padding-left: 16px; padding-right: 16px; }
  .docs-page pre.cb-body { font-size: 11.5px; }
}
</style>
