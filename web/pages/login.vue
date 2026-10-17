<template>
  <div class="auth-page">
    <div class="bg-glow glow-a" aria-hidden="true"></div>
    <div class="bg-glow glow-b" aria-hidden="true"></div>

    <div class="auth-left">
      <div class="auth-box">
        <NuxtLink to="/" class="btn-close" title="Kembali ke beranda">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
            <line x1="18" y1="6" x2="6" y2="18"/>
            <line x1="6" y1="6" x2="18" y2="18"/>
          </svg>
        </NuxtLink>

        <NuxtLink to="/" class="brand">
          <SiteLogo />
        </NuxtLink>

        <div class="head">
          <div class="eyebrow">{{ showTfa ? 'Verifikasi 2FA' : 'Masuk' }}</div>
          <h1>{{ showTfa ? 'Kode 2FA' : 'Selamat datang kembali' }}</h1>
          <p>{{ showTfa ? 'Masukkan 6 digit dari Google Authenticator' : 'Masuk ke dashboard payment gateway kamu' }}</p>
        </div>

        <form v-if="!showTfa" @submit.prevent="onLogin" class="form">
          <div class="form-group">
            <label>Email</label>
            <div class="input-wrap">
              <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
                <polyline points="22,6 12,13 2,6"/>
              </svg>
              <input v-model="email" type="email" required placeholder="email@kamu.com" :disabled="loading" />
            </div>
          </div>

          <div class="form-group">
            <label>Password</label>
            <div class="input-wrap">
              <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
              </svg>
              <input v-model="password" :type="showPass ? 'text' : 'password'" required placeholder="Masukkan password" :disabled="loading" />
              <button type="button" class="input-action" @click="showPass = !showPass" :aria-label="showPass ? 'Sembunyikan password' : 'Tampilkan password'">
                <svg v-if="!showPass" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                  <circle cx="12" cy="12" r="3"/>
                </svg>
                <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/>
                  <line x1="1" y1="1" x2="23" y2="23"/>
                </svg>
              </button>
            </div>
          </div>

          <div class="turnstile-wrap">
            <div ref="turnstileEl" class="turnstile-el"></div>
            <p v-if="!turnstileToken && turnstileError" class="turnstile-hint error">
              Captcha gagal dimuat. <button type="button" @click="reloadTurnstile">Coba lagi</button>
            </p>
          </div>

          <div v-if="error" class="alert alert-error">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="12" cy="12" r="10"/>
              <line x1="12" y1="8" x2="12" y2="12"/>
              <line x1="12" y1="16" x2="12.01" y2="16"/>
            </svg>
            <span>{{ error }}</span>
          </div>

          <button type="submit" class="btn-submit" :disabled="loading || !turnstileToken">
            <span v-if="loading" class="btn-loading">
              <span class="btn-spinner"></span>
              Memuat...
            </span>
            <span v-else>Masuk</span>
          </button>

          <p class="legal-note">
            Dengan masuk, kamu setuju dengan
            <NuxtLink to="/tos">Syarat &amp; Ketentuan</NuxtLink> dan
            <NuxtLink to="/privacy">Kebijakan Privasi</NuxtLink>.
          </p>
        </form>

        <form v-if="showTfa" @submit.prevent="onVerifyTfa" class="form">
          <div class="form-group">
            <label>Kode 6 Digit</label>
            <div class="input-wrap">
              <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
              </svg>
              <input v-model="tfaCode" type="text" inputmode="numeric" maxlength="6" required placeholder="0 0 0 0 0 0" class="tfa-code-input" :disabled="loading" />
            </div>
            <div class="tfa-hint">Buka Google Authenticator lalu masukkan 6 digit</div>
          </div>

          <div v-if="error" class="alert alert-error">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="12" cy="12" r="10"/>
              <line x1="12" y1="8" x2="12" y2="12"/>
              <line x1="12" y1="16" x2="12.01" y2="16"/>
            </svg>
            <span>{{ error }}</span>
          </div>

          <button type="submit" class="btn-submit" :disabled="loading || tfaCode.length !== 6">
            <span v-if="loading" class="btn-loading">
              <span class="btn-spinner"></span>
              Memverifikasi...
            </span>
            <span v-else>Verifikasi</span>
          </button>

          <button type="button" class="btn-back" @click="backToLogin">Kembali ke Login</button>
        </form>

        <div class="divider"><span>atau</span></div>

        <p class="footer-link">
          Belum punya akun?
          <NuxtLink to="/register">Daftar gratis</NuxtLink>
        </p>
      </div>
    </div>

    <div class="auth-right">
      <div class="branding">
        <div class="brand-logo-big">
          <SiteLogo />
        </div>
        <h2>Payment Gateway QRIS<br />untuk Merchant Indonesia</h2>
        <p class="branding-sub">Terima pembayaran QRIS tanpa ribet. Dashboard lengkap, API siap pakai, webhook real-time.</p>

        <div class="feature-list">
          <div class="feature-item">
            <div class="feature-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></div>
            <div>
              <div class="feature-title">QRIS Dinamis</div>
              <div class="feature-desc">Setiap transaksi nominal unik</div>
            </div>
          </div>
          <div class="feature-item">
            <div class="feature-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></div>
            <div>
              <div class="feature-title">Webhook Signed</div>
              <div class="feature-desc">Notifikasi HMAC-SHA256</div>
            </div>
          </div>
          <div class="feature-item">
            <div class="feature-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></div>
            <div>
              <div class="feature-title">2FA Ready</div>
              <div class="feature-desc">Keamanan Google Authenticator</div>
            </div>
          </div>
          <div class="feature-item">
            <div class="feature-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></div>
            <div>
              <div class="feature-title">Auto-matching</div>
              <div class="feature-desc">Pembayaran terdeteksi otomatis</div>
            </div>
          </div>
        </div>

        <div class="branding-foot">
          <span>© {{ year }} {{ siteName }}</span>
          <span>v1.0.0</span>
        </div>
      </div>
    </div>

    <Teleport to="body">
      <Transition name="modal">
        <div v-if="showSuccess" class="modal-overlay">
          <div class="modal">
            <div class="success-icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="20 6 9 17 4 12"/>
              </svg>
            </div>
            <h2>Login Berhasil</h2>
            <p class="modal-msg">Selamat datang kembali, <strong>{{ userName }}</strong>. Mengalihkan ke dashboard...</p>
            <div class="modal-loader"><div class="loader-bar"></div></div>
          </div>
        </div>
      </Transition>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: false })

const config = useRuntimeConfig()
const { siteName } = useSiteSettings()
const turnstileKey = computed(() => config.public.turnstileSiteKey || process.env.NUXT_PUBLIC_TURNSTILE_SITE_KEY || '')

const email = ref('')
const password = ref('')
const tfaCode = ref('')
const showPass = ref(false)
const showTfa = ref(false)
const error = ref('')
const loading = ref(false)
const showSuccess = ref(false)
const userName = ref('')
const tempToken = ref('')
const turnstileToken = ref('')
const turnstileError = ref(false)
const turnstileEl = ref<HTMLElement | null>(null)
let widgetId: string | null = null
const year = new Date().getFullYear()

function loadTurnstileScript(): Promise<void> {
  return new Promise((resolve, reject) => {
    if ((window as any).turnstile) return resolve()
    const s = document.createElement('script')
    s.src = 'https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit'
    s.async = true
    s.defer = true
    s.onload = () => resolve()
    s.onerror = () => reject(new Error('turnstile script failed'))
    document.head.appendChild(s)
  })
}

async function renderTurnstile() {
  if (!turnstileKey.value) {
    turnstileError.value = true
    return
  }
  try {
    await loadTurnstileScript()
    const t = (window as any).turnstile
    if (!t || !turnstileEl.value) return
    if (widgetId) {
      try { t.remove(widgetId) } catch {}
      widgetId = null
    }
    widgetId = t.render(turnstileEl.value, {
      sitekey: turnstileKey.value,
      theme: 'light',
      callback: (token: string) => {
        turnstileToken.value = token
        turnstileError.value = false
      },
      'error-callback': () => {
        turnstileToken.value = ''
        turnstileError.value = true
      },
      'expired-callback': () => {
        turnstileToken.value = ''
      },
    })
  } catch {
    turnstileError.value = true
  }
}

function reloadTurnstile() {
  turnstileToken.value = ''
  turnstileError.value = false
  renderTurnstile()
}

async function onLogin() {
  error.value = ''
  if (!turnstileToken.value) {
    error.value = 'Selesaikan captcha terlebih dahulu'
    return
  }
  loading.value = true
  try {
    const r: any = await $fetch('/api/auth/login', {
      method: 'POST',
      body: { email: email.value, password: password.value, turnstileToken: turnstileToken.value },
      credentials: 'include',
    })

    if (r?.success && r.data?.requires2fa) {
      showTfa.value = true
      tempToken.value = r.data.tempToken || ''
      loading.value = false
      return
    }

    if (r?.success) {
      userName.value = r.data?.user?.name || email.value
      showSuccess.value = true
      setTimeout(() => navigateTo('/merchant'), 1200)
      return
    }

    error.value = 'Login gagal'
    reloadTurnstile()
  } catch (e: any) {
    error.value = e?.data?.error || e.message || 'Login gagal'
    reloadTurnstile()
  } finally {
    loading.value = false
  }
}

async function onVerifyTfa() {
  error.value = ''
  if (tfaCode.value.length !== 6) return
  loading.value = true
  try {
    const r: any = await $fetch('/api/auth/login/totp', {
      method: 'POST',
      body: { email: email.value, token: tfaCode.value, tempToken: tempToken.value },
      credentials: 'include',
    })

    if (r?.success) {
      userName.value = r.data?.user?.name || email.value
      showSuccess.value = true
      setTimeout(() => navigateTo('/merchant'), 1200)
      return
    }

    error.value = 'Kode 2FA salah'
  } catch (e: any) {
    error.value = e?.data?.error || 'Kode 2FA salah'
    tfaCode.value = ''
  } finally {
    loading.value = false
  }
}

function backToLogin() {
  showTfa.value = false
  tfaCode.value = ''
  error.value = ''
}

onMounted(() => { renderTurnstile() })
onBeforeUnmount(() => {
  if (widgetId && (window as any).turnstile) {
    try { (window as any).turnstile.remove(widgetId) } catch {}
  }
})
</script>

<style scoped>
* { box-sizing: border-box; }

.auth-page {
  min-height: 100vh;
  display: grid;
  grid-template-columns: 1fr 1fr;
  position: relative;
  overflow: hidden;
  background: var(--bg, #ffffff);
  color: var(--txt, #16121f);
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
  -webkit-font-smoothing: antialiased;
}

/* ===== BG GLOW ===== */
.bg-glow {
  position: fixed;
  pointer-events: none;
  z-index: 0;
  border-radius: 50%;
  filter: blur(120px);
}
.glow-a {
  width: 500px; height: 500px;
  top: -180px; left: -120px;
  background: radial-gradient(circle, rgba(124,58,237,0.1), transparent 70%);
}
.glow-b {
  width: 600px; height: 600px;
  bottom: -240px; right: -180px;
  background: radial-gradient(circle, rgba(217,70,239,0.07), transparent 70%);
}

/* ===== LEFT (FORM) ===== */
.auth-left {
  position: relative; z-index: 1;
  display: flex; align-items: center; justify-content: center;
  padding: 40px;
  overflow-y: auto;
}
.auth-box {
  width: 100%; max-width: 420px;
  padding: 40px 36px;
  background: #ffffff;
  border: 1px solid var(--line, #eceaf4);
  border-radius: 24px;
  box-shadow:
    0 4px 8px rgba(88,60,160,0.04),
    0 30px 70px -20px rgba(88,60,160,0.18);
  animation: fadeUp 0.6s cubic-bezier(0.22,1,0.36,1) both;
  position: relative;
}
@keyframes fadeUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

.btn-close {
  position: absolute; top: 16px; right: 16px;
  width: 34px; height: 34px;
  border-radius: 10px;
  background: var(--bg-soft, #f9f8fc);
  border: 1px solid var(--line, #eceaf4);
  color: var(--dim, #6f6a80);
  display: flex; align-items: center; justify-content: center;
  cursor: pointer;
  transition: all 0.15s;
  text-decoration: none;
  z-index: 2;
}
.btn-close:hover { border-color: rgba(124,58,237,0.35); color: var(--vio, #7c3aed); }
.btn-close svg { width: 15px; height: 15px; }

.brand { display: flex; margin-bottom: 28px; }
.brand :deep(img) { height: 36px; width: auto; display: block; }

.head { margin-bottom: 24px; }
.eyebrow {
  display: inline-block;
  font-size: 10.5px; font-weight: 800;
  letter-spacing: 0.14em; text-transform: uppercase;
  color: var(--vio, #7c3aed);
  background: rgba(124,58,237,0.06);
  border: 1px solid rgba(124,58,237,0.18);
  padding: 5px 11px; border-radius: 999px;
  margin-bottom: 14px;
}
.head h1 {
  font-size: 26px; font-weight: 800;
  letter-spacing: -0.03em;
  color: var(--txt, #16121f);
  line-height: 1.15;
  margin-bottom: 8px;
}
.head p { font-size: 13px; color: var(--dim, #6f6a80); line-height: 1.55; }

/* ===== FORM ===== */
.form { display: flex; flex-direction: column; gap: 14px; }
.form-group { display: flex; flex-direction: column; gap: 8px; }
.form-group label { font-size: 12px; font-weight: 700; color: var(--txt, #16121f); }

.input-wrap { position: relative; display: flex; align-items: center; }
.input-icon {
  position: absolute; left: 13px; top: 50%;
  transform: translateY(-50%);
  width: 16px; height: 16px;
  color: var(--dim, #6f6a80);
  pointer-events: none;
}
.input-wrap input {
  width: 100%;
  padding: 12px 42px 12px 40px;
  border: 1px solid var(--line-2, #ddd9ee);
  border-radius: 12px;
  font-size: 14px;
  color: var(--txt, #16121f);
  background: #ffffff;
  outline: none;
  transition: border-color 0.18s, box-shadow 0.18s;
  font-family: inherit;
}
.input-wrap input::placeholder { color: var(--dim, #6f6a80); opacity: 0.55; }
.input-wrap input:focus {
  border-color: var(--vio, #7c3aed);
  box-shadow: 0 0 0 4px rgba(124,58,237,0.12);
}
.input-wrap input:disabled { opacity: 0.5; }

.tfa-code-input {
  text-align: center;
  letter-spacing: 10px;
  font-family: ui-monospace, monospace;
  font-size: 20px !important;
  font-weight: 800;
  padding-left: 40px !important;
}
.tfa-code-input::placeholder { letter-spacing: 10px; color: var(--line-2, #ddd9ee); }

.input-action {
  position: absolute; right: 8px; top: 50%;
  transform: translateY(-50%);
  background: transparent;
  border: none;
  padding: 6px;
  cursor: pointer;
  color: var(--dim, #6f6a80);
  display: flex;
  border-radius: 6px;
  transition: color 0.15s, background 0.15s;
}
.input-action:hover { color: var(--vio, #7c3aed); background: rgba(124,58,237,0.06); }
.input-action svg { width: 15px; height: 15px; }

.tfa-hint { font-size: 12px; color: var(--dim, #6f6a80); margin-top: 4px; line-height: 1.5; }

/* ===== TURNSTILE ===== */
.turnstile-wrap {
  display: flex; flex-direction: column;
  align-items: center; gap: 6px;
  margin: 4px 0;
}
.turnstile-el { min-height: 65px; }
.turnstile-hint { font-size: 11.5px; color: var(--dim, #6f6a80); text-align: center; }
.turnstile-hint.error { color: var(--bad, #e11d48); }
.turnstile-hint button {
  background: transparent;
  border: none;
  color: var(--vio, #7c3aed);
  text-decoration: underline;
  cursor: pointer;
  font-family: inherit;
  font-size: inherit;
  padding: 0;
}

/* ===== ALERT ===== */
.alert {
  display: flex; align-items: center; gap: 8px;
  padding: 11px 14px;
  border-radius: 10px;
  font-size: 12.5px;
  line-height: 1.5;
}
.alert svg { width: 16px; height: 16px; flex-shrink: 0; }
.alert-error {
  background: rgba(225,29,72,0.05);
  color: var(--bad, #e11d48);
  border: 1px solid rgba(225,29,72,0.18);
  font-weight: 600;
}

/* ===== BUTTON ===== */
.btn-submit {
  width: 100%;
  padding: 14px;
  background: var(--grad, linear-gradient(135deg, #7c3aed, #d946ef));
  color: #ffffff;
  border: none;
  border-radius: 12px;
  font-size: 14px;
  font-weight: 800;
  cursor: pointer;
  transition: all 0.2s;
  font-family: inherit;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  box-shadow: 0 10px 28px -8px rgba(124,58,237,0.55);
}
.btn-submit:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 16px 36px -10px rgba(124,58,237,0.65);
}
.btn-submit:disabled { opacity: 0.35; cursor: not-allowed; transform: none; box-shadow: none; }
.btn-submit svg { width: 15px; height: 15px; }
.btn-loading { display: inline-flex; align-items: center; gap: 8px; }
.btn-spinner {
  width: 14px; height: 14px;
  border: 2px solid rgba(255,255,255,0.3);
  border-top-color: #ffffff;
  border-radius: 50%;
  animation: spin 0.7s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }

.btn-back {
  background: transparent;
  border: none;
  color: var(--dim, #6f6a80);
  font-size: 12.5px;
  font-weight: 600;
  cursor: pointer;
  padding: 8px;
  font-family: inherit;
  transition: color 0.15s;
}
.btn-back:hover { color: var(--vio, #7c3aed); }

/* ===== LEGAL & FOOTER ===== */
.legal-note {
  text-align: center;
  margin-top: 4px;
  font-size: 12px;
  color: var(--dim, #6f6a80);
  line-height: 1.6;
}
.legal-note a { color: var(--vio, #7c3aed); text-decoration: none; font-weight: 650; }
.legal-note a:hover { text-decoration: underline; }

.divider { display: flex; align-items: center; margin: 22px 0 18px; gap: 12px; }
.divider::before, .divider::after {
  content: '';
  flex: 1;
  height: 1px;
  background: var(--line, #eceaf4);
}
.divider span {
  font-size: 11px;
  color: var(--dim, #6f6a80);
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.12em;
}

.footer-link { text-align: center; font-size: 13px; color: var(--dim, #6f6a80); }
.footer-link a { color: var(--vio, #7c3aed); font-weight: 750; text-decoration: none; }
.footer-link a:hover { text-decoration: underline; }

/* ===== RIGHT (BRANDING) ===== */
.auth-right {
  position: relative; z-index: 1;
  padding: 60px 56px;
  display: flex; align-items: center; justify-content: center;
  overflow: hidden;
  border-left: 1px solid var(--line, #eceaf4);
  background:
    radial-gradient(600px 400px at 80% 20%, rgba(124,58,237,0.07), transparent 60%),
    var(--bg-soft, #f9f8fc);
}
.branding { max-width: 440px; position: relative; z-index: 1; }
.brand-logo-big {
  width: 68px; height: 68px;
  border-radius: 18px;
  background: var(--grad, linear-gradient(135deg, #7c3aed, #d946ef));
  display: flex; align-items: center; justify-content: center;
  margin-bottom: 32px;
  padding: 14px;
  box-shadow: 0 16px 40px -12px rgba(124,58,237,0.55);
}
.brand-logo-big :deep(img) {
  width: 100%; height: auto;
  filter: brightness(0) invert(1);
}
.branding h2 {
  font-size: 34px; font-weight: 800;
  letter-spacing: -0.035em;
  line-height: 1.12;
  margin-bottom: 18px;
  color: var(--txt, #16121f);
}
.branding-sub {
  font-size: 14.5px;
  color: var(--dim, #6f6a80);
  line-height: 1.65;
  margin-bottom: 40px;
}

.feature-list { display: flex; flex-direction: column; gap: 16px; }
.feature-item { display: flex; gap: 14px; align-items: flex-start; }
.feature-icon {
  width: 34px; height: 34px;
  border-radius: 10px;
  background: rgba(124,58,237,0.07);
  border: 1px solid rgba(124,58,237,0.15);
  color: var(--vio, #7c3aed);
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
}
.feature-icon svg { width: 16px; height: 16px; }
.feature-title { font-size: 13.5px; font-weight: 750; margin-bottom: 3px; color: var(--txt, #16121f); }
.feature-desc { font-size: 12.5px; color: var(--dim, #6f6a80); line-height: 1.45; }

.branding-foot {
  display: flex;
  justify-content: space-between;
  margin-top: 40px;
  padding-top: 20px;
  border-top: 1px solid var(--line, #eceaf4);
  font-size: 11px;
  color: var(--dim, #6f6a80);
}

/* ===== SUCCESS MODAL ===== */
.modal-overlay {
  position: fixed; inset: 0;
  background: rgba(22, 18, 31, 0.45);
  backdrop-filter: blur(6px);
  -webkit-backdrop-filter: blur(6px);
  display: flex; align-items: center; justify-content: center;
  z-index: 900;
  padding: 20px;
}
.modal {
  background: #ffffff;
  border: 1px solid var(--line, #eceaf4);
  border-radius: 24px;
  width: 100%; max-width: 380px;
  padding: 40px 32px 32px;
  text-align: center;
  box-shadow: 0 40px 90px -20px rgba(88,60,160,0.35);
  animation: popIn 0.4s cubic-bezier(0.34, 1.56, 0.64, 1) both;
}
@keyframes popIn {
  from { opacity: 0; transform: scale(0.9); }
  to { opacity: 1; transform: scale(1); }
}
.success-icon {
  width: 72px; height: 72px;
  margin: 0 auto 20px;
  border-radius: 50%;
  background: var(--grad, linear-gradient(135deg, #7c3aed, #d946ef));
  display: flex; align-items: center; justify-content: center;
  color: #ffffff;
  box-shadow: 0 16px 40px -10px rgba(124,58,237,0.55);
}
.success-icon svg { width: 36px; height: 36px; }
.modal h2 {
  font-size: 22px; font-weight: 800;
  color: var(--txt, #16121f);
  margin-bottom: 10px;
  letter-spacing: -0.02em;
}
.modal-msg {
  font-size: 14px;
  color: var(--dim, #6f6a80);
  line-height: 1.6;
  margin-bottom: 22px;
}
.modal-msg strong { color: var(--txt, #16121f); }
.modal-loader {
  width: 100%; height: 4px;
  background: var(--line, #eceaf4);
  border-radius: 999px;
  overflow: hidden;
}
.loader-bar {
  height: 100%;
  width: 40%;
  background: var(--grad, linear-gradient(135deg, #7c3aed, #d946ef));
  border-radius: 999px;
  animation: loading 1.2s ease-in-out infinite;
}
@keyframes loading {
  0% { margin-left: -40%; }
  100% { margin-left: 100%; }
}

.modal-enter-active, .modal-leave-active { transition: opacity 0.25s; }
.modal-enter-from, .modal-leave-to { opacity: 0; }

/* ===== MOBILE ===== */
@media (max-width: 900px) {
  .auth-page { grid-template-columns: 1fr; }
  .auth-right { display: none; }
  .auth-left { padding: 24px 16px; }
  .auth-box { padding: 32px 24px; border-radius: 20px; }
  .head h1 { font-size: 22px; }
}

@media (max-width: 480px) {
  .auth-left { padding: 16px 12px; }
  .auth-box { padding: 28px 20px; border-radius: 18px; }
  .head h1 { font-size: 20px; }
  .head p { font-size: 12.5px; }
  .input-wrap input { font-size: 13.5px; padding: 11px 40px 11px 38px; }
  .tfa-code-input { font-size: 18px !important; letter-spacing: 8px; }
  .btn-submit { padding: 13px; font-size: 13.5px; }
}
</style>