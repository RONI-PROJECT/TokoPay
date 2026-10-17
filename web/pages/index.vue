<!-- pages/index.vue (landing) -->
<template>
  <div class="landing">
    <!-- NAV -->
    <header class="nav" :class="{ 'nav-on': isScrolled }">
      <div class="nav-in">
        <NuxtLink to="/" class="brand"><SiteLogo /></NuxtLink>
        <nav class="links">
          <a href="#api">API</a>
          <a href="#fitur">Fitur</a>
          <a href="#alur">Alur</a>
          <NuxtLink to="/docs">Docs</NuxtLink>
        </nav>
        <div class="cta-nav">
          <NuxtLink to="/login" class="btn-soft">Masuk</NuxtLink>
          <NuxtLink to="/register" class="btn-grad">Daftar</NuxtLink>
        </div>
      </div>
    </header>

    <!-- HERO (langsung turun ke API) -->
    <section class="hero">
      <div class="hero-in">
        <div class="chip"><i class="dot"></i> QRIS aktif · deteksi otomatis</div>
        <h1 class="h1">Terima pembayaran <span class="mark">QRIS</span> tanpa ribet.</h1>
        <p class="sub">{{ heroLead }}</p>
        <div class="hero-cta">
          <NuxtLink to="/register" class="btn-grad btn-xl">Buat akun sekarang →</NuxtLink>
          <a href="#api" class="btn-ghost btn-xl">Lihat contoh API</a>
        </div>
      </div>
    </section>

    <!-- API — PALING ATAS, LANGSUNG -->
    <section id="api" class="api">
      <div class="wrap">
        <div class="api-head" v-reveal>
          <div>
            <span class="tag">API</span>
            <h2>Integrasi <em>5 menit</em> beres</h2>
          </div>
          <NuxtLink to="/docs" class="btn-ghost">Baca dokumentasi →</NuxtLink>
        </div>

        <div class="api-shell" v-reveal>
          <div class="api-tabs">
            <button
              v-for="t in Object.keys(snippets)" :key="t"
              class="api-tab" :class="{ active: tab === t }"
              @click="tab = t"
            >{{ t }}</button>
            <button class="api-copy" @click="copyCode">{{ copied ? '✓ Tersalin' : 'Copy' }}</button>
          </div>
          <pre class="api-code"><code>{{ snippets[tab] }}</code></pre>
        </div>

        <div class="api-grid">
          <div class="api-item" v-reveal>
            <span class="method post">POST</span>
            <code>/api/v1/qris/create</code>
            <p>Buat QRIS dinamis dengan nominal bebas.</p>
          </div>
          <div class="api-item" v-reveal>
            <span class="method get">GET</span>
            <code>/api/v1/qris/:reference</code>
            <p>Cek status pembayaran real-time.</p>
          </div>
          <div class="api-item" v-reveal>
            <span class="method post">POST</span>
            <code>callback_url kamu</code>
            <p>Callback otomatis saat lunas / kadaluarsa.</p>
          </div>
        </div>
      </div>
    </section>

    <!-- FITUR -->
    <section id="fitur" class="sec sec-alt">
      <div class="wrap">
        <div class="head" v-reveal>
          <span class="tag">FITUR</span>
          <h2>Bangun sistem bayar <em>tanpa drama</em></h2>
          <p>Satu API, semua kebutuhan payment merchant Indonesia.</p>
        </div>

        <div class="bento">
          <article class="cell c-wide" v-reveal>
            <div class="ic">◈</div>
            <h3>QRIS Dinamis</h3>
            <p>Nominal bebas, kode unik per transaksi, terdeteksi otomatis lewat polling GoBiz. Tidak ada saldo mengambang.</p>
          </article>
          <article class="cell" v-reveal>
            <div class="ic">⚡</div>
            <h3>Callback Otomatis</h3>
            <p>Notifikasi langsung ke server kamu saat lunas — auto-retry sampai 12x kalau gagal.</p>
          </article>
          <article class="cell" v-reveal>
            <div class="ic">▤</div>
            <h3>Dashboard Live</h3>
            <p>Transaksi, grafik omzet, dan saldo — update real-time.</p>
          </article>
          <article class="cell" v-reveal>
            <div class="ic">🔑</div>
            <h3>Multi API Key</h3>
            <p>Isolasi per project. Rotate key tanpa downtime.</p>
          </article>
          <article class="cell c-wide" v-reveal>
            <div class="ic">↥</div>
            <h3>Penarikan Dana</h3>
            <p>Ajukan withdraw kapan saja. Biaya jelas di depan, status jelas di dashboard.</p>
          </article>
        </div>
      </div>
    </section>

    <!-- ALUR -->
    <section id="alur" class="sec">
      <div class="wrap">
        <div class="head" v-reveal>
          <span class="tag">ALUR</span>
          <h2>Empat langkah, langsung jalan</h2>
        </div>
        <div class="flow">
          <div class="fstep" v-reveal v-for="(st, i) in steps" :key="i">
            <span class="fnum">{{ st.n }}</span>
            <h3>{{ st.t }}</h3>
            <p>{{ st.d }}</p>
          </div>
        </div>
      </div>
    </section>

    <!-- CTA -->
    <section class="sec sec-last">
      <div class="wrap">
        <div class="cta-card" v-reveal>
          <div class="cta-glow" aria-hidden="true"></div>
          <h2>Mulai terima QRIS <em>hari ini</em></h2>
          <p>Gratis, tanpa biaya bulanan. Cukup daftar dan ambil API key.</p>
          <NuxtLink to="/register" class="btn-white-xl">Daftar Sekarang — Gratis</NuxtLink>
          <span class="cta-foot">± 30 detik sampai dashboard aktif</span>
        </div>
      </div>
    </section>

    <SiteCopyright />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount } from 'vue'

const config = useRuntimeConfig()

const apiBase = computed(() => {
  const url = config.public.publicUrl || config.public.apiBaseUrl || ''
  if (url) return String(url).replace(/\/+$/, '')
  if (typeof window !== 'undefined') return window.location.origin
  return ''
})

const { heroLead, load: loadSettings } = useSiteSettings()

const isScrolled = ref(false)
let scrollHandler: any = null

const tab = ref('cURL')
const copied = ref(false)

const snippets = computed<Record<string, string>>(() => ({
  cURL: `curl -X POST ${apiBase.value}/api/v1/qris/create \\
  -H "Authorization: Bearer API_KEY_KAMU" \\
  -H "Content-Type: application/json" \\
  -d '{
    "amount": 25000,
    "reference": "TPV-10001",
    "callback_url": "https://tokoku.id/pay/notify",
    "expires_minutes": 15
  }'`,

  Node: `const res = await fetch(
  "${apiBase.value}/api/v1/qris/create",
  {
    method: "POST",
    headers: {
      "Authorization": "Bearer API_KEY_KAMU",
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      amount: 25000,
      reference: "TPV-10001"
    })
  }
);

const { data } = await res.json();
console.log(data.qr_image);`,

  PHP: `<?php
 $ch = curl_init(
  "${apiBase.value}/api/v1/qris/create"
);

curl_setopt_array($ch, [
  CURLOPT_POST => true,
  CURLOPT_RETURNTRANSFER => true,
  CURLOPT_HTTPHEADER => [
    "Authorization: Bearer API_KEY_KAMU",
    "Content-Type: application/json"
  ],
  CURLOPT_POSTFIELDS => json_encode([
    "amount" => 25000,
    "reference" => "TPV-10001"
  ])
]);

 $data = json_decode(curl_exec($ch), true);
echo $data["data"]["qr_image"];`,

  Python: `import requests

res = requests.post(
  "${apiBase.value}/api/v1/qris/create",
  headers={
    "Authorization": "Bearer API_KEY_KAMU"
  },
  json={
    "amount": 25000,
    "reference": "TPV-10001"
  }
)

print(res.json()["data"]["qr_image"])`,
}))

const steps = [
  { n: '01', t: 'Daftar merchant', d: 'Akun gratis, aktif dalam 30 detik.' },
  { n: '02', t: 'Ambil API key', d: 'Generate langsung dari dashboard.' },
  { n: '03', t: 'Integrasi', d: 'Satu endpoint POST, contoh kode tersedia.' },
  { n: '04', t: 'Terima & tarik', d: 'Dana mengalir sesuai settlement.' },
]

async function copyCode() {
  try {
    await navigator.clipboard.writeText(snippets[tab.value])
    copied.value = true
    setTimeout(() => (copied.value = false), 1500)
  } catch {}
}

const vReveal = {
  mounted(el: HTMLElement) {
    el.classList.add('rv')
    const obs = new IntersectionObserver(es => {
      es.forEach(e => {
        if (e.isIntersecting) { el.classList.add('rv-in'); obs.unobserve(el) }
      })
    }, { threshold: 0.1, rootMargin: '0px 0px -40px 0px' })
    obs.observe(el)
  },
}

onMounted(() => {
  loadSettings()
  scrollHandler = () => { isScrolled.value = window.scrollY > 20 }
  window.addEventListener('scroll', scrollHandler, { passive: true })
  scrollHandler()
})
onBeforeUnmount(() => {
  if (scrollHandler) window.removeEventListener('scroll', scrollHandler)
})
</script>

<style scoped>
* { box-sizing: border-box; margin: 0; padding: 0; }

.landing {
  position: relative;
  min-height: 100vh;
  color: var(--txt);
  font-family: 'Inter', system-ui, sans-serif;
  -webkit-font-smoothing: antialiased;
  overflow-x: hidden;
}
.wrap { max-width: 1120px; margin: 0 auto; padding: 0 24px; }

/* ===== NAV ===== */
.nav { position: sticky; top: 0; z-index: 100; transition: all .3s; }
.nav-on {
  background: rgba(255,255,255,0.85);
  backdrop-filter: blur(16px) saturate(150%);
  -webkit-backdrop-filter: blur(16px) saturate(150%);
  border-bottom: 1px solid var(--line);
}
.nav-in {
  max-width: 1120px; margin: 0 auto; padding: 0 20px;
  height: 64px; display: flex; align-items: center; gap: 16px;
}
.brand { display: flex; align-items: center; flex-shrink: 0; }
.brand :deep(img) { height: 30px; width: auto; display: block; }
.links { display: flex; gap: 26px; margin: 0 auto; }
.links a { color: var(--dim); font-size: 13.5px; font-weight: 550; text-decoration: none; transition: color .15s; }
.links a:hover { color: var(--vio); }
.cta-nav { display: flex; gap: 8px; align-items: center; flex-shrink: 0; }

.btn-soft {
  padding: 8px 14px; border-radius: 10px;
  color: var(--txt); font-size: 13px; font-weight: 600;
  text-decoration: none; transition: all .2s;
  border: 1px solid var(--line); background: #fff; white-space: nowrap;
}
.btn-soft:hover { border-color: var(--line-2); box-shadow: 0 4px 14px rgba(88,60,160,0.06); }
.btn-grad {
  padding: 9px 18px; border-radius: 10px;
  background: var(--grad); color: #fff;
  font-size: 13px; font-weight: 700; text-decoration: none;
  transition: all .25s; white-space: nowrap;
  box-shadow: 0 6px 20px -6px rgba(124,58,237,0.5);
}
.btn-grad:hover { transform: translateY(-1px); box-shadow: 0 12px 30px -8px rgba(124,58,237,0.6); }
.btn-ghost {
  padding: 9px 16px; border-radius: 10px;
  color: var(--vio); font-size: 13px; font-weight: 650;
  text-decoration: none; border: 1px solid var(--line-2);
  background: #fff; transition: all .2s; white-space: nowrap;
}
.btn-ghost:hover { border-color: #a78bfa; background: var(--bg-soft); }
.btn-xl { padding: 14px 26px; font-size: 14.5px; border-radius: 12px; }

/* ===== HERO (pendek, langsung ke API) ===== */
.hero { position: relative; padding: 64px 0 40px; text-align: center; }
.hero::before {
  content: ''; position: absolute; inset: 0; pointer-events: none;
  background: radial-gradient(700px 320px at 50% -5%, rgba(124,58,237,0.09), transparent 65%);
}
.hero-in { position: relative; max-width: 760px; margin: 0 auto; padding: 0 24px; }
.chip {
  display: inline-flex; align-items: center; gap: 8px;
  padding: 7px 14px; border-radius: 999px;
  background: rgba(124,58,237,0.06);
  border: 1px solid rgba(124,58,237,0.18);
  color: var(--vio); font-size: 12px; font-weight: 600;
  margin-bottom: 22px;
}
.dot { width: 7px; height: 7px; border-radius: 50%; background: var(--vio); box-shadow: 0 0 0 3px rgba(124,58,237,0.15); animation: pulse 2s infinite; }
@keyframes pulse { 0%,100% { opacity: 1; } 50% { opacity: .5; } }

.h1 {
  font-size: clamp(34px, 5.6vw, 58px);
  font-weight: 800; letter-spacing: -0.045em; line-height: 1.06;
  margin-bottom: 16px;
  animation: rise .7s cubic-bezier(.22,1,.36,1) both;
}
.mark {
  background: var(--grad);
  -webkit-background-clip: text; background-clip: text;
  -webkit-text-fill-color: transparent;
}
.sub {
  font-size: 16px; color: var(--dim); line-height: 1.7; max-width: 500px;
  margin: 0 auto 26px; animation: rise .7s .08s cubic-bezier(.22,1,.36,1) both;
}
.hero-cta {
  display: flex; gap: 10px; justify-content: center; flex-wrap: wrap;
  animation: rise .7s .16s cubic-bezier(.22,1,.36,1) both;
}
@keyframes rise { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: none; } }

/* ===== API ===== */
.api { padding: 28px 0 72px; }
.api-head {
  display: flex; align-items: flex-end; justify-content: space-between;
  gap: 16px; margin-bottom: 20px; flex-wrap: wrap;
}
.api-head .tag { margin-bottom: 12px; }
.api-head h2 { font-size: clamp(24px, 3.6vw, 34px); font-weight: 800; letter-spacing: -0.035em; }
.api-head h2 em { font-style: normal; background: var(--grad); -webkit-background-clip: text; background-clip: text; -webkit-text-fill-color: transparent; }

.api-shell {
  background: #17131f;
  border: 1px solid #2a2338;
  border-radius: 18px;
  overflow: hidden;
  box-shadow: 0 24px 70px -24px rgba(91,33,182,0.45);
}
.api-tabs {
  display: flex; align-items: center; gap: 4px;
  padding: 10px 12px;
  background: rgba(255,255,255,0.03);
  border-bottom: 1px solid #2a2338;
  overflow-x: auto;
}
.api-tab {
  padding: 7px 14px; border-radius: 8px;
  background: transparent; border: 0;
  color: #8d84a3; font-size: 12.5px; font-weight: 650;
  cursor: pointer; transition: all .2s;
  font-family: inherit; white-space: nowrap;
}
.api-tab:hover { color: #d9d2ea; }
.api-tab.active {
  background: rgba(124,58,237,0.22);
  color: #cdb6ff;
  box-shadow: inset 0 0 0 1px rgba(124,58,237,0.4);
}
.api-copy {
  margin-left: auto;
  padding: 7px 14px; border-radius: 8px;
  background: rgba(255,255,255,0.05); border: 1px solid #2f2840;
  color: #b6aecd; font-size: 12px; font-weight: 600;
  cursor: pointer; transition: all .2s;
  font-family: inherit; white-space: nowrap;
}
.api-copy:hover { background: rgba(124,58,237,0.2); color: #e4dbf5; border-color: rgba(124,58,237,0.4); }
.api-code {
  margin: 0; padding: 22px 24px;
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
  font-family: ui-monospace, 'SF Mono', Menlo, monospace;
  font-size: 12px; line-height: 1.75;
  color: #d4cce6;
  white-space: pre;
  min-height: 220px;
}
.api-code code { font-family: inherit; }

.api-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; margin-top: 14px; }
.api-item {
  background: #fff; border: 1px solid var(--line);
  border-radius: 14px; padding: 20px;
  box-shadow: 0 1px 2px rgba(88,60,160,0.05), 0 4px 14px rgba(88,60,160,0.06);
  transition: all .25s;
}
.api-item:hover { transform: translateY(-3px); box-shadow: 0 4px 8px rgba(88,60,160,0.06), 0 20px 50px rgba(88,60,160,0.12); }
.method {
  display: inline-block; padding: 3px 9px; border-radius: 6px;
  font-family: ui-monospace, monospace; font-size: 10.5px; font-weight: 800;
  letter-spacing: .05em; margin-bottom: 12px;
}
.method.post { background: rgba(124,58,237,0.1); color: var(--vio); border: 1px solid rgba(124,58,237,0.2); }
.method.get { background: rgba(13,148,136,0.1); color: #0d9488; border: 1px solid rgba(13,148,136,0.2); }
.api-item code {
  display: block;
  font-family: ui-monospace, monospace; font-size: 13px; font-weight: 700;
  color: var(--txt); margin-bottom: 8px;
  word-break: break-all;
}
.api-item p { font-size: 12.5px; color: var(--dim); line-height: 1.6; }

/* ===== SECTIONS ===== */
.sec { padding: 76px 0; }
.sec-alt {
  background: var(--bg-soft);
  border-top: 1px solid var(--line);
  border-bottom: 1px solid var(--line);
}
.sec-last { padding-top: 20px; }
.head { text-align: center; margin-bottom: 46px; }
.tag {
  display: inline-block; padding: 5px 12px; border-radius: 999px;
  background: #fff; border: 1px solid var(--line-2);
  color: var(--vio); font-size: 10px; font-weight: 800; letter-spacing: .2em;
  margin-bottom: 14px; box-shadow: 0 1px 2px rgba(88,60,160,0.05), 0 4px 14px rgba(88,60,160,0.06);
}
.head h2 { font-size: clamp(26px, 4vw, 38px); font-weight: 800; letter-spacing: -0.035em; margin-bottom: 10px; }
.head h2 em { font-style: normal; background: var(--grad); -webkit-background-clip: text; background-clip: text; -webkit-text-fill-color: transparent; }
.head p { color: var(--dim); font-size: 15px; }

/* ===== BENTO ===== */
.bento { display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; }
.cell {
  position: relative; overflow: hidden;
  background: #fff;
  border: 1px solid var(--line);
  border-radius: 18px; padding: 28px;
  transition: all .25s;
  box-shadow: 0 1px 2px rgba(88,60,160,0.05), 0 4px 14px rgba(88,60,160,0.06);
}
.cell:hover { transform: translateY(-3px); box-shadow: 0 4px 8px rgba(88,60,160,0.06), 0 20px 50px rgba(88,60,160,0.12); border-color: var(--line-2); }
.c-wide { grid-column: span 2; }
.ic {
  width: 42px; height: 42px; border-radius: 12px;
  display: flex; align-items: center; justify-content: center;
  background: rgba(124,58,237,0.07); border: 1px solid rgba(124,58,237,0.15);
  color: var(--vio);
  font-size: 17px; margin-bottom: 18px;
}
.cell h3 { font-size: 16.5px; font-weight: 750; margin-bottom: 8px; letter-spacing: -0.015em; }
.cell p { font-size: 13.5px; color: var(--dim); line-height: 1.7; max-width: 440px; }

/* ===== FLOW ===== */
.flow { display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px; }
.fstep {
  background: #fff; border: 1px solid var(--line);
  border-radius: 16px; padding: 24px;
  box-shadow: 0 1px 2px rgba(88,60,160,0.05), 0 4px 14px rgba(88,60,160,0.06);
  transition: all .25s;
  position: relative; overflow: hidden;
}
.fstep::after {
  content: ''; position: absolute; bottom: 0; left: 0; right: 0; height: 2px;
  background: var(--grad);
  transform: scaleX(0); transform-origin: left;
  transition: transform .35s;
}
.fstep:hover::after { transform: scaleX(1); }
.fstep:hover { transform: translateY(-3px); }
.fnum {
  font-family: ui-monospace, monospace;
  font-size: 12px; font-weight: 800; color: var(--vio);
  display: inline-flex; padding: 4px 10px; border-radius: 8px;
  background: rgba(124,58,237,0.07);
  border: 1px solid rgba(124,58,237,0.14);
  margin-bottom: 14px;
}
.fstep h3 { font-size: 15px; font-weight: 700; margin-bottom: 6px; }
.fstep p { font-size: 12.5px; color: var(--dim); line-height: 1.6; }

/* ===== CTA ===== */
.cta-card {
  position: relative; overflow: hidden;
  text-align: center;
  background:
    radial-gradient(600px 300px at 50% -10%, rgba(168,85,247,0.35), transparent 65%),
    linear-gradient(160deg, #1c1428 0%, #17111f 100%);
  color: #fff;
  border-radius: 26px; padding: 64px 32px;
  box-shadow: 0 30px 80px -24px rgba(91,33,182,0.55);
}
.cta-glow {
  position: absolute; inset: -40%;
  background: conic-gradient(from 0deg, transparent 72%, rgba(168,85,247,0.16), transparent 92%);
  animation: spin 10s linear infinite; pointer-events: none;
}
@keyframes spin { to { transform: rotate(360deg); } }
.cta-card h2 { position: relative; font-size: clamp(26px, 4vw, 40px); font-weight: 800; letter-spacing: -0.035em; margin-bottom: 12px; }
.cta-card h2 em { font-style: normal; background: linear-gradient(135deg, #c4b5fd, #e9d5ff); -webkit-background-clip: text; background-clip: text; -webkit-text-fill-color: transparent; }
.cta-card p { position: relative; color: rgba(255,255,255,0.6); font-size: 15px; margin-bottom: 30px; }
.btn-white-xl {
  position: relative;
  display: inline-block; padding: 15px 32px;
  background: #fff; color: var(--vio-deep);
  border-radius: 13px; font-size: 14.5px; font-weight: 800;
  text-decoration: none; transition: all .25s;
  box-shadow: 0 16px 44px -12px rgba(255,255,255,0.35);
}
.btn-white-xl:hover { transform: translateY(-3px); box-shadow: 0 24px 56px -12px rgba(196,181,253,0.5); }
.cta-foot { position: relative; display: block; margin-top: 16px; font-size: 12px; color: rgba(255,255,255,0.45); }

/* ===== REVEAL ===== */
.rv { opacity: 0; transform: translateY(24px); transition: opacity .7s cubic-bezier(.22,1,.36,1), transform .7s cubic-bezier(.22,1,.36,1); }
.rv-in { opacity: 1; transform: none; }

/* ===== RESPONSIVE ===== */
@media (max-width: 940px) {
  .links { display: none; }
  .bento { grid-template-columns: 1fr 1fr; }
  .c-wide { grid-column: span 2; }
  .flow { grid-template-columns: 1fr 1fr; }
  .api-grid { grid-template-columns: 1fr; }
}
@media (max-width: 640px) {
  .nav-in { height: 58px; padding: 0 14px; gap: 10px; }
  .brand { margin-right: auto; }
  .cta-nav { gap: 6px; }
  .btn-soft { padding: 7px 11px; font-size: 12.5px; }
  .btn-grad { padding: 8px 13px; font-size: 12.5px; }
  .hero { padding: 40px 0 32px; }
  .sec { padding: 56px 0; }
  .api { padding: 20px 0 56px; }
  .bento { grid-template-columns: 1fr; }
  .c-wide { grid-column: span 1; }
  .flow { grid-template-columns: 1fr; }
  .cta-card { padding: 48px 22px; }
  .btn-xl { padding: 13px 20px; font-size: 13.5px; width: 100%; }
  .hero-cta { flex-direction: column; align-items: stretch; }
  .api-code { font-size: 11px; padding: 18px 16px; }
  .api-head { flex-direction: column; align-items: flex-start; }
}
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after { animation: none !important; transition: none !important; }
  .rv { opacity: 1; transform: none; }
}
</style>
