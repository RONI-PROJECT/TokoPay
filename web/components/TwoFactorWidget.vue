<template>
  <div v-if="show" class="tfa-widget">
    <button class="tfa-toggle" @click="open = !open">
      <div class="tfa-lock-icon" :class="totpEnabled ? 'on' : 'off'">
        <svg v-if="totpEnabled" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
          <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
        </svg>
        <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
          <path d="M7 11V7a5 5 0 0 1 9.9-1"/>
        </svg>
      </div>
      <div class="tfa-toggle-info">
        <div class="tfa-toggle-title">Keamanan 2FA</div>
        <div class="tfa-toggle-status" :class="totpEnabled ? 'on' : 'off'">
          {{ totpEnabled ? 'Aktif' : 'Belum Aktif' }}
        </div>
      </div>
    </button>

    <Transition name="tfa-panel">
      <div v-if="open" class="tfa-panel">
        <div class="tfa-panel-head">
          <div>
            <h3>Keamanan 2FA</h3>
            <p>Google Authenticator</p>
          </div>
          <button class="tfa-close" @click="open = false">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <line x1="18" y1="6" x2="6" y2="18"/>
              <line x1="6" y1="6" x2="18" y2="18"/>
            </svg>
          </button>
        </div>

        <div class="tfa-status-box" :class="totpEnabled ? 'active' : 'inactive'">
          <span v-if="totpEnabled">2FA sudah aktif di akun Anda</span>
          <span v-else>2FA belum aktif. Amankan akun Anda.</span>
        </div>

        <button v-if="!totpEnabled && !setupMode" class="tfa-btn-primary" @click="startSetup" :disabled="loading">
          {{ loading ? 'Memuat...' : 'Mulai Setup 2FA' }}
        </button>

        <template v-if="setupMode && !totpEnabled">
          <div class="tfa-block">
            <div class="tfa-block-head">
              <div class="tfa-step-num">1</div>
              <div class="tfa-step-title">Scan QR pakai Google Authenticator</div>
            </div>
            <div class="tfa-qr-wrap">
              <div v-if="qrUrl" class="tfa-qr-box">
                <img :src="qrUrl" alt="QR 2FA" class="tfa-qr" />
              </div>
              <div v-else class="tfa-qr-loading">
                <div class="tfa-spinner"></div>
                <span>Memuat QR...</span>
              </div>
            </div>
          </div>

          <div class="tfa-block">
            <div class="tfa-manual-label">Atau masukkan kode manual:</div>
            <div class="tfa-manual-row">
              <code>{{ formattedKey }}</code>
              <button class="tfa-copy-mini" @click="copyKey" title="Copy">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <rect x="9" y="9" width="13" height="13" rx="2" ry="2"/>
                  <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/>
                </svg>
              </button>
            </div>
          </div>

          <div class="tfa-block">
            <div class="tfa-block-head">
              <div class="tfa-step-num">2</div>
              <div class="tfa-step-title">Masukkan kode 6 digit</div>
            </div>
            <input
              v-model="code"
              type="text"
              inputmode="numeric"
              maxlength="6"
              placeholder="000000"
              class="tfa-input"
              @keyup.enter="verifySetup"
              autocomplete="off"
            />
          </div>

          <div v-if="error" class="tfa-error">{{ error }}</div>

          <div class="tfa-actions">
            <button class="tfa-btn-cancel" @click="cancelSetup" :disabled="loading">Batal</button>
            <button class="tfa-btn-grad" @click="verifySetup" :disabled="loading || code.length !== 6">
              {{ loading ? 'Memverifikasi...' : 'Aktifkan 2FA' }}
            </button>
          </div>
        </template>

        <template v-if="totpEnabled && !disableMode">
          <button class="tfa-btn-danger" @click="startDisable" :disabled="loading">
            Nonaktifkan 2FA
          </button>
        </template>

        <template v-if="totpEnabled && disableMode">
          <div class="tfa-warn-box">
            Masukkan kode 6 digit dari Google Authenticator untuk konfirmasi.
          </div>

          <div class="tfa-block">
            <div class="tfa-block-head">
              <div class="tfa-step-num">1</div>
              <div class="tfa-step-title">Kode 6 digit</div>
            </div>
            <input
              v-model="disableCode"
              type="text"
              inputmode="numeric"
              maxlength="6"
              placeholder="000000"
              class="tfa-input"
              @keyup.enter="confirmDisable"
              autocomplete="off"
            />
          </div>

          <div v-if="error" class="tfa-error">{{ error }}</div>

          <div class="tfa-actions">
            <button class="tfa-btn-cancel" @click="cancelDisable" :disabled="loading">Batal</button>
            <button class="tfa-btn-danger-solid" @click="confirmDisable" :disabled="loading || disableCode.length !== 6">
              {{ loading ? 'Menonaktifkan...' : 'Konfirmasi' }}
            </button>
          </div>
        </template>
      </div>
    </Transition>
  </div>
</template>

<script setup lang="ts">
const show = ref(false)
const open = ref(false)
const setupMode = ref(false)
const disableMode = ref(false)
const totpEnabled = ref(false)
const qrUrl = ref('')
const manualKey = ref('')
const code = ref('')
const disableCode = ref('')
const error = ref('')
const loading = ref(false)

const formattedKey = computed(() => {
  if (!manualKey.value) return ''
  return manualKey.value.match(/.{1,4}/g)?.join(' ') || manualKey.value
})

async function checkStatus() {
  try {
    const r: any = await $fetch('/api/auth/me', { credentials: 'include' }).catch(() => null)
    if (r?.success) {
      totpEnabled.value = r.data.totpEnabled === true
      show.value = true
    }
  } catch {}
}

async function startSetup() {
  error.value = ''
  loading.value = true
  try {
    const r: any = await $fetch('/api/auth/2fa/setup', { method: 'POST', credentials: 'include' })
    if (r?.success) {
      qrUrl.value = r.data.qrDataUrl || r.data.qr || r.data.qrUrl || ''
      manualKey.value = r.data.secret || r.data.manualEntry || ''
      setupMode.value = true
    } else {
      error.value = r?.error || 'Gagal memulai setup'
    }
  } catch (e: any) {
    error.value = e?.data?.error || e.message
  } finally {
    loading.value = false
  }
}

async function verifySetup() {
  if (code.value.length !== 6) return
  error.value = ''
  loading.value = true
  try {
    const r: any = await $fetch('/api/auth/2fa/verify-setup', {
      method: 'POST',
      body: { token: code.value },
      credentials: 'include',
    })
    if (r?.success) {
      totpEnabled.value = true
      setupMode.value = false
      code.value = ''
      await checkStatus()
    } else {
      error.value = r?.error || 'Kode salah'
    }
  } catch (e: any) {
    error.value = e?.data?.error || 'Kode salah'
  } finally {
    loading.value = false
  }
}

function cancelSetup() {
  setupMode.value = false
  code.value = ''
  error.value = ''
  qrUrl.value = ''
  manualKey.value = ''
}

function startDisable() {
  disableMode.value = true
  disableCode.value = ''
  error.value = ''
}

async function confirmDisable() {
  if (disableCode.value.length !== 6) return
  error.value = ''
  loading.value = true
  try {
    const r: any = await $fetch('/api/auth/2fa/disable', {
      method: 'POST',
      body: { token: disableCode.value },
      credentials: 'include',
    })
    if (r?.success) {
      totpEnabled.value = false
      disableMode.value = false
      disableCode.value = ''
      await checkStatus()
    } else {
      error.value = r?.error || 'Kode salah'
    }
  } catch (e: any) {
    error.value = e?.data?.error || 'Kode salah'
  } finally {
    loading.value = false
  }
}

function cancelDisable() {
  disableMode.value = false
  disableCode.value = ''
  error.value = ''
}

function copyKey() {
  if (!manualKey.value) return
  navigator.clipboard.writeText(manualKey.value)
  alert('Kode manual di-copy!')
}

onMounted(() => { checkStatus() })

defineExpose({ checkStatus })
</script>

<style scoped>
/* Widget mengambang di pojok kanan bawah */
.tfa-widget {
  position: fixed;
  bottom: 24px;
  right: 24px;
  z-index: 850;
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
  pointer-events: auto;
}

/* ===== TOGGLE BUTTON ===== */
.tfa-toggle {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 18px;
  background: #ffffff;
  color: var(--txt, #16121f);
  border: 1px solid var(--line, #eceaf4);
  border-radius: 14px;
  cursor: pointer;
  font-family: inherit;
  box-shadow: 0 12px 36px -10px rgba(88,60,160,0.25);
  transition: all 0.2s;
  width: auto;
  max-width: calc(100vw - 32px);
}
.tfa-toggle:hover {
  border-color: rgba(124,58,237,0.35);
  transform: translateY(-2px);
  box-shadow: 0 16px 44px -10px rgba(124,58,237,0.35);
}

.tfa-lock-icon {
  width: 38px; height: 38px;
  border-radius: 10px;
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
  transition: all 0.2s;
}
.tfa-lock-icon svg { width: 18px; height: 18px; }
.tfa-lock-icon.off {
  background: rgba(245,158,11,0.1);
  border: 1px solid rgba(245,158,11,0.3);
  color: #d97706;
}
.tfa-lock-icon.on {
  background: var(--grad, linear-gradient(135deg, #7c3aed, #d946ef));
  border: none;
  color: #ffffff;
  box-shadow: 0 6px 16px -4px rgba(124,58,237,0.5);
}

.tfa-toggle-info { text-align: left; }
.tfa-toggle-title { font-size: 13px; font-weight: 750; color: var(--txt, #16121f); margin-bottom: 2px; white-space: nowrap; }
.tfa-toggle-status { font-size: 11px; font-weight: 650; white-space: nowrap; }
.tfa-toggle-status.off { color: #d97706; }
.tfa-toggle-status.on { color: var(--vio, #7c3aed); }

/* ===== PANEL ===== */
.tfa-panel {
  position: absolute;
  bottom: 70px;
  right: 0;
  box-sizing: border-box;
  width: 380px;
  max-width: calc(100vw - 32px);
  background: #ffffff;
  border: 1px solid var(--line, #eceaf4);
  border-radius: 20px;
  padding: 22px;
  box-shadow: 0 28px 80px -16px rgba(88,60,160,0.3);
  max-height: 80vh;
  overflow-y: auto;
}

.tfa-panel-head {
  display: flex; justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 16px; gap: 12px;
}
.tfa-panel-head h3 { font-size: 16px; font-weight: 800; color: var(--txt, #16121f); margin-bottom: 4px; letter-spacing: -0.01em; }
.tfa-panel-head p { font-size: 12px; color: var(--dim, #6f6a80); line-height: 1.5; }
.tfa-close {
  background: #fff;
  border: 1px solid var(--line, #eceaf4);
  width: 30px; height: 30px;
  border-radius: 8px;
  color: var(--dim, #6f6a80); cursor: pointer;
  flex-shrink: 0;
  display: flex; align-items: center; justify-content: center;
  transition: all 0.15s;
}
.tfa-close svg { width: 14px; height: 14px; }
.tfa-close:hover { border-color: rgba(124,58,237,0.35); color: var(--vio, #7c3aed); }

/* ===== STATUS / WARN BOX ===== */
.tfa-status-box {
  padding: 11px 14px; border-radius: 10px;
  font-size: 12.5px; font-weight: 650;
  margin-bottom: 16px; text-align: center;
}
.tfa-status-box.inactive {
  background: rgba(245,158,11,0.07);
  color: #d97706;
  border: 1px solid rgba(245,158,11,0.2);
}
.tfa-status-box.active {
  background: rgba(16,185,129,0.07);
  color: #059669;
  border: 1px solid rgba(16,185,129,0.2);
}

.tfa-warn-box {
  padding: 11px 14px; border-radius: 10px;
  font-size: 12px;
  background: var(--bg-soft, #f9f8fc);
  color: var(--dim, #6f6a80);
  border: 1px solid var(--line, #eceaf4);
  margin-bottom: 14px; line-height: 1.55;
  text-align: center;
}

/* ===== STEPS ===== */
.tfa-block { margin-bottom: 16px; width: 100%; }
.tfa-block-head { display: flex; align-items: center; gap: 10px; margin-bottom: 12px; }
.tfa-step-num {
  width: 26px; height: 26px;
  border-radius: 50%;
  background: var(--grad, linear-gradient(135deg, #7c3aed, #d946ef));
  color: #ffffff;
  display: flex; align-items: center; justify-content: center;
  font-size: 12px; font-weight: 800;
  flex-shrink: 0;
  box-shadow: 0 4px 12px -2px rgba(124,58,237,0.4);
}
.tfa-step-title { font-size: 13px; font-weight: 650; color: var(--txt, #16121f); line-height: 1.4; }

/* ===== QR ===== */
.tfa-qr-wrap { display: flex; justify-content: center; align-items: center; width: 100%; margin: 0 auto; }
.tfa-qr-box {
  padding: 10px;
  background: #ffffff;
  border: 1px solid var(--line, #eceaf4);
  border-radius: 14px;
  box-shadow: 0 8px 24px -8px rgba(88,60,160,0.15);
  display: inline-block;
  margin: 0 auto;
}
.tfa-qr { width: 180px; height: 180px; display: block; }
.tfa-qr-loading {
  width: 200px; height: 200px;
  display: flex; flex-direction: column;
  align-items: center; justify-content: center;
  gap: 10px;
  background: var(--bg-soft, #f9f8fc);
  border: 1px dashed var(--line-2, #ddd9ee);
  border-radius: 14px;
  color: var(--dim, #6f6a80); font-size: 12px;
}
.tfa-spinner {
  width: 20px; height: 20px;
  border: 2px solid var(--line, #eceaf4);
  border-top-color: var(--vio, #7c3aed);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }

/* ===== MANUAL KEY ===== */
.tfa-manual-label {
  font-size: 11.5px;
  color: var(--dim, #6f6a80);
  margin-bottom: 8px;
  font-weight: 600;
  text-align: center;
  width: 100%;
}
.tfa-manual-row {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 12px 14px;
  background: var(--bg-soft, #f9f8fc);
  border: 1px solid var(--line, #eceaf4);
  border-radius: 11px;
  width: 100%;
}
.tfa-manual-row code {
  font-family: ui-monospace, monospace;
  color: var(--vio-deep, #5b21b6);
  font-weight: 750;
  font-size: 12px;
  letter-spacing: 1.5px;
  word-break: break-all;
  text-align: center;
  flex: 1;
}
.tfa-copy-mini {
  background: #ffffff;
  border: 1px solid var(--line-2, #ddd9ee);
  border-radius: 7px;
  padding: 6px;
  color: var(--dim, #6f6a80);
  cursor: pointer;
  display: flex; align-items: center;
  flex-shrink: 0;
  transition: all 0.15s;
}
.tfa-copy-mini svg { width: 13px; height: 13px; }
.tfa-copy-mini:hover { border-color: var(--vio, #7c3aed); color: var(--vio, #7c3aed); }

/* ===== CODE INPUT ===== */
.tfa-input {
  width: 100%;
  padding: 16px;
  border: 2px solid var(--line-2, #ddd9ee);
  border-radius: 12px;
  font-size: 24px;
  text-align: center;
  letter-spacing: 12px;
  font-family: ui-monospace, monospace;
  font-weight: 800;
  outline: none;
  background: #ffffff;
  color: var(--txt, #16121f);
  transition: all 0.2s;
  box-sizing: border-box;
}
.tfa-input:focus {
  border-color: var(--vio, #7c3aed);
  box-shadow: 0 0 0 4px rgba(124,58,237,0.12);
}
.tfa-input::placeholder { letter-spacing: 12px; color: var(--line-2, #ddd9ee); font-weight: 700; }

/* ===== ACTIONS ===== */
.tfa-actions { display: flex; gap: 8px; margin-top: 6px; }

.tfa-btn-grad {
  flex: 1;
  padding: 13px;
  background: var(--grad, linear-gradient(135deg, #7c3aed, #d946ef));
  color: #ffffff;
  border: none;
  border-radius: 11px;
  font-size: 13.5px;
  font-weight: 800;
  cursor: pointer;
  font-family: inherit;
  box-shadow: 0 8px 24px -6px rgba(124,58,237,0.5);
  transition: all 0.2s;
}
.tfa-btn-grad:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 14px 32px -8px rgba(124,58,237,0.6);
}
.tfa-btn-grad:disabled { opacity: 0.4; cursor: not-allowed; box-shadow: none; }

.tfa-btn-cancel {
  padding: 13px 18px;
  background: #ffffff;
  color: var(--dim, #6f6a80);
  border: 1px solid var(--line, #eceaf4);
  border-radius: 11px;
  font-size: 13px;
  font-weight: 650;
  cursor: pointer;
  font-family: inherit;
  flex-shrink: 0;
  transition: all 0.15s;
}
.tfa-btn-cancel:hover:not(:disabled) { border-color: var(--line-2, #ddd9ee); color: var(--txt, #16121f); }

.tfa-btn-primary {
  width: 100%;
  padding: 13px;
  background: var(--grad, linear-gradient(135deg, #7c3aed, #d946ef));
  color: #ffffff;
  border: none;
  border-radius: 11px;
  font-size: 13.5px;
  font-weight: 800;
  cursor: pointer;
  font-family: inherit;
  box-shadow: 0 8px 24px -6px rgba(124,58,237,0.5);
  transition: all 0.2s;
}
.tfa-btn-primary:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 14px 32px -8px rgba(124,58,237,0.6);
}
.tfa-btn-primary:disabled { opacity: 0.4; cursor: not-allowed; box-shadow: none; }

.tfa-btn-danger {
  width: 100%;
  padding: 13px;
  background: #ffffff;
  color: var(--bad, #e11d48);
  border: 1px solid rgba(225,29,72,0.3);
  border-radius: 11px;
  font-size: 13px;
  font-weight: 750;
  cursor: pointer;
  font-family: inherit;
  transition: all 0.15s;
}
.tfa-btn-danger:hover:not(:disabled) { background: rgba(225,29,72,0.05); }
.tfa-btn-danger:disabled { opacity: 0.4; cursor: not-allowed; }

.tfa-btn-danger-solid {
  flex: 1;
  padding: 13px;
  background: var(--bad, #e11d48);
  color: #ffffff;
  border: none;
  border-radius: 11px;
  font-size: 13px;
  font-weight: 800;
  cursor: pointer;
  font-family: inherit;
  transition: all 0.2s;
}
.tfa-btn-danger-solid:hover:not(:disabled) { background: #be123c; }
.tfa-btn-danger-solid:disabled { opacity: 0.4; cursor: not-allowed; }

.tfa-error {
  margin-top: 10px;
  padding: 10px 12px;
  background: rgba(225,29,72,0.05);
  color: var(--bad, #e11d48);
  border-radius: 8px;
  font-size: 12px;
  border: 1px solid rgba(225,29,72,0.15);
  text-align: center;
  font-weight: 600;
}

.tfa-panel-enter-active, .tfa-panel-leave-active { transition: opacity 0.25s, transform 0.25s; }
.tfa-panel-enter-from, .tfa-panel-leave-to { opacity: 0; transform: translateY(12px) scale(0.96); }

@media (max-width: 480px) {
  .tfa-widget { bottom: 16px; right: 16px; }
  .tfa-toggle { padding: 10px 14px; }
  .tfa-panel { padding: 18px 16px; }
}
</style>