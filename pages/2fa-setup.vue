<template>
  <div class="auth-page">
    <div class="snow-layer" aria-hidden="true">
      <span v-for="f in snowflakes" :key="f.id" class="flake" :style="f.style" />
    </div>

    <div class="auth-left">
      <div class="auth-box">
        <NuxtLink to="/" class="brand">
          <img src="https://cdn.phototourl.com/member/2026-09-30-f9ea62fe-f172-493b-9a10-e38b7dacf376.png" alt="Ronipaygate" />
        </NuxtLink>

        <template v-if="step === 'setup'">
          <div class="head">
            <div class="badge">🔐 Two-Factor Auth</div>
            <h1>Setup 2FA</h1>
            <p>Scan QR di bawah pakai Google Authenticator, Authy, atau aplikasi TOTP lain</p>
          </div>

          <div v-if="loadingQR" class="loading-box">
            <div class="spinner"></div>
            <p>Generate QR...</p>
          </div>

          <template v-else-if="qrData">
            <div class="qr-box">
              <div class="qr-glow"></div>
              <img :src="qrData.qrDataUrl" alt="QR Code" class="qr-img" />
            </div>

            <div class="manual-box">
              <div class="manual-label">Atau input manual di aplikasi</div>
              <div class="manual-secret">
                <code>{{ qrData.manualEntry }}</code>
                <button class="copy-btn" @click="copySecret">Copy</button>
              </div>
            </div>

            <form @submit.prevent="onVerifySetup" class="form">
              <div class="form-group">
                <label>Masukkan kode 6 digit dari aplikasi</label>
                <input v-model="totpCode" type="text" inputmode="numeric" pattern="[0-9]*" maxlength="6" placeholder="000000" class="totp-input" />
              </div>

              <div v-if="error" class="alert alert-error">{{ error }}</div>

              <button type="submit" class="btn-submit" :disabled="loading || totpCode.length !== 6">
                <span v-if="!loading">Aktifkan 2FA</span>
                <span v-else class="btn-loading"><span class="btn-spinner"></span> Memverifikasi...</span>
              </button>
            </form>
          </template>
        </template>

        <template v-else-if="step === 'backup'">
          <div class="head">
            <div class="badge success">✅ Berhasil</div>
            <h1>Simpan Backup Code</h1>
            <p>Kalau kamu kehilangan akses ke authenticator, pakai kode di bawah buat login</p>
          </div>

          <div class="backup-box">
            <div class="backup-codes">
              <code v-for="c in backupCodes" :key="c">{{ c }}</code>
            </div>
            <button class="copy-btn-full" @click="copyBackupCodes">📋 Copy Semua</button>
          </div>

          <div class="alert alert-warn">⚠️ Simpan kode ini di tempat aman. Nggak akan ditampilkan lagi.</div>

          <button class="btn-submit" @click="goToDashboard">Saya sudah simpan, lanjut ke dashboard →</button>
        </template>
      </div>
    </div>

    <div class="auth-right">
      <div class="branding">
        <div class="brand-logo-big">
          <img src="https://cdn.phototourl.com/member/2026-09-30-f9ea62fe-f172-493b-9a10-e38b7dacf376.png" alt="Ronipaygate" />
        </div>
        <h2>Keamanan berlapis<br>buat akun Anda</h2>
        <p class="branding-sub">2FA TOTP melindungi akun dari akses tidak sah. Setup sekali, aman selamanya.</p>

        <div class="feature-list">
          <div class="feature-item">
            <div class="feature-icon">1</div>
            <div><div class="feature-title">Scan QR Code</div><div class="feature-desc">Pakai Google Authenticator / Authy</div></div>
          </div>
          <div class="feature-item">
            <div class="feature-icon">2</div>
            <div><div class="feature-title">Verifikasi Kode</div><div class="feature-desc">Masukkan 6 digit dari aplikasi</div></div>
          </div>
          <div class="feature-item">
            <div class="feature-icon">3</div>
            <div><div class="feature-title">Simpan Backup Code</div><div class="feature-desc">8 kode cadangan buat recovery</div></div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: false })

const step = ref<'setup' | 'backup'>('setup')
const totpCode = ref('')
const qrData = ref<any>(null)
const backupCodes = ref<string[]>([])
const loading = ref(false)
const loadingQR = ref(true)
const error = ref('')
const snowflakes = ref<any[]>([])

onMounted(async () => {
  snowflakes.value = Array.from({ length: 45 }, (_, i) => {
    const size = 4 + Math.random() * 10
    return {
      id: i,
      style: {
        left: Math.random() * 100 + '%',
        width: size + 'px',
        height: size + 'px',
        opacity: (0.35 + Math.random() * 0.55).toFixed(2),
        animationDuration: (7 + Math.random() * 12) + 's',
        animationDelay: (-Math.random() * 15) + 's',
      } as Record<string, string>,
    }
  })

  try {
    const me: any = await $fetch('/auth/me', { credentials: 'include' })
    if (!me.success) { navigateTo('/login'); return }
    if (me.data.totpEnabled) { navigateTo('/dashboard'); return }

    const r: any = await $fetch('/auth/2fa/setup', { method: 'POST', credentials: 'include' })
    qrData.value = r.data
  } catch (e: any) {
    error.value = e?.data?.error || e.message
    if (e?.statusCode === 401) navigateTo('/login')
  } finally {
    loadingQR.value = false
  }
})

async function onVerifySetup() {
  error.value = ''
  loading.value = true
  try {
    const r: any = await $fetch('/auth/2fa/verify-setup', {
      method: 'POST',
      body: { token: totpCode.value },
      credentials: 'include',
    })
    backupCodes.value = r.data.backupCodes
    step.value = 'backup'
  } catch (e: any) {
    error.value = e?.data?.error || e.message
    totpCode.value = ''
  } finally {
    loading.value = false
  }
}

function copySecret() { navigator.clipboard.writeText(qrData.value.secret); alert('Secret di-copy!') }
function copyBackupCodes() { navigator.clipboard.writeText(backupCodes.value.join('\n')); alert('Backup codes di-copy!') }
function goToDashboard() { navigateTo('/dashboard') }
</script>

<style scoped>
* { box-sizing: border-box; }
.auth-page { min-height: 100vh; display: grid; grid-template-columns: 1fr 1fr; position: relative; overflow: hidden; font-family: 'Inter', -apple-system, sans-serif; }

.snow-layer { position: fixed; inset: 0; pointer-events: none; z-index: 999; overflow: hidden; }
.flake {
  position: absolute; top: -20px; display: block; border-radius: 50%;
  background: radial-gradient(circle, #fff 0%, rgba(255,255,255,0.7) 50%, rgba(255,255,255,0) 75%);
  animation: fall linear infinite; will-change: transform;
  filter: drop-shadow(0 0 3px rgba(255,255,255,0.6));
}
@keyframes fall {
  0%   { transform: translate3d(0, -10vh, 0) rotate(0deg); }
  50%  { transform: translate3d(20px, 50vh, 0) rotate(180deg); }
  100% { transform: translate3d(-10px, 110vh, 0) rotate(360deg); }
}

.auth-left {
  display: flex; align-items: center; justify-content: center; padding: 40px;
  background:
    radial-gradient(1200px 600px at 10% 0%, rgba(99,102,241,0.10), transparent 60%),
    radial-gradient(900px 500px at 100% 100%, rgba(16,185,129,0.10), transparent 60%),
    linear-gradient(180deg, #ffffff 0%, #fbfbfd 100%);
  overflow-y: auto; position: relative; z-index: 1;
}
.auth-box { width: 100%; max-width: 420px; animation: fadeUp 0.6s cubic-bezier(0.22,1,0.36,1) both; }
@keyframes fadeUp { from { opacity: 0; transform: translateY(16px); } to { opacity: 1; transform: translateY(0); } }

.brand { display: flex; margin-bottom: 28px; }
.brand img { height: 40px; width: auto; }

.head { margin-bottom: 24px; }
.badge {
  display: inline-block; font-size: 11px; font-weight: 700; letter-spacing: 0.06em; text-transform: uppercase;
  color: #4f46e5; background: rgba(99,102,241,0.10); border: 1px solid rgba(99,102,241,0.20);
  padding: 5px 10px; border-radius: 999px; margin-bottom: 12px;
}
.badge.success { color: #059669; background: rgba(16,185,129,0.10); border-color: rgba(16,185,129,0.25); }
.head h1 { font-size: 28px; font-weight: 800; letter-spacing: -0.03em; color: #0a0a0a; line-height: 1.1; }
.head p { font-size: 13.5px; color: #6b7280; margin-top: 8px; line-height: 1.55; }

.loading-box { text-align: center; padding: 60px 20px; color: #6b7280; }
.spinner { width: 34px; height: 34px; border: 3px solid rgba(0,0,0,0.06); border-top-color: #6366f1; border-radius: 50%; animation: spin 0.8s linear infinite; margin: 0 auto 14px; }
@keyframes spin { to { transform: rotate(360deg); } }

.qr-box {
  position: relative; background: #fff; border: 1px solid rgba(0,0,0,0.06); border-radius: 18px;
  padding: 18px; text-align: center; margin-bottom: 16px;
  box-shadow: 0 10px 30px -12px rgba(79,70,229,0.25), 0 2px 6px rgba(0,0,0,0.03);
}
.qr-glow { position: absolute; inset: -2px; border-radius: 20px; background: conic-gradient(from 0deg, #6366f1, #10b981, #6366f1); filter: blur(18px); opacity: 0.15; z-index: -1; animation: rot 8s linear infinite; }
@keyframes rot { to { transform: rotate(360deg); } }
.qr-img { width: 220px; height: 220px; margin: 0 auto; display: block; border-radius: 10px; image-rendering: pixelated; }

.manual-box { background: rgba(250,250,252,0.8); backdrop-filter: blur(8px); border: 1px solid rgba(0,0,0,0.06); border-radius: 14px; padding: 14px; margin-bottom: 16px; }
.manual-label { font-size: 11px; font-weight: 700; color: #6b7280; text-transform: uppercase; letter-spacing: 0.08em; margin-bottom: 8px; }
.manual-secret { display: flex; gap: 8px; align-items: center; }
.manual-secret code { flex: 1; font-family: ui-monospace, monospace; font-size: 12.5px; color: #0a0a0a; font-weight: 700; background: #fff; padding: 9px 12px; border-radius: 9px; border: 1px solid rgba(0,0,0,0.06); word-break: break-all; }
.copy-btn { padding: 9px 14px; background: linear-gradient(135deg, #111 0%, #2a2a2a 100%); color: #fff; border: none; border-radius: 9px; font-size: 12px; font-weight: 700; cursor: pointer; transition: transform 0.15s, box-shadow 0.15s; }
.copy-btn:hover { transform: translateY(-1px); box-shadow: 0 6px 16px -6px rgba(0,0,0,0.5); }

.form { display: flex; flex-direction: column; gap: 14px; }
.form-group { display: flex; flex-direction: column; gap: 6px; }
.form-group label { font-size: 12px; font-weight: 600; color: #404040; }

.totp-input { width: 100%; padding: 16px; border: 1px solid rgba(0,0,0,0.08); border-radius: 12px; font-size: 24px; letter-spacing: 14px; text-align: center; font-family: ui-monospace, monospace; font-weight: 700; color: #0a0a0a; background: #fafafc; transition: all 0.18s; }
.totp-input:focus { outline: none; border-color: #6366f1; background: #fff; box-shadow: 0 0 0 4px rgba(99,102,241,0.12); }
.totp-input::placeholder { color: #cbd5e1; letter-spacing: 14px; }

.alert { padding: 11px 14px; border-radius: 10px; font-size: 13px; line-height: 1.5; }
.alert-error { background: #fef2f2; color: #991b1b; border: 1px solid #fecaca; }
.alert-warn { background: #fffbeb; color: #78350f; border: 1px solid #fde68a; margin-top: 12px; }

.btn-submit { position: relative; width: 100%; padding: 14px; background: linear-gradient(135deg, #0a0a0a 0%, #1f1f1f 60%, #0a0a0a 100%); background-size: 200% 100%; color: #fff; border: none; border-radius: 12px; font-size: 14px; font-weight: 700; cursor: pointer; transition: all 0.2s; overflow: hidden; box-shadow: 0 8px 20px -8px rgba(0,0,0,0.5); }
.btn-submit:hover:not(:disabled) { background-position: -100% 0; transform: translateY(-1px); box-shadow: 0 12px 26px -8px rgba(0,0,0,0.55); }
.btn-submit:disabled { opacity: 0.45; cursor: not-allowed; transform: none; }
.btn-loading { display: inline-flex; align-items: center; gap: 8px; justify-content: center; }
.btn-spinner { width: 14px; height: 14px; border: 2px solid rgba(255,255,255,0.3); border-top-color: #fff; border-radius: 50%; animation: spin 0.7s linear infinite; }

.backup-box { background: rgba(250,250,252,0.8); backdrop-filter: blur(8px); border: 1px solid rgba(0,0,0,0.06); border-radius: 16px; padding: 16px; margin-bottom: 12px; }
.backup-codes { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin-bottom: 12px; }
.backup-codes code { font-family: ui-monospace, monospace; font-size: 13px; font-weight: 700; color: #0a0a0a; background: #fff; padding: 10px; border-radius: 8px; border: 1px solid rgba(0,0,0,0.06); text-align: center; }
.copy-btn-full { width: 100%; padding: 11px; background: #fff; color: #0a0a0a; border: 1px solid rgba(0,0,0,0.1); border-radius: 10px; font-size: 13px; font-weight: 700; cursor: pointer; transition: all 0.15s; }
.copy-btn-full:hover { background: #f5f5f7; transform: translateY(-1px); }

.auth-right {
  position: relative;
  background:
    radial-gradient(800px 400px at 20% 10%, rgba(99,102,241,0.35), transparent 60%),
    radial-gradient(700px 500px at 90% 90%, rgba(16,185,129,0.25), transparent 60%),
    linear-gradient(135deg, #050505 0%, #0f0f14 50%, #050505 100%);
  color: #fff; padding: 60px 48px; display: flex; align-items: center; justify-content: center; overflow: hidden; z-index: 1;
}
.auth-right::before { content: ''; position: absolute; inset: 0; background-image: linear-gradient(rgba(255,255,255,0.03) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.03) 1px, transparent 1px); background-size: 40px 40px; mask-image: radial-gradient(circle at 50% 50%, black 30%, transparent 80%); pointer-events: none; }
.branding { max-width: 460px; position: relative; z-index: 1; }
.brand-logo-big { width: 76px; height: 76px; border-radius: 20px; background: rgba(255,255,255,0.06); display: flex; align-items: center; justify-content: center; margin-bottom: 30px; padding: 12px; border: 1px solid rgba(255,255,255,0.12); backdrop-filter: blur(10px); box-shadow: 0 20px 40px -20px rgba(99,102,241,0.5); }
.brand-logo-big img { width: 100%; height: auto; }
.branding h2 { font-size: 34px; font-weight: 800; letter-spacing: -0.03em; line-height: 1.12; margin-bottom: 18px; background: linear-gradient(180deg, #ffffff 0%, #b8b8c8 100%); -webkit-background-clip: text; background-clip: text; -webkit-text-fill-color: transparent; }
.branding-sub { font-size: 15px; opacity: 0.7; line-height: 1.65; margin-bottom: 40px; }

.feature-list { display: flex; flex-direction: column; gap: 20px; }
.feature-item { display: flex; gap: 14px; align-items: flex-start; }
.feature-icon { width: 32px; height: 32px; border-radius: 10px; background: linear-gradient(135deg, rgba(16,185,129,0.25), rgba(99,102,241,0.25)); color: #7dd3fc; display: flex; align-items: center; justify-content: center; font-size: 13px; font-weight: 800; flex-shrink: 0; border: 1px solid rgba(255,255,255,0.1); }
.feature-title { font-size: 14px; font-weight: 700; margin-bottom: 3px; }
.feature-desc { font-size: 12.5px; opacity: 0.6; line-height: 1.4; }

@media (max-width: 900px) {
  .auth-page { grid-template-columns: 1fr; }
  .auth-right { display: none; }
  .auth-left { padding: 28px 20px; }
}
@media (prefers-reduced-motion: reduce) {
  .flake { animation: none; opacity: 0 !important; }
  .auth-box, .qr-glow { animation: none; }
}
</style>
