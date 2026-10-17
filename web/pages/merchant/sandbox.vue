<template>
  <div class="page">
    <div class="head">
      <div class="head-text">
        <h1>Developer &amp; Sandbox</h1>
        <p class="sub">Uji integrasi tanpa transaksi nyata</p>
      </div>
      <div class="status-pill">
        <span class="status-dot"></span>
        Sandbox Aktif
      </div>
    </div>

    <!-- BASE URL SANDBOX -->
    <div class="card">
      <h2>
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/>
          <path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/>
        </svg>
        Base URL Sandbox
      </h2>

      <div class="url-row">
        <code class="url-value">{{ sandboxUrl }}</code>
        <button class="btn-copy" @click="copyText(sandboxUrl, 'url')" :class="{ copied: copiedKey === 'url' }">
          <svg v-if="copiedKey !== 'url'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <rect x="9" y="9" width="13" height="13" rx="2" ry="2"/>
            <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/>
          </svg>
          <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
            <polyline points="20 6 9 17 4 12"/>
          </svg>
          <span>{{ copiedKey === 'url' ? 'Copied!' : 'Copy' }}</span>
        </button>
      </div>

      <p class="hint">Endpoint sandbox sama persis dengan production, tapi pakai API key environment <code>sandbox</code>.</p>
    </div>

    <!-- TEST SCENARIOS -->
    <div class="card">
      <h2>
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M12 20h9M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/>
        </svg>
        Skenario Test
      </h2>

      <div class="scenario-list">
        <div class="scenario-row">
          <div class="scenario-icon paid">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
              <polyline points="20 6 9 17 4 12"/>
            </svg>
          </div>
          <div class="scenario-body">
            <div class="scenario-title">Pembayaran Sukses</div>
            <div class="scenario-desc">Scan QRIS di aplikasi e-wallet manapun → status berubah jadi <code>PAID</code></div>
          </div>
        </div>

        <div class="scenario-row">
          <div class="scenario-icon pending">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="12" cy="12" r="10"/>
              <polyline points="12 6 12 12 16 14"/>
            </svg>
          </div>
          <div class="scenario-body">
            <div class="scenario-title">Menunggu Pembayaran</div>
            <div class="scenario-desc">Buat transaksi baru tanpa scan → status <code>PENDING</code> sampai expire</div>
          </div>
        </div>

        <div class="scenario-row">
          <div class="scenario-icon expired">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <line x1="18" y1="6" x2="6" y2="18"/>
              <line x1="6" y1="6" x2="18" y2="18"/>
            </svg>
          </div>
          <div class="scenario-body">
            <div class="scenario-title">Kadaluwarsa</div>
            <div class="scenario-desc">Biarkan transaksi tanpa scan > 5 menit → status <code>EXPIRED</code></div>
          </div>
        </div>
      </div>

      <div class="info-box">
        <div class="info-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
          </svg>
        </div>
        <div class="info-text">
          <strong>Isolasi Sandbox</strong>
          <p>Database sandbox terpisah dari production. Tidak ada uang yang berpindah & tidak ada webhook yang dikirim ke callback URL produksi.</p>
        </div>
      </div>
    </div>

    <!-- QUICK ACTIONS -->
    <div class="card">
      <h2>
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <polyline points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/>
        </svg>
        Langkah Cepat
      </h2>

      <div class="quick-actions">
        <NuxtLink to="/merchant/api-key" class="qa-item">
          <div class="qa-icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 1 1-7.778 7.778 5.5 5.5 0 0 1 7.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4" stroke-linecap="round"/>
            </svg>
          </div>
          <div class="qa-info">
            <div class="qa-title">Buat API Key</div>
            <div class="qa-desc">Pilih environment <code>sandbox</code></div>
          </div>
          <div class="qa-arrow">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <polyline points="9 18 15 12 9 6"/>
            </svg>
          </div>
        </NuxtLink>

        <NuxtLink to="/merchant/docs" class="qa-item">
          <div class="qa-icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/>
              <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/>
            </svg>
          </div>
          <div class="qa-info">
            <div class="qa-title">Baca Dokumentasi</div>
            <div class="qa-desc">Contoh cURL, PHP, Node, Python</div>
          </div>
          <div class="qa-arrow">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <polyline points="9 18 15 12 9 6"/>
            </svg>
          </div>
        </NuxtLink>

        <NuxtLink to="/merchant/webhook" class="qa-item">
          <div class="qa-icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M18 16.98h-5.99c-1.1 0-1.95.94-2.48 1.9A4 4 0 0 1 2 17c.01-.7.2-1.4.57-2"/>
              <path d="m6 17 3.13-5.78c.53-.97.1-2.18-.5-3.1a4 4 0 1 1 6.89-4.06"/>
              <path d="m12 6 3.13 5.73C15.66 12.7 16.9 13 18 13a4 4 0 0 1 0 8"/>
            </svg>
          </div>
          <div class="qa-info">
            <div class="qa-title">Setup Webhook</div>
            <div class="qa-desc">Test kirim event ke URL kamu</div>
          </div>
          <div class="qa-arrow">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <polyline points="9 18 15 12 9 6"/>
            </svg>
          </div>
        </NuxtLink>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'dashboard' })

const config = useRuntimeConfig()
const { siteName } = useSiteSettings()
const copiedKey = ref<string | null>(null)

// Base URL dari env: NUXT_PUBLIC_PUBLIC_URL → NUXT_PUBLIC_API_BASE_URL → window origin
const sandboxUrl = computed(() => {
  const url = config.public.publicUrl || config.public.apiBaseUrl || ''
  if (url) return String(url).replace(/\/+$/, '')
  if (typeof window !== 'undefined') return window.location.origin
  return ''
})

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

useHead({ title: 'Developer & Sandbox — ' + (siteName.value || 'UnoPay') })
</script>

<style scoped>
* { box-sizing: border-box; }

.page {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  padding-bottom: 60px;
  color: var(--txt, #16121f);
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
}

.head {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 24px;
  gap: 12px;
  flex-wrap: wrap;
}
.head-text { min-width: 0; }
h1 { font-size: 22px; font-weight: 800; color: var(--txt, #16121f); letter-spacing: -0.02em; }
.sub { font-size: 13px; color: var(--dim, #6f6a80); margin-top: 5px; }

/* STATUS PILL */
.status-pill {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 7px 14px;
  background: rgba(16,185,129,0.08);
  border: 1px solid rgba(16,185,129,0.25);
  border-radius: 999px;
  font-size: 12px;
  font-weight: 750;
  color: #059669;
  white-space: nowrap;
  flex-shrink: 0;
}
.status-dot {
  width: 6px; height: 6px;
  border-radius: 50%;
  background: #10b981;
  box-shadow: 0 0 0 3px rgba(16,185,129,0.15);
  animation: pulse 2s infinite;
}
@keyframes pulse {
  0%, 100% { opacity: 1; transform: scale(1); }
  50% { opacity: 0.45; transform: scale(0.85); }
}

/* CARD */
.card {
  background: #ffffff;
  border: 1px solid var(--line, #eceaf4);
  border-radius: 16px;
  padding: 22px;
  margin-bottom: 14px;
  box-shadow: 0 1px 2px rgba(88,60,160,0.04), 0 4px 14px rgba(88,60,160,0.05);
}
.card h2 {
  display: flex; align-items: center; gap: 10px;
  font-size: 15px; font-weight: 750;
  margin: 0 0 18px; color: var(--txt, #16121f);
}
.card h2 svg { color: var(--vio, #7c3aed); flex-shrink: 0; width: 18px; height: 18px; }

/* URL ROW */
.url-row {
  display: flex;
  gap: 8px;
  align-items: stretch;
  margin-bottom: 12px;
}
.url-value {
  flex: 1;
  padding: 12px 14px;
  background: var(--bg-soft, #f9f8fc);
  border: 1px solid var(--line-2, #ddd9ee);
  border-radius: 11px;
  font-size: 12.5px;
  font-family: ui-monospace, 'SF Mono', monospace;
  color: var(--vio-deep, #5b21b6);
  word-break: break-all;
  min-width: 0;
  font-weight: 700;
  line-height: 1.5;
  display: flex;
  align-items: center;
}
.btn-copy {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 12px 16px;
  background: #ffffff;
  border: 1px solid var(--line, #eceaf4);
  border-radius: 11px;
  font-size: 12px;
  font-weight: 700;
  color: var(--dim, #6f6a80);
  cursor: pointer;
  font-family: inherit;
  white-space: nowrap;
  flex-shrink: 0;
  transition: all 0.18s;
}
.btn-copy svg { width: 13px; height: 13px; }
.btn-copy:hover { border-color: var(--vio-2, #a78bfa); color: var(--vio, #7c3aed); }
.btn-copy.copied {
  background: var(--grad, linear-gradient(135deg, #7c3aed, #d946ef));
  border-color: transparent;
  color: #ffffff;
}
.hint {
  font-size: 12px;
  color: var(--dim, #6f6a80);
  line-height: 1.6;
  margin: 0;
}
.hint code {
  background: rgba(124,58,237,0.07);
  border: 1px solid rgba(124,58,237,0.15);
  padding: 2px 6px;
  border-radius: 5px;
  font-size: 11.5px;
  font-family: ui-monospace, monospace;
  color: var(--vio-deep, #5b21b6);
  font-weight: 700;
}

/* SCENARIO LIST */
.scenario-list { display: flex; flex-direction: column; margin-bottom: 16px; }
.scenario-row {
  display: flex;
  gap: 14px;
  padding: 16px 0;
  border-bottom: 1px solid var(--line, #eceaf4);
  align-items: flex-start;
}
.scenario-row:last-child { border-bottom: none; }
.scenario-icon {
  width: 36px; height: 36px;
  border-radius: 10px;
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
}
.scenario-icon svg { width: 16px; height: 16px; }
.scenario-icon.paid {
  background: rgba(16,185,129,0.09);
  border: 1px solid rgba(16,185,129,0.25);
  color: #059669;
}
.scenario-icon.pending {
  background: rgba(245,158,11,0.09);
  border: 1px solid rgba(245,158,11,0.25);
  color: #d97706;
}
.scenario-icon.expired {
  background: var(--bg-soft, #f9f8fc);
  border: 1px solid var(--line, #eceaf4);
  color: var(--dim, #6f6a80);
}
.scenario-body { flex: 1; min-width: 0; }
.scenario-title {
  font-size: 13.5px;
  font-weight: 750;
  color: var(--txt, #16121f);
  margin-bottom: 4px;
}
.scenario-desc {
  font-size: 12.5px;
  color: var(--dim, #6f6a80);
  line-height: 1.6;
}
.scenario-desc code {
  background: rgba(124,58,237,0.07);
  border: 1px solid rgba(124,58,237,0.15);
  padding: 1px 6px;
  border-radius: 4px;
  font-size: 11.5px;
  font-family: ui-monospace, monospace;
  color: var(--vio-deep, #5b21b6);
  font-weight: 700;
}

/* INFO BOX */
.info-box {
  display: flex;
  gap: 12px;
  padding: 14px 16px;
  background: rgba(124,58,237,0.04);
  border: 1px solid rgba(124,58,237,0.14);
  border-radius: 12px;
}
.info-icon {
  width: 28px; height: 28px;
  border-radius: 9px;
  background: rgba(124,58,237,0.08);
  border: 1px solid rgba(124,58,237,0.18);
  color: var(--vio, #7c3aed);
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
}
.info-icon svg { width: 14px; height: 14px; }
.info-text { flex: 1; min-width: 0; }
.info-text strong {
  display: block;
  font-size: 12.5px;
  font-weight: 750;
  color: var(--txt, #16121f);
  margin-bottom: 3px;
}
.info-text p {
  font-size: 12px;
  color: var(--dim, #6f6a80);
  line-height: 1.6;
  margin: 0;
}

/* QUICK ACTIONS */
.quick-actions { display: flex; flex-direction: column; gap: 8px; }
.qa-item {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 14px 16px;
  background: var(--bg-soft, #f9f8fc);
  border: 1px solid var(--line, #eceaf4);
  border-radius: 12px;
  text-decoration: none;
  transition: all 0.2s;
}
.qa-item:hover {
  background: #ffffff;
  border-color: rgba(124,58,237,0.3);
  transform: translateX(2px);
}
.qa-icon {
  width: 40px; height: 40px;
  border-radius: 11px;
  background: rgba(124,58,237,0.07);
  border: 1px solid rgba(124,58,237,0.15);
  color: var(--vio, #7c3aed);
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
}
.qa-icon svg { width: 18px; height: 18px; }
.qa-info { flex: 1; min-width: 0; }
.qa-title { font-size: 13.5px; font-weight: 750; color: var(--txt, #16121f); margin-bottom: 2px; }
.qa-desc { font-size: 12px; color: var(--dim, #6f6a80); }
.qa-desc code {
  background: rgba(124,58,237,0.07);
  border: 1px solid rgba(124,58,237,0.15);
  padding: 1px 5px;
  border-radius: 4px;
  font-size: 11px;
  font-family: ui-monospace, monospace;
  color: var(--vio-deep, #5b21b6);
}
.qa-arrow { color: var(--line-2, #ddd9ee); transition: color 0.15s; flex-shrink: 0; }
.qa-arrow svg { width: 16px; height: 16px; }
.qa-item:hover .qa-arrow { color: var(--vio, #7c3aed); }

/* MOBILE */
@media (max-width: 640px) {
  .page { padding-bottom: 40px; }
  h1 { font-size: 20px; }
  .card { padding: 18px; border-radius: 14px; }
  .url-row { flex-direction: column; }
  .btn-copy { justify-content: center; }
  .scenario-icon { width: 32px; height: 32px; }
  .qa-icon { width: 36px; height: 36px; }
}
</style>