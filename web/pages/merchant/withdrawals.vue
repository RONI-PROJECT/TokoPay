<template>
  <div class="page">
    <div class="head">
      <div>
        <h1>Tarik Dana</h1>
        <p class="sub">Ajukan penarikan kapan saja</p>
      </div>
      <button class="btn-primary" @click="openModal" :disabled="loading">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" class="btn-icon-svg">
          <line x1="12" y1="5" x2="12" y2="19" stroke-linecap="round"/>
          <line x1="5" y1="12" x2="19" y2="12" stroke-linecap="round"/>
        </svg>
        Ajukan Penarikan
      </button>
    </div>

    <div v-if="loading" class="state">
      <div class="spinner"></div>
      <p>Memuat...</p>
    </div>

    <template v-else>
      <div class="bal-grid">
        <div class="bal">
          <div class="lbl">SALDO TERSEDIA</div>
          <div class="val grad">{{ rupiah(balance?.available ?? 0) }}</div>
        </div>
        <div class="bal">
          <div class="lbl">SEDANG DIPROSES</div>
          <div class="val">{{ rupiah(pendingWd) }}</div>
          <div class="sub2">{{ pendingCount }} penarikan menunggu</div>
        </div>
        <div class="bal">
          <div class="lbl">TOTAL DITERIMA</div>
          <div class="val ok">{{ rupiah(successWd) }}</div>
          <div class="sub2">{{ successCount }} penarikan selesai</div>
        </div>
      </div>

      <div class="info-card">
        <div class="info-icon">i</div>
        <div>
          <strong>Info Penarikan</strong>
          <p>
            Minimum {{ rupiah(wdMin) }} · Biaya {{ wdFeePercent }}% + {{ rupiah(wdFeeFlat) }} ·
            Proses maksimal 24 jam kerja
          </p>
        </div>
      </div>

      <div v-if="items.length > 0" class="stat-row">
        <div class="stat-chip pending">
          <span class="chip-dot"></span>
          <span class="chip-label">Menunggu</span>
          <span class="chip-count">{{ pendingCount }}</span>
        </div>
        <div class="stat-chip done">
          <span class="chip-dot"></span>
          <span class="chip-label">Berhasil</span>
          <span class="chip-count">{{ successCount }}</span>
        </div>
        <div class="stat-chip rejected">
          <span class="chip-dot"></span>
          <span class="chip-label">Ditolak</span>
          <span class="chip-count">{{ rejectedCount }}</span>
        </div>
      </div>

      <div class="card">
        <div class="card-head">
          <h2>Riwayat Penarikan</h2>
          <button class="btn-refresh" @click="load" :disabled="refreshing" title="Refresh">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" :class="{ spinning: refreshing }">
              <polyline points="23 4 23 10 17 10"/>
              <polyline points="1 20 1 14 7 14"/>
              <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"/>
            </svg>
          </button>
        </div>

        <div v-if="items.length === 0" class="empty">
          <div class="empty-icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
              <path d="M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6" stroke-linecap="round"/>
            </svg>
          </div>
          <p>Belum ada penarikan</p>
        </div>

        <div v-else class="trx-table">
          <div class="trx-header">
            <span>ID</span>
            <span>Nominal</span>
            <span>Biaya</span>
            <span>Diterima</span>
            <span>Rekening</span>
            <span>Status</span>
          </div>
          <TransitionGroup name="trx">
            <div v-for="w in items" :key="w.wdrId" class="trx-row">
              <span class="mono">{{ w.wdrId }}</span>
              <span>{{ rupiah(w.amount) }}</span>
              <span class="fee">-{{ rupiah(w.fee) }}</span>
              <span class="recv">{{ rupiah(w.received) }}</span>
              <span class="small">{{ w.bank }} {{ w.account }}</span>
              <span>
                <span class="badge" :class="'badge-' + w.status.toLowerCase()">
                  <svg v-if="w.status === 'PENDING' || w.status === 'APPROVED'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                    <circle cx="12" cy="12" r="10"/>
                    <polyline points="12 6 12 12 16 14"/>
                  </svg>
                  <svg v-else-if="w.status === 'DONE'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">
                    <polyline points="20 6 9 17 4 12"/>
                  </svg>
                  <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                    <line x1="18" y1="6" x2="6" y2="18"/>
                    <line x1="6" y1="6" x2="18" y2="18"/>
                  </svg>
                  {{ statusLabel(w.status) }}
                </span>
              </span>
            </div>
          </TransitionGroup>
        </div>
      </div>
    </template>

    <Teleport to="body">
      <Transition name="modal">
        <div v-if="showModal" class="modal-overlay" @click.self="closeModal">
          <div class="modal">
            <div class="modal-head">
              <div>
                <div class="modal-eyebrow">Konfirmasi</div>
                <h2>Ajukan Penarikan Dana</h2>
              </div>
            </div>
            <div class="modal-body">
              <div class="balance-info">
                <div class="bi-row">
                  <span>Saldo tersedia</span>
                  <strong>{{ rupiah(balance?.available ?? 0) }}</strong>
                </div>
                <div class="bi-hint">
                  Minimum {{ rupiah(wdMin) }} · Biaya {{ wdFeePercent }}% + {{ rupiah(wdFeeFlat) }}
                </div>
              </div>

              <!-- NOMINAL -->
              <div class="form-group">
                <label>Nominal (IDR)</label>
                <input
                  v-model.number="form.amount"
                  type="number"
                  :min="wdMin"
                  :placeholder="String(wdMin)"
                  @input="calcFee"
                />
                <div class="quick-row">
                  <button type="button" class="btn-quick" @click="setAmount(wdMin)">
                    Min ({{ rupiah(wdMin) }})
                  </button>
                  <button
                    type="button"
                    class="btn-quick"
                    @click="setAmount(balance?.available || 0)"
                    :disabled="(balance?.available || 0) < wdMin"
                  >
                    Semua ({{ rupiah(balance?.available || 0) }})
                  </button>
                </div>
              </div>

              <!-- FEE BREAKDOWN -->
              <div v-if="form.amount >= wdMin" class="fee-breakdown">
                <div class="fb-row">
                  <span>Nominal penarikan</span>
                  <strong>{{ rupiah(form.amount) }}</strong>
                </div>
                <div class="fb-row">
                  <span>Biaya admin ({{ wdFeePercent }}% + {{ rupiah(wdFeeFlat) }})</span>
                  <strong class="fee-val">-{{ rupiah(fee) }}</strong>
                </div>
                <div class="fb-row total">
                  <span>Dana diterima</span>
                  <strong>{{ rupiah(received) }}</strong>
                </div>
              </div>

              <!-- REKENING TUJUAN -->
              <div class="form-group">
                <label>Rekening Tujuan</label>

                <!-- Jika sudah ada rekening tersimpan -->
                <div v-if="savedAccount && !editingAccount" class="saved-account">
                  <div class="sa-icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                      <rect x="2" y="7" width="20" height="14" rx="2"/>
                      <path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/>
                    </svg>
                  </div>
                  <div class="sa-info">
                    <div class="sa-bank">{{ savedAccount.bank }}</div>
                    <div class="sa-number">{{ savedAccount.account }}</div>
                  </div>
                  <button type="button" class="sa-edit" @click="editingAccount = true" title="Ganti rekening">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                      <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>
                      <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>
                    </svg>
                  </button>
                </div>

                <!-- Form rekening -->
                <div v-else class="account-form">
                  <!-- Bank picker -->
                  <div class="bank-picker">
                    <button
                      type="button"
                      class="bank-trigger"
                      @click="showBankList = !showBankList"
                      :class="{ active: showBankList }"
                    >
                      <span v-if="form.bank" class="bank-selected">
                        <img
                            v-if="getBankLogo(form.bank, bankLogos)"
                            :src="getBankLogo(form.bank, bankLogos)"
                            :alt="form.bank"
                            class="bank-logo-img"
                            @error="(e) => (e.target).style.display = 'none'"
                          />
                          <span v-else class="bank-logo" :class="'logo-' + form.bank.toLowerCase()">{{ form.bank.slice(0, 3) }}</span>
                        <span class="bank-name">{{ form.bank }}</span>
                      </span>
                      <span v-else class="bank-placeholder">Pilih bank tujuan</span>
                      <svg class="bank-chev" :class="{ open: showBankList }" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4">
                        <polyline points="6 9 12 15 18 9"/>
                      </svg>
                    </button>

                    <Transition name="dropdown">
                      <div v-if="showBankList" class="bank-list">
                        <div class="bank-list-head">
                          <input
                            v-model="bankSearch"
                            type="text"
                            placeholder="Cari bank..."
                            class="bank-search"
                            @click.stop
                          />
                        </div>
                        <div class="bank-list-body">
                          <button
                            v-for="b in filteredBanks"
                            :key="b.code"
                            type="button"
                            class="bank-option"
                            :class="{ selected: form.bank === b.code }"
                            @click="selectBank(b.code)"
                          >
                            <img
                            v-if="getBankLogo(b.code, bankLogos)"
                            :src="getBankLogo(b.code, bankLogos)"
                            :alt="b.code"
                            class="bank-logo-img"
                            @error="(e) => (e.target).style.display = 'none'"
                          />
                          <span v-else class="bank-logo" :class="'logo-' + b.code.toLowerCase()">{{ b.code.slice(0, 3) }}</span>
                            <span class="bank-name-full">{{ b.name }}</span>
                            <span class="bank-code">{{ b.code }}</span>
                            <svg v-if="form.bank === b.code" class="bank-check" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                              <polyline points="20 6 9 17 4 12"/>
                            </svg>
                          </button>
                          <div v-if="filteredBanks.length === 0" class="bank-empty">
                            Bank tidak ditemukan
                          </div>
                        </div>
                      </div>
                    </Transition>
                  </div>

                  <!-- Nomor rekening -->
                  <input
                    v-model="form.account"
                    type="text"
                    inputmode="numeric"
                    placeholder="Nomor rekening (angka saja)"
                    class="account-input"
                    @input="onAccountInput"
                  />

                  <p v-if="accountError" class="field-error">{{ accountError }}</p>
                  <p v-else class="hint">
                    Nomor rekening hanya angka, {{ minAccountLen }}–{{ maxAccountLen }} digit.
                  </p>

                  <div v-if="editingAccount && savedAccount" class="edit-actions">
                    <button type="button" class="btn-ghost-small" @click="cancelEditAccount">
                      Batal
                    </button>
                  </div>
                </div>
              </div>

              <!-- CATATAN -->
              <div class="form-group">
                <label>Catatan</label>
                <input
                  v-model="form.note"
                  placeholder="Ketik catatan (opsional)"
                  autocomplete="off"
                  autocorrect="off"
                  autocapitalize="off"
                  spellcheck="false"
                  name="withdraw_note_field_v2"
                  type="text"
                  readonly
                  @focus="(e) => (e.target).removeAttribute('readonly')"
                />
              </div>

              <!-- SAVE ACCOUNT CHECKBOX -->
              <label v-if="!savedAccount || editingAccount" class="checkbox-row">
                <input type="checkbox" v-model="form.saveAccount" />
                <span>Simpan rekening ini untuk penarikan berikutnya</span>
              </label>

              <div v-if="error" class="err">{{ error }}</div>
              <div v-if="success" class="ok">Penarikan berhasil diajukan. Menunggu persetujuan admin.</div>
            </div>
            <div class="modal-foot">
              <button class="btn-ghost" @click="closeModal" :disabled="loading2">Batal</button>
              <button
                class="btn-primary"
                @click="submit"
                :disabled="loading2 || !form.amount || form.amount < wdMin || !isAccountValid"
              >
                {{ loading2 ? 'Memproses...' : 'Tarik Sekarang' }}
              </button>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import { getBankLogo } from '~/utils/bankLogo'
import { parseBankLogos } from '~/utils/bankLogo'
definePageMeta({ layout: 'dashboard' })

const { wdMin, wdFeePercent, wdFeeFlat, load: loadSettings } = useSiteSettings()

// Bank logos — dari settings, fallback ke clearbit
const bankLogos = computed<Record<string, string>>(() => {
  try {
    const settings = useSiteSettings()
    return parseBankLogos((settings as any).bank_logos?.value)
  } catch {
    return {}
  }
})

// DAFTAR BANK INDONESIA
const BANKS = [
  { code: 'BCA',     name: 'Bank Central Asia (BCA)' },
  { code: 'BNI',     name: 'Bank Negara Indonesia (BNI)' },
  { code: 'BRI',     name: 'Bank Rakyat Indonesia (BRI)' },
  { code: 'MANDIRI', name: 'Bank Mandiri' },
  { code: 'CIMB',    name: 'CIMB Niaga' },
  { code: 'PERMATA', name: 'Bank Permata' },
  { code: 'DANAMON', name: 'Bank Danamon' },
  { code: 'BSI',     name: 'Bank Syariah Indonesia (BSI)' },
  { code: 'BTN',     name: 'Bank Tabungan Negara (BTN)' },
  { code: 'OCBC',    name: 'OCBC NISP' },
  { code: 'MAYBANK', name: 'Maybank Indonesia' },
  { code: 'PANIN',   name: 'Bank Panin' },
  { code: 'MEGA',    name: 'Bank Mega' },
  { code: 'BJB',     name: 'Bank Jabar Banten (BJB)' },
  { code: 'DKI',     name: 'Bank DKI' },
  { code: 'JAGO',    name: 'Bank Jago' },
  { code: 'SEABANK', name: 'SeaBank' },
  { code: 'NEO',     name: 'Bank Neo Commerce' },
  { code: 'BLU',     name: 'Blu by BCA Digital' },
  { code: 'JENIUS',  name: 'Jenius (BTPN)' },
  { code: 'GOPAY',   name: 'GoPay' },
  { code: 'OVO',     name: 'OVO' },
  { code: 'DANA',    name: 'DANA' },
  { code: 'SHOPEEPAY', name: 'ShopeePay' },
  { code: 'LINKAJA', name: 'LinkAja' },
]

const balance = ref<any>(null)
const items = ref<any[]>([])
const showModal = ref(false)
const loading = ref(true)
const loading2 = ref(false)
const refreshing = ref(false)
const error = ref('')
const success = ref(false)
const fee = ref(0)
const received = ref(0)

// State rekening
const showBankList = ref(false)
const bankSearch = ref('')
const savedAccount = ref<{ bank: string, account: string } | null>(null)
const editingAccount = ref(false)
const accountError = ref('')
const minAccountLen = 8
const maxAccountLen = 20

const form = reactive({
  amount: 0,
  bank: '',
  account: '',
  note: '',
  saveAccount: true,
})

let pollInterval: any = null

const pendingWd = computed(() =>
  items.value.filter(w => w.status === 'PENDING' || w.status === 'APPROVED')
    .reduce((s, w) => s + Number(w.amount), 0)
)
const successWd = computed(() =>
  items.value.filter(w => w.status === 'DONE').reduce((s, w) => s + Number(w.received), 0)
)
const pendingCount = computed(() =>
  items.value.filter(w => w.status === 'PENDING' || w.status === 'APPROVED').length
)
const successCount = computed(() => items.value.filter(w => w.status === 'DONE').length)
const rejectedCount = computed(() => items.value.filter(w => w.status === 'REJECTED').length)

const filteredBanks = computed(() => {
  const q = bankSearch.value.toLowerCase().trim()
  if (!q) return BANKS
  return BANKS.filter(b =>
    b.code.toLowerCase().includes(q) || b.name.toLowerCase().includes(q)
  )
})

const isAccountValid = computed(() => {
  if (!form.bank) return false
  const num = form.account.trim()
  if (!num) return false
  if (!/^\d+$/.test(num)) return false
  if (num.length < minAccountLen || num.length > maxAccountLen) return false
  return true
})

async function load(silent = false) {
  if (!silent) refreshing.value = true
  try {
    const [b, w]: any = await Promise.all([
      $fetch('/api/user/balance', { credentials: 'include' }).catch(() => ({ data: null })),
      $fetch('/api/user/withdrawals', { credentials: 'include' }).catch(() => ({ data: [] })),
    ])
    if (b?.data) balance.value = b.data
    items.value = w.data || []
  } catch {}
  finally { refreshing.value = false }
}

function loadSavedAccount() {
  if (typeof window === 'undefined') return
  try {
    const raw = localStorage.getItem('ronpay_withdraw_account')
    if (raw) savedAccount.value = JSON.parse(raw)
  } catch {}
}

function persistAccount() {
  if (typeof window === 'undefined') return
  if (form.saveAccount && form.bank && form.account) {
    savedAccount.value = { bank: form.bank, account: form.account.trim() }
    localStorage.setItem('ronpay_withdraw_account', JSON.stringify(savedAccount.value))
  }
}

onMounted(() => {
  loadSettings()
  loadSavedAccount()
  load().finally(() => { loading.value = false })
  pollInterval = setInterval(() => {
    load(true)
    loadSettings()
  }, 8000)
})

onBeforeUnmount(() => {
  if (pollInterval) clearInterval(pollInterval)
})

function openModal() {
  form.amount = 0
  form.note = ''
  form.saveAccount = true
  fee.value = 0
  received.value = 0
  error.value = ''
  success.value = false
  editingAccount.value = !savedAccount.value
  accountError.value = ''
  showBankList.value = false
  bankSearch.value = ''

  if (savedAccount.value) {
    form.bank = savedAccount.value.bank
    form.account = savedAccount.value.account
  } else {
    form.bank = ''
    form.account = ''
  }

  showModal.value = true
}

function closeModal() {
  showModal.value = false
  showBankList.value = false
}

function selectBank(code: string) {
  form.bank = code
  showBankList.value = false
  bankSearch.value = ''
  validateAccount()
}

function onAccountInput(e: Event) {
  const input = e.target as HTMLInputElement
  input.value = input.value.replace(/\D/g, '')
  form.account = input.value
  validateAccount()
}

function validateAccount() {
  const num = form.account.trim()
  if (!num) { accountError.value = ''; return }
  if (!/^\d+$/.test(num)) {
    accountError.value = 'Nomor rekening hanya boleh angka'
    return
  }
  if (num.length < minAccountLen) {
    accountError.value = `Nomor rekening minimal ${minAccountLen} digit`
    return
  }
  if (num.length > maxAccountLen) {
    accountError.value = `Nomor rekening maksimal ${maxAccountLen} digit`
    return
  }
  accountError.value = ''
}

function cancelEditAccount() {
  editingAccount.value = false
  if (savedAccount.value) {
    form.bank = savedAccount.value.bank
    form.account = savedAccount.value.account
  }
  accountError.value = ''
}

function setAmount(val: number) {
  form.amount = Number(val) || 0
  calcFee()
}

function calcFee() {
  if (form.amount >= wdMin.value) {
    fee.value = Math.round(form.amount * (wdFeePercent.value / 100) + wdFeeFlat.value)
    received.value = form.amount - fee.value
  } else {
    fee.value = 0
    received.value = 0
  }
}

async function submit() {
  error.value = ''
  success.value = false

  if (!isAccountValid.value) {
    error.value = 'Rekening tujuan belum lengkap atau tidak valid'
    return
  }

  loading2.value = true
  try {
    await $fetch('/api/user/withdrawals', {
      method: 'POST',
      body: {
        amount: form.amount,
        bank: form.bank,
        account: form.account.trim(),
        note: form.note,
      },
      credentials: 'include',
    })
    persistAccount()
    success.value = true
    await load()
    setTimeout(() => closeModal(), 1200)
  } catch (e: any) {
    error.value = e?.data?.error || e.message
  } finally {
    loading2.value = false
  }
}

function rupiah(n: number) { return 'Rp ' + Number(n || 0).toLocaleString('id-ID') }
function statusLabel(s: string) {
  if (s === 'PENDING') return 'Menunggu'
  if (s === 'APPROVED') return 'Diproses'
  if (s === 'DONE') return 'Berhasil'
  if (s === 'REJECTED') return 'Ditolak'
  return s
}
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
  display: flex; justify-content: space-between; align-items: flex-start;
  margin-bottom: 24px; gap: 12px; flex-wrap: wrap;
}
h1 { font-size: 22px; font-weight: 800; letter-spacing: -0.02em; color: var(--txt, #16121f); }
.sub { font-size: 13px; color: var(--dim, #6f6a80); margin-top: 5px; }

.btn-primary {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 11px 20px;
  background: var(--grad, linear-gradient(135deg, #7c3aed, #d946ef));
  color: #ffffff;
  border: none;
  border-radius: 11px;
  font-size: 13px;
  font-weight: 800;
  cursor: pointer;
  transition: all 0.2s;
  font-family: inherit;
  box-shadow: 0 8px 24px -8px rgba(124,58,237,0.55);
  white-space: nowrap;
}
.btn-primary:hover:not(:disabled) { transform: translateY(-1px); box-shadow: 0 14px 32px -8px rgba(124,58,237,0.65); }
.btn-primary:disabled { opacity: 0.4; cursor: not-allowed; transform: none; box-shadow: none; }
.btn-icon-svg { width: 14px; height: 14px; }

.btn-ghost {
  padding: 11px 20px;
  background: #ffffff;
  border: 1px solid var(--line-2, #ddd9ee);
  border-radius: 11px;
  font-size: 13px;
  font-weight: 650;
  color: var(--dim, #6f6a80);
  cursor: pointer;
  font-family: inherit;
  transition: all 0.15s;
}
.btn-ghost:hover:not(:disabled) { border-color: var(--line, #eceaf4); color: var(--txt, #16121f); }
.btn-ghost:disabled { opacity: 0.4; cursor: not-allowed; }

.btn-ghost-small {
  padding: 7px 14px;
  background: #ffffff;
  border: 1px solid var(--line-2, #ddd9ee);
  border-radius: 8px;
  font-size: 12px;
  font-weight: 650;
  color: var(--dim, #6f6a80);
  cursor: pointer;
  font-family: inherit;
  transition: all 0.15s;
}
.btn-ghost-small:hover { border-color: var(--line, #eceaf4); color: var(--txt, #16121f); }

.state { text-align: center; padding: 60px 20px; color: var(--dim, #6f6a80); font-size: 13.5px; }
.spinner {
  width: 28px; height: 28px;
  border: 3px solid var(--line, #eceaf4);
  border-top-color: var(--vio, #7c3aed);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  margin: 0 auto 14px;
}
@keyframes spin { to { transform: rotate(360deg); } }

/* ===== BALANCE GRID ===== */
.bal-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; }
@media (max-width: 768px) { .bal-grid { grid-template-columns: 1fr; } }

.bal {
  padding: 18px;
  border-radius: 16px;
  border: 1px solid var(--line, #eceaf4);
  background: #ffffff;
  position: relative;
  overflow: hidden;
  box-shadow: 0 1px 2px rgba(88,60,160,0.04), 0 4px 14px rgba(88,60,160,0.05);
}
.bal::before {
  content: '';
  position: absolute;
  top: 0; left: 0; right: 0; height: 3px;
  background: var(--grad, linear-gradient(135deg, #7c3aed, #d946ef));
  opacity: 0;
  transition: opacity 0.2s;
}
.bal:hover::before { opacity: 1; }
.lbl {
  font-size: 10px; font-weight: 800;
  color: var(--dim, #6f6a80);
  letter-spacing: 0.12em; margin-bottom: 9px;
  position: relative; z-index: 1;
}
.val {
  font-size: 22px; font-weight: 800; color: var(--txt, #16121f);
  letter-spacing: -0.025em; font-variant-numeric: tabular-nums;
  position: relative; z-index: 1;
  word-break: break-word;
}
.val.grad {
  background: var(--grad, linear-gradient(135deg, #7c3aed, #d946ef));
  -webkit-background-clip: text; background-clip: text;
  -webkit-text-fill-color: transparent;
}
.val.ok { color: #059669; }
.sub2 { font-size: 11.5px; color: var(--dim, #6f6a80); margin-top: 6px; position: relative; z-index: 1; }

.info-card {
  display: flex; gap: 12px;
  padding: 16px;
  background: rgba(124,58,237,0.04);
  border: 1px solid rgba(124,58,237,0.15);
  border-radius: 14px;
  margin-top: 16px;
}
.info-icon {
  width: 24px; height: 24px; border-radius: 50%;
  background: rgba(124,58,237,0.08);
  border: 1px solid rgba(124,58,237,0.18);
  color: var(--vio, #7c3aed);
  display: flex; align-items: center; justify-content: center;
  font-size: 12px; font-weight: 800;
  flex-shrink: 0;
}
.info-card strong {
  display: block; font-size: 13px; color: var(--txt, #16121f);
  margin-bottom: 3px;
}
.info-card p {
  font-size: 12px; color: var(--dim, #6f6a80);
  margin: 0; line-height: 1.55;
}

/* ===== STAT CHIPS ===== */
.stat-row { display: flex; gap: 8px; margin-top: 16px; flex-wrap: wrap; }
.stat-chip {
  display: inline-flex; align-items: center; gap: 8px;
  padding: 8px 14px;
  border-radius: 999px;
  font-size: 12px; font-weight: 700;
  white-space: nowrap;
}
.stat-chip.pending { background: rgba(245,158,11,0.09); border: 1px solid rgba(245,158,11,0.25); color: #d97706; }
.stat-chip.done { background: rgba(16,185,129,0.09); border: 1px solid rgba(16,185,129,0.25); color: #059669; }
.stat-chip.rejected { background: rgba(225,29,72,0.06); border: 1px solid rgba(225,29,72,0.18); color: var(--bad, #e11d48); }
.chip-dot {
  width: 6px; height: 6px; border-radius: 50%;
  background: currentColor;
  flex-shrink: 0;
}
.chip-count {
  font-variant-numeric: tabular-nums;
  font-weight: 800;
  padding-left: 8px;
  border-left: 1px solid rgba(0,0,0,0.1);
  margin-left: 2px;
}

/* ===== CARD / TABLE ===== */
.card {
  background: #ffffff;
  border: 1px solid var(--line, #eceaf4);
  border-radius: 16px;
  padding: 20px;
  margin-top: 16px;
  box-shadow: 0 1px 2px rgba(88,60,160,0.04), 0 4px 14px rgba(88,60,160,0.05);
}
.card-head {
  margin-bottom: 16px;
  display: flex; justify-content: space-between; align-items: center;
  gap: 12px;
}
.card-head h2 { font-size: 15px; font-weight: 750; color: var(--txt, #16121f); }

.btn-refresh {
  width: 34px; height: 34px;
  border-radius: 10px;
  background: #ffffff;
  border: 1px solid var(--line, #eceaf4);
  color: var(--dim, #6f6a80);
  display: flex; align-items: center; justify-content: center;
  cursor: pointer;
  transition: all 0.15s;
}
.btn-refresh:hover:not(:disabled) { border-color: var(--vio-2, #a78bfa); color: var(--vio, #7c3aed); }
.btn-refresh:disabled { opacity: 0.6; cursor: not-allowed; }
.btn-refresh svg { width: 15px; height: 15px; }
.btn-refresh svg.spinning { animation: spin 0.8s linear infinite; }

.empty { text-align: center; padding: 36px 20px; color: var(--dim, #6f6a80); font-size: 13px; }
.empty-icon {
  width: 56px; height: 56px;
  border-radius: 14px;
  background: var(--bg-soft, #f9f8fc);
  border: 1px solid var(--line, #eceaf4);
  display: flex; align-items: center; justify-content: center;
  margin: 0 auto 14px;
  color: var(--vio, #7c3aed);
}
.empty-icon svg { width: 24px; height: 24px; }

.trx-table { width: 100%; }
.trx-header, .trx-row {
  display: grid;
  grid-template-columns: 1.2fr 1fr 1fr 1fr 1.2fr 1fr;
  gap: 8px; padding: 12px 8px; align-items: center;
  font-size: 12.5px;
}
.trx-header {
  font-size: 10px; font-weight: 800;
  color: var(--dim, #6f6a80);
  text-transform: uppercase; letter-spacing: 0.1em;
  border-bottom: 1px solid var(--line, #eceaf4);
}
.trx-row {
  border-bottom: 1px solid var(--line, #eceaf4);
  color: var(--txt, #16121f);
  font-variant-numeric: tabular-nums;
}
.trx-row:last-child { border-bottom: none; }
.trx-row:hover { background: var(--bg-soft, #f9f8fc); }
.mono {
  font-family: ui-monospace, monospace;
  font-size: 11.5px; color: var(--vio-deep, #5b21b6);
  font-weight: 700; letter-spacing: 0.02em;
}
.small { font-size: 11.5px; color: var(--dim, #6f6a80); }
.fee { color: #d97706; font-weight: 650; }
.recv { color: #059669; font-weight: 750; }

@media (max-width: 768px) {
  .trx-header, .trx-row { grid-template-columns: 1fr 1fr; gap: 6px; }
  .trx-header span:nth-child(n+3), .trx-row span:nth-child(n+3) { display: none; }
}

/* ===== BADGES ===== */
.badge {
  display: inline-flex; align-items: center; gap: 5px;
  padding: 4px 10px;
  border-radius: 999px;
  font-size: 10px; font-weight: 800;
  letter-spacing: 0.04em; text-transform: uppercase;
  white-space: nowrap;
  border: 1px solid;
}
.badge svg { width: 11px; height: 11px; flex-shrink: 0; }
.badge-pending {
  background: rgba(245,158,11,0.09);
  border-color: rgba(245,158,11,0.25);
  color: #d97706;
}
.badge-pending svg { animation: pulse 2s infinite; }
.badge-approved {
  background: rgba(124,58,237,0.07);
  border-color: rgba(124,58,237,0.22);
  color: var(--vio, #7c3aed);
}
.badge-approved svg { animation: pulse 2s infinite; }
.badge-done {
  background: rgba(16,185,129,0.09);
  border-color: rgba(16,185,129,0.25);
  color: #059669;
}
.badge-rejected {
  background: rgba(225,29,72,0.06);
  border-color: rgba(225,29,72,0.18);
  color: var(--bad, #e11d48);
}
@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.4; }
}

.trx-move { transition: transform 0.4s cubic-bezier(0.22, 1, 0.36, 1); }
.trx-enter-active { transition: all 0.4s ease; }
.trx-leave-active { transition: all 0.3s ease; position: absolute; }
.trx-enter-from { opacity: 0; transform: translateY(-10px); }
.trx-leave-to { opacity: 0; transform: translateY(10px); }

/* ===== MODAL ===== */
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
  border-radius: 20px;
  width: 100%; max-width: 500px;
  max-height: 90vh;
  overflow-y: auto;
  color: var(--txt, #16121f);
  position: relative;
  box-shadow: 0 30px 80px -20px rgba(88,60,160,0.35);
}
.modal-head {
  padding: 22px 24px 18px;
  border-bottom: 1px solid var(--line, #eceaf4);
}
.modal-eyebrow {
  font-size: 10.5px; font-weight: 800;
  letter-spacing: 0.14em; text-transform: uppercase;
  color: var(--vio, #7c3aed);
  margin-bottom: 8px;
}
.modal-head h2 { font-size: 17px; font-weight: 800; color: var(--txt, #16121f); letter-spacing: -0.02em; }
.modal-body { padding: 22px 24px; }
.modal-foot {
  padding: 16px 24px 24px;
  border-top: 1px solid var(--line, #eceaf4);
  display: flex; justify-content: flex-end;
  gap: 8px;
  position: sticky;
  bottom: 0;
  background: #ffffff;
  z-index: 10;
}

.balance-info {
  background: var(--bg-soft, #f9f8fc);
  border: 1px solid var(--line, #eceaf4);
  border-radius: 14px;
  padding: 14px 16px;
  margin-bottom: 18px;
}
.bi-row {
  display: flex; justify-content: space-between; align-items: center;
  font-size: 13px; margin-bottom: 6px;
  color: var(--dim, #6f6a80);
}
.bi-row strong {
  font-size: 16px; color: var(--vio-deep, #5b21b6);
  font-variant-numeric: tabular-nums;
  font-weight: 800;
}
.bi-hint { font-size: 11.5px; color: var(--dim, #6f6a80); line-height: 1.5; }

.form-group { margin-bottom: 16px; }
.form-group label {
  display: block; font-size: 12px; font-weight: 700;
  color: var(--txt, #16121f); margin-bottom: 8px;
}
.form-group input[type="text"],
.form-group input[type="number"] {
  width: 100%;
  padding: 12px 14px;
  border: 1px solid var(--line-2, #ddd9ee);
  border-radius: 11px;
  font-size: 14px;
  background: #ffffff;
  color: var(--txt, #16121f);
  outline: none;
  transition: all 0.18s;
  font-family: inherit;
}
.form-group input::placeholder { color: var(--dim, #6f6a80); opacity: 0.55; }
.form-group input:focus {
  border-color: var(--vio, #7c3aed);
  box-shadow: 0 0 0 4px rgba(124,58,237,0.12);
}
.hint { font-size: 11.5px; color: var(--dim, #6f6a80); margin-top: 8px; line-height: 1.5; }
.field-error {
  font-size: 11.5px;
  color: var(--bad, #e11d48);
  margin-top: 8px;
  line-height: 1.5;
  padding: 6px 10px;
  background: rgba(225,29,72,0.05);
  border: 1px solid rgba(225,29,72,0.18);
  border-radius: 8px;
  font-weight: 600;
}

/* ===== SAVED ACCOUNT ===== */
.saved-account {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 14px;
  background: var(--bg-soft, #f9f8fc);
  border: 1px solid var(--line, #eceaf4);
  border-radius: 11px;
}
.sa-icon {
  width: 36px; height: 36px;
  border-radius: 10px;
  background: rgba(124,58,237,0.07);
  border: 1px solid rgba(124,58,237,0.15);
  color: var(--vio, #7c3aed);
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
}
.sa-icon svg { width: 16px; height: 16px; }
.sa-info { flex: 1; min-width: 0; }
.sa-bank { font-size: 13px; font-weight: 750; color: var(--txt, #16121f); }
.sa-number {
  font-family: ui-monospace, monospace;
  font-size: 12.5px;
  color: var(--dim, #6f6a80);
  margin-top: 2px;
  letter-spacing: 0.02em;
}
.sa-edit {
  width: 32px; height: 32px;
  border-radius: 8px;
  background: #ffffff;
  border: 1px solid var(--line, #eceaf4);
  color: var(--dim, #6f6a80);
  display: flex; align-items: center; justify-content: center;
  cursor: pointer;
  flex-shrink: 0;
  transition: all 0.15s;
}
.sa-edit:hover {
  border-color: var(--vio-2, #a78bfa);
  color: var(--vio, #7c3aed);
}
.sa-edit svg { width: 14px; height: 14px; }

/* ===== ACCOUNT FORM ===== */
.account-form { display: flex; flex-direction: column; gap: 10px; }

.bank-picker { position: relative; }
.bank-trigger {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  padding: 12px 14px;
  background: #ffffff;
  border: 1px solid var(--line-2, #ddd9ee);
  border-radius: 11px;
  font-size: 14px;
  color: var(--txt, #16121f);
  cursor: pointer;
  font-family: inherit;
  transition: all 0.18s;
  text-align: left;
}
.bank-trigger:hover { border-color: var(--line, #eceaf4); }
.bank-trigger.active {
  border-color: var(--vio, #7c3aed);
  box-shadow: 0 0 0 4px rgba(124,58,237,0.12);
}
.bank-selected {
  display: flex; align-items: center; gap: 10px;
  min-width: 0;
}
.bank-placeholder { color: var(--dim, #6f6a80); opacity: 0.7; }

.bank-logo {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 36px; height: 26px;
  border-radius: 6px;
  background: var(--bg-soft, #f9f8fc);
  border: 1px solid var(--line, #eceaf4);
  font-size: 9px;
  font-weight: 800;
  color: var(--vio, #7c3aed);
  letter-spacing: 0.02em;
  flex-shrink: 0;
  font-family: ui-monospace, monospace;
}
.bank-logo-img {
  width: 36px;
  height: 26px;
  object-fit: contain;
  background: #ffffff;
  border: 1px solid var(--line, #eceaf4);
  border-radius: 6px;
  padding: 3px;
  flex-shrink: 0;
}

.bank-name { font-weight: 700; color: var(--txt, #16121f); }
.bank-name-full {
  flex: 1;
  font-weight: 600;
  color: var(--txt, #16121f);
  min-width: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.bank-chev {
  width: 16px; height: 16px;
  color: var(--dim, #6f6a80);
  flex-shrink: 0;
  transition: transform 0.28s cubic-bezier(0.22,1,0.36,1);
}
.bank-chev.open { transform: rotate(180deg); color: var(--vio, #7c3aed); }

.bank-list {
  position: absolute;
  top: calc(100% + 6px);
  left: 0; right: 0;
  background: #ffffff;
  border: 1px solid var(--line, #eceaf4);
  border-radius: 12px;
  z-index: 100;
  overflow: hidden;
  box-shadow: 0 20px 50px -12px rgba(88,60,160,0.25);
  max-height: 320px;
  display: flex;
  flex-direction: column;
}
.bank-list-head {
  padding: 10px;
  border-bottom: 1px solid var(--line, #eceaf4);
  flex-shrink: 0;
}
.bank-search {
  width: 100%;
  padding: 9px 12px;
  background: var(--bg-soft, #f9f8fc);
  border: 1px solid var(--line, #eceaf4);
  border-radius: 8px;
  font-size: 13px;
  color: var(--txt, #16121f);
  font-family: inherit;
  outline: none;
  transition: all 0.18s;
}
.bank-search::placeholder { color: var(--dim, #6f6a80); opacity: 0.6; }
.bank-search:focus { border-color: var(--vio, #7c3aed); box-shadow: 0 0 0 3px rgba(124,58,237,0.1); }

.bank-list-body {
  overflow-y: auto;
  padding: 6px;
  flex: 1;
  scrollbar-width: thin;
  scrollbar-color: var(--line-2, #ddd9ee) transparent;
}
.bank-list-body::-webkit-scrollbar { width: 6px; }
.bank-list-body::-webkit-scrollbar-thumb {
  background: var(--line-2, #ddd9ee);
  border-radius: 3px;
}
.bank-option {
  width: 100%;
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 12px;
  background: transparent;
  border: none;
  border-radius: 8px;
  color: var(--txt, #16121f);
  font-size: 13px;
  cursor: pointer;
  font-family: inherit;
  text-align: left;
  transition: background 0.15s;
}
.bank-option:hover { background: var(--bg-soft, #f9f8fc); }
.bank-option.selected { background: rgba(124,58,237,0.07); color: var(--vio-deep, #5b21b6); }
.bank-code {
  font-family: ui-monospace, monospace;
  font-size: 11px;
  color: var(--dim, #6f6a80);
  flex-shrink: 0;
}
.bank-check {
  width: 14px; height: 14px;
  color: var(--vio, #7c3aed);
  flex-shrink: 0;
}
.bank-empty {
  padding: 20px;
  text-align: center;
  color: var(--dim, #6f6a80);
  font-size: 12.5px;
}

.account-input {
  width: 100%;
  padding: 12px 14px;
  background: #ffffff;
  border: 1px solid var(--line-2, #ddd9ee);
  border-radius: 11px;
  font-size: 14px;
  color: var(--txt, #16121f);
  font-family: ui-monospace, monospace;
  letter-spacing: 0.04em;
  outline: none;
  transition: all 0.18s;
}
.account-input::placeholder { color: var(--dim, #6f6a80); opacity: 0.6; font-family: inherit; letter-spacing: 0; }
.account-input:focus {
  border-color: var(--vio, #7c3aed);
  box-shadow: 0 0 0 4px rgba(124,58,237,0.12);
}

.edit-actions { display: flex; justify-content: flex-end; }

.checkbox-row {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 12px;
  background: var(--bg-soft, #f9f8fc);
  border: 1px solid var(--line, #eceaf4);
  border-radius: 10px;
  cursor: pointer;
  font-size: 12.5px;
  color: var(--dim, #6f6a80);
  margin-bottom: 12px;
}
.checkbox-row input[type="checkbox"] {
  width: 16px; height: 16px;
  accent-color: var(--vio, #7c3aed);
  cursor: pointer;
  flex-shrink: 0;
}
.checkbox-row span { line-height: 1.4; }

.quick-row {
  display: flex;
  gap: 6px;
  margin-top: 8px;
}
.btn-quick {
  flex: 1;
  padding: 8px 10px;
  background: #ffffff;
  border: 1px solid var(--line, #eceaf4);
  border-radius: 9px;
  font-size: 11.5px;
  font-weight: 650;
  color: var(--dim, #6f6a80);
  cursor: pointer;
  font-family: inherit;
  transition: all 0.15s;
}
.btn-quick:hover:not(:disabled) {
  border-color: var(--vio-2, #a78bfa);
  color: var(--vio, #7c3aed);
}
.btn-quick:disabled { opacity: 0.4; cursor: not-allowed; }

.fee-breakdown {
  background: rgba(124,58,237,0.04);
  border: 1px solid rgba(124,58,237,0.15);
  border-radius: 12px;
  padding: 14px 16px;
  margin: 12px 0 16px;
}
.fb-row {
  display: flex; justify-content: space-between; align-items: center;
  padding: 5px 0; font-size: 13px; color: var(--dim, #6f6a80);
  gap: 12px;
}
.fb-row strong { color: var(--txt, #16121f); font-variant-numeric: tabular-nums; font-weight: 750; }
.fb-row strong.fee-val { color: #d97706; font-weight: 700; }
.fb-row.total {
  border-top: 1px solid rgba(124,58,237,0.15);
  margin-top: 8px; padding-top: 11px;
  font-size: 13.5px;
  color: var(--txt, #16121f);
}
.fb-row.total strong { font-size: 16px; color: var(--vio-deep, #5b21b6); font-weight: 800; }

.err {
  background: rgba(225,29,72,0.05);
  color: var(--bad, #e11d48);
  padding: 12px 14px;
  border-radius: 10px;
  font-size: 12.5px;
  margin-top: 12px;
  border: 1px solid rgba(225,29,72,0.18);
  line-height: 1.5;
  font-weight: 600;
}
.ok {
  background: rgba(16,185,129,0.07);
  color: #059669;
  padding: 12px 14px;
  border-radius: 10px;
  font-size: 12.5px;
  margin-top: 12px;
  border: 1px solid rgba(16,185,129,0.25);
  line-height: 1.5;
  font-weight: 600;
}

.modal-enter-active, .modal-leave-active { transition: opacity 0.22s ease; }
.modal-enter-active .modal, .modal-leave-active .modal {
  transition: transform 0.22s cubic-bezier(0.22,1,0.36,1), opacity 0.22s ease;
}
.modal-enter-from, .modal-leave-to { opacity: 0; }
.modal-enter-from .modal, .modal-leave-to .modal {
  transform: scale(0.96) translateY(8px);
  opacity: 0;
}

.dropdown-enter-active, .dropdown-leave-active {
  transition: opacity 0.18s ease, transform 0.18s ease;
}
.dropdown-enter-from, .dropdown-leave-to {
  opacity: 0;
  transform: translateY(-6px);
}

@media (max-width: 640px) {
  .page { padding-bottom: 40px; }
  h1 { font-size: 20px; }
  .modal { border-radius: 16px; max-width: 100%; }
  .modal-head { padding: 18px 20px 16px; }
  .modal-body { padding: 18px 20px; }
  .modal-foot {
    padding: 14px 20px calc(14px + env(safe-area-inset-bottom, 0px));
    flex-direction: column-reverse;
  }
  .modal-foot button {
    width: 100%;
    justify-content: center;
  }
  .bank-list { max-height: 240px; }
  .bank-logo { width: 32px; height: 22px; font-size: 8.5px; }
}
</style>