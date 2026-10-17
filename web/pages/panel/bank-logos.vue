<template>
  <div class="page">
    <div class="head">
      <div>
        <h1>Logo Bank</h1>
        <p class="sub">Override logo default (opsional)</p>
      </div>
      <button class="btn-primary" @click="save" :disabled="saving">
        {{ saving ? 'Menyimpan...' : 'Simpan' }}
      </button>
    </div>

    <div class="info-card">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="info-icon">
        <circle cx="12" cy="12" r="10"/>
        <line x1="12" y1="16" x2="12" y2="12"/>
        <line x1="12" y1="8" x2="12.01" y2="8"/>
      </svg>
      <span><strong>Default:</strong> Logo otomatis dari Clearbit CDN berdasarkan domain bank. Kalau mau override, isi URL custom di bawah.</span>
    </div>

    <div class="list">
      <div v-for="bank in banks" :key="bank.code" class="row">
        <div class="bank-info">
          <div class="bank-logo-wrap">
            <img
              v-if="logos[bank.code] || getBankLogo(bank.code)"
              :src="logos[bank.code] || getBankLogo(bank.code)"
              :alt="bank.code"
              class="bank-logo-img"
              @error="(e) => (e.target as HTMLImageElement).style.display = 'none'"
            />
            <span v-else class="bank-logo-empty">{{ bank.code.charAt(0) }}</span>
          </div>
          <div>
            <div class="bank-name">{{ bank.name }}</div>
            <div class="bank-code">{{ bank.code }}</div>
          </div>
        </div>
        <input v-model="logos[bank.code]" placeholder="URL logo custom (opsional)" class="bank-input" />
      </div>
    </div>

    <Transition name="toast">
      <div v-if="saved" class="toast">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">
          <polyline points="20 6 9 17 4 12"/>
        </svg>
        <span>Logo tersimpan</span>
      </div>
    </Transition>
  </div>
</template>

<script setup lang="ts">
import { getBankLogo } from '~/utils/bankLogo'

definePageMeta({ layout: 'panel' })

const BANKS = [
  { code: 'BCA', name: 'Bank Central Asia' },
  { code: 'BNI', name: 'Bank Negara Indonesia' },
  { code: 'BRI', name: 'Bank Rakyat Indonesia' },
  { code: 'MANDIRI', name: 'Bank Mandiri' },
  { code: 'CIMB', name: 'CIMB Niaga' },
  { code: 'PERMATA', name: 'Bank Permata' },
  { code: 'DANAMON', name: 'Bank Danamon' },
  { code: 'BSI', name: 'Bank Syariah Indonesia' },
  { code: 'BTN', name: 'Bank Tabungan Negara' },
  { code: 'OCBC', name: 'OCBC NISP' },
  { code: 'MAYBANK', name: 'Maybank Indonesia' },
  { code: 'PANIN', name: 'Bank Panin' },
  { code: 'MEGA', name: 'Bank Mega' },
  { code: 'BJB', name: 'Bank Jabar Banten' },
  { code: 'DKI', name: 'Bank DKI' },
  { code: 'JAGO', name: 'Bank Jago' },
  { code: 'SEABANK', name: 'SeaBank' },
  { code: 'NEO', name: 'Bank Neo Commerce' },
  { code: 'BLU', name: 'Blu BCA Digital' },
  { code: 'JENIUS', name: 'Jenius' },
  { code: 'GOPAY', name: 'GoPay' },
  { code: 'OVO', name: 'OVO' },
  { code: 'DANA', name: 'DANA' },
  { code: 'SHOPEEPAY', name: 'ShopeePay' },
  { code: 'LINKAJA', name: 'LinkAja' },
]

const banks = BANKS
const logos = reactive<Record<string, string>>({})
const saving = ref(false)
const saved = ref(false)

async function load() {
  try {
    const r: any = await $fetch('/api/admin-panel/settings', { credentials: 'include' })
    if (r?.success && r.data?.bank_logos) {
      const parsed = JSON.parse(r.data.bank_logos)
      Object.assign(logos, parsed)
    }
  } catch {}
}

async function save() {
  saving.value = true
  try {
    const clean: Record<string, string> = {}
    for (const [k, v] of Object.entries(logos)) {
      if (v && v.trim()) clean[k] = v.trim()
    }
    await $fetch('/api/admin-panel/settings', {
      method: 'POST',
      body: { bank_logos: JSON.stringify(clean) },
      credentials: 'include',
    })
    saved.value = true
    setTimeout(() => (saved.value = false), 2000)
  } catch (e: any) {
    alert('Gagal: ' + (e?.data?.error || e.message))
  } finally {
    saving.value = false
  }
}

onMounted(load)
</script>

<style scoped>
* { box-sizing: border-box; }
.page {
  width: 100%; max-width: 900px;
  margin: 0 auto; padding-bottom: 140px;
  color: var(--txt, #16121f);
  font-family: 'Inter', -apple-system, sans-serif;
}
.head {
  display: flex; justify-content: space-between; align-items: flex-start;
  margin-bottom: 20px; gap: 12px; flex-wrap: wrap;
}
h1 { font-size: 22px; font-weight: 800; color: var(--txt, #16121f); letter-spacing: -0.02em; }
.sub { font-size: 13px; color: var(--dim, #6f6a80); margin-top: 5px; }

.info-card {
  display: flex; align-items: flex-start; gap: 10px;
  padding: 13px 16px;
  background: rgba(124,58,237,0.05);
  border: 1px solid rgba(124,58,237,0.15);
  border-radius: 12px;
  font-size: 12.5px; color: var(--dim, #6f6a80);
  line-height: 1.6; margin-bottom: 16px;
}
.info-card strong { color: var(--vio-deep, #5b21b6); }
.info-icon {
  width: 15px; height: 15px;
  color: var(--vio, #7c3aed);
  flex-shrink: 0;
  margin-top: 2px;
}

.list { display: flex; flex-direction: column; gap: 8px; }
.row {
  display: flex; align-items: center; gap: 14px;
  padding: 12px 16px;
  background: #ffffff;
  border: 1px solid var(--line, #eceaf4);
  border-radius: 12px;
  transition: all 0.2s;
  box-shadow: 0 1px 2px rgba(88,60,160,0.04), 0 2px 8px rgba(88,60,160,0.04);
}
.row:hover { border-color: var(--line-2, #ddd9ee); }

.bank-info { display: flex; align-items: center; gap: 12px; min-width: 180px; }
.bank-logo-wrap {
  width: 40px; height: 40px; border-radius: 10px;
  background: var(--bg-soft, #f9f8fc);
  border: 1px solid var(--line, #eceaf4);
  padding: 5px;
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0; overflow: hidden;
}
.bank-logo-img { width: 100%; height: 100%; object-fit: contain; }
.bank-logo-empty {
  font-size: 14px;
  font-weight: 800;
  color: var(--vio, #7c3aed);
}
.bank-name { font-size: 13px; font-weight: 700; color: var(--txt, #16121f); }
.bank-code {
  font-family: ui-monospace, monospace;
  font-size: 11px; color: var(--dim, #6f6a80); margin-top: 2px;
}

.bank-input {
  flex: 1; padding: 10px 14px;
  background: var(--bg-soft, #f9f8fc);
  border: 1px solid var(--line, #eceaf4);
  border-radius: 10px;
  font-size: 12.5px; color: var(--txt, #16121f);
  font-family: inherit; min-width: 0;
  outline: none;
  transition: border-color 0.18s, box-shadow 0.18s, background 0.18s;
}
.bank-input::placeholder { color: var(--dim, #6f6a80); opacity: 0.55; }
.bank-input:focus {
  border-color: var(--vio, #7c3aed);
  background: #ffffff;
  box-shadow: 0 0 0 4px rgba(124,58,237,0.12);
}

.btn-primary {
  padding: 10px 20px;
  background: var(--grad, linear-gradient(135deg, #7c3aed, #d946ef));
  color: #ffffff;
  border: none; border-radius: 10px;
  font-size: 13px; font-weight: 800;
  cursor: pointer; font-family: inherit;
  box-shadow: 0 8px 24px -8px rgba(124,58,237,0.55);
  transition: all 0.2s;
}
.btn-primary:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 14px 32px -8px rgba(124,58,237,0.65);
}
.btn-primary:disabled { opacity: 0.5; cursor: not-allowed; box-shadow: none; }

.toast {
  position: fixed; bottom: 24px; left: 50%;
  transform: translateX(-50%);
  padding: 12px 20px;
  background: var(--txt, #16121f); color: #ffffff;
  border-radius: 11px; font-size: 13px; font-weight: 700;
  box-shadow: 0 16px 44px -10px rgba(22,18,31,0.4);
  z-index: 850; display: flex; align-items: center; gap: 8px;
}
.toast svg { width: 15px; height: 15px; color: #34d399; }

.toast-enter-active, .toast-leave-active { transition: all 0.3s; }
.toast-enter-from, .toast-leave-to { opacity: 0; transform: translateX(-50%) translateY(10px); }

@media (max-width: 640px) {
  .row { flex-direction: column; align-items: stretch; }
  .bank-info { min-width: 0; }
}
</style>