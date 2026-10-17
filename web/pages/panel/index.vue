<template>
  <div class="page">
    <div v-if="checking || !isAdmin" class="state">
      <div class="spinner"></div>
      <p>{{ checking ? 'Memeriksa akses...' : 'Mengalihkan...' }}</p>
    </div>

    <template v-else>
      <!-- HEADER -->
      <div class="welcome">
        <div class="welcome-text">
          <div class="eyebrow">
            <span class="eyebrow-dot"></span>
            Panel Admin
          </div>
          <h1>Halo, {{ adminName }}</h1>
          <p>{{ todayLabel }}</p>
        </div>
        <button class="refresh-btn" @click="refresh" :disabled="refreshing">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" :class="{ spinning: refreshing }">
            <polyline points="23 4 23 10 17 10"/>
            <polyline points="1 20 1 14 7 14"/>
            <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"/>
          </svg>
          <span>{{ refreshing ? 'Memuat...' : 'Refresh' }}</span>
        </button>
      </div>

      <!-- STATS -->
      <div class="stats-grid">
        <div class="stat-card">
          <div class="stat-head">
            <div class="stat-label">Total Transaksi</div>
            <div class="stat-icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                <polyline points="14 2 14 8 20 8"/>
              </svg>
            </div>
          </div>
          <div class="stat-value">{{ stats?.transactions?.total || 0 }}</div>
        </div>

        <div class="stat-card">
          <div class="stat-head">
            <div class="stat-label">Pembayaran Sukses</div>
            <div class="stat-icon stat-icon--ok">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4">
                <polyline points="20 6 9 17 4 12"/>
              </svg>
            </div>
          </div>
          <div class="stat-value">{{ stats?.transactions?.paid || 0 }}</div>
        </div>

        <div class="stat-card">
          <div class="stat-head">
            <div class="stat-label">WD Pending</div>
            <div class="stat-icon stat-icon--warn">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="12" cy="12" r="10"/>
                <polyline points="12 6 12 12 16 14"/>
              </svg>
            </div>
          </div>
          <div class="stat-value">{{ stats?.withdrawals?.pendingCount || 0 }}</div>
        </div>

        <div class="stat-card">
          <div class="stat-head">
            <div class="stat-label">Total Users</div>
            <div class="stat-icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                <circle cx="12" cy="7" r="4"/>
              </svg>
            </div>
          </div>
          <div class="stat-value">{{ stats?.users?.total || 0 }}</div>
        </div>
      </div>

      <!-- MONITORING -->
      <div class="card">
        <div class="card-head">
          <div>
            <h2>Monitoring</h2>
            <span class="card-sub">Perangkat & koneksi</span>
          </div>
          <div class="live-indicator">
            <span class="live-dot"></span>
            Live
          </div>
        </div>

        <div class="monitor-grid">
          <div class="monitor-item">
            <div class="mi-label">CPU Cores</div>
            <div class="mi-value">{{ monitor.cpuCores || '—' }}</div>
          </div>
          <div class="monitor-item">
            <div class="mi-label">RAM Perangkat</div>
            <div class="mi-value">{{ monitor.deviceRam }}</div>
          </div>
          <div class="monitor-item">
            <div class="mi-label">Platform</div>
            <div class="mi-value">{{ monitor.platform }}</div>
          </div>
          <div class="monitor-item">
            <div class="mi-label">Resolusi</div>
            <div class="mi-value">{{ monitor.screen }}</div>
          </div>
        </div>

        <div class="progress-wrap">
          <div class="progress-head">
            <span class="mi-label">Memori JS Heap</span>
            <span class="mi-value-sm">{{ monitor.memUsed }} / {{ monitor.memTotal }}</span>
          </div>
          <div class="progress-bar">
            <div class="progress-fill" :style="{ width: monitor.memPercent + '%' }"></div>
          </div>
          <div class="progress-foot">{{ monitor.memPercent }}% terpakai</div>
        </div>

        <div class="monitor-foot">
          <div class="mf-item">
            <span class="mf-dot" :class="{ offline: !monitor.online }"></span>
            <span>Latency: {{ monitor.latency }}</span>
          </div>
          <div class="mf-item">
            <span class="mf-dot"></span>
            <span>Uptime sesi: {{ monitor.sessionTime }}</span>
          </div>
          <div class="mf-item">
            <span class="mf-dot" :class="{ offline: !monitor.online }"></span>
            <span>Status: {{ monitor.online ? 'Online' : 'Offline' }}</span>
          </div>
        </div>
      </div>

      <!-- QUICK LINKS -->
      <div class="card">
        <div class="card-head">
          <div>
            <h2>Aksi Cepat</h2>
            <span class="card-sub">Shortcut navigasi</span>
          </div>
        </div>
        <div class="quick-links">
          <NuxtLink to="/panel/withdrawals" class="quick-link">
            <div class="ql-icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6" stroke-linecap="round"/>
              </svg>
            </div>
            <div class="ql-body">
              <div class="ql-title">Kelola Tarik Dana</div>
              <div class="ql-desc">Approve / reject permintaan penarikan</div>
            </div>
            <svg class="ql-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <polyline points="9 18 15 12 9 6"/>
            </svg>
          </NuxtLink>

          <NuxtLink to="/panel/transactions" class="quick-link">
            <div class="ql-icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                <polyline points="14 2 14 8 20 8"/>
                <line x1="16" y1="13" x2="8" y2="13"/>
                <line x1="16" y1="17" x2="8" y2="17"/>
              </svg>
            </div>
            <div class="ql-body">
              <div class="ql-title">Semua Transaksi</div>
              <div class="ql-desc">Lihat dan filter transaksi</div>
            </div>
            <svg class="ql-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <polyline points="9 18 15 12 9 6"/>
            </svg>
          </NuxtLink>

          <NuxtLink to="/panel/users" class="quick-link">
            <div class="ql-icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                <circle cx="9" cy="7" r="4"/>
                <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
                <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
              </svg>
            </div>
            <div class="ql-body">
              <div class="ql-title">Kelola Users</div>
              <div class="ql-desc">Ban, unban, set admin</div>
            </div>
            <svg class="ql-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <polyline points="9 18 15 12 9 6"/>
            </svg>
          </NuxtLink>

          <NuxtLink to="/panel/settings" class="quick-link">
            <div class="ql-icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="12" cy="12" r="3"/>
                <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/>
              </svg>
            </div>
            <div class="ql-body">
              <div class="ql-title">Pengaturan</div>
              <div class="ql-desc">Maintenance mode, dll</div>
            </div>
            <svg class="ql-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <polyline points="9 18 15 12 9 6"/>
            </svg>
          </NuxtLink>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'panel' })

const checking = ref(true)
const refreshing = ref(false)
const isAdmin = ref(false)
const adminName = ref('Admin')
const stats = ref<any>(null)

const monitor = reactive({
  cpuCores: 0,
  deviceRam: '—',
  platform: '—',
  screen: '—',
  memUsed: '0 MB',
  memTotal: '0 MB',
  memPercent: 0,
  latency: '—',
  sessionTime: '—',
  online: true,
})

const todayLabel = computed(() =>
  new Date().toLocaleDateString('id-ID', {
    weekday: 'long', day: 'numeric', month: 'long', year: 'numeric',
  })
)

const sessionStart = Date.now()
let monitorInterval: any = null

function fmtMB(bytes: number) {
  return (bytes / 1024 / 1024).toFixed(1) + ' MB'
}

async function measureLatency() {
  const t0 = performance.now()
  try {
    await fetch('/health', { cache: 'no-store' }).catch(() => {})
    const t1 = performance.now()
    monitor.latency = Math.round(t1 - t0) + ' ms'
    monitor.online = true
  } catch {
    monitor.latency = 'timeout'
    monitor.online = false
  }
}

function readMonitor() {
  const nav: any = navigator
  monitor.cpuCores = nav.hardwareConcurrency || 0
  monitor.deviceRam = nav.deviceMemory ? nav.deviceMemory + ' GB' : '—'
  monitor.platform = nav.userAgentData?.platform || nav.platform || '—'
  monitor.screen = window.screen.width + '×' + window.screen.height

  const perf: any = performance
  if (perf.memory) {
    const used = perf.memory.usedJSHeapSize
    const total = perf.memory.totalJSHeapSize
    monitor.memUsed = fmtMB(used)
    monitor.memTotal = fmtMB(total)
    monitor.memPercent = total ? Math.round((used / total) * 100) : 0
  }

  const sec = Math.floor((Date.now() - sessionStart) / 1000)
  const m = Math.floor(sec / 60)
  const s = sec % 60
  monitor.sessionTime = m > 0 ? `${m}m ${s}s` : `${s}s`
}

async function load() {
  const me: any = await $fetch('/api/admin-panel/me', { credentials: 'include' }).catch(() => null)
  if (!me?.success) {
    navigateTo('/panel/login')
    return false
  }
  isAdmin.value = true
  adminName.value = me.data.name || me.data.username || 'Admin'

  const st: any = await $fetch('/api/admin-panel/stats', { credentials: 'include' }).catch(() => null)
  if (st?.success) stats.value = st.data
  return true
}

async function refresh() {
  refreshing.value = true
  await Promise.all([load(), measureLatency()])
  refreshing.value = false
}

onMounted(async () => {
  try {
    await load()
    readMonitor()
    await measureLatency()
    monitorInterval = setInterval(readMonitor, 2000)
  } catch {
    navigateTo('/panel/login')
  } finally {
    checking.value = false
  }
})

onBeforeUnmount(() => {
  if (monitorInterval) clearInterval(monitorInterval)
})
</script>

<style scoped>
* { box-sizing: border-box; }

.page {
  min-height: 60vh;
  padding-bottom: 120px;
  color: var(--txt, #16121f);
}

/* ===== STATE ===== */
.state {
  text-align: center;
  padding: 60px 20px;
  color: var(--dim, #6f6a80);
  font-size: 13.5px;
}
.spinner {
  width: 32px; height: 32px;
  border: 3px solid var(--line, #eceaf4);
  border-top-color: var(--vio, #7c3aed);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  margin: 0 auto 16px;
}
@keyframes spin { to { transform: rotate(360deg); } }

/* ===== HEADER ===== */
.welcome {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 20px;
  margin-bottom: 28px;
  flex-wrap: wrap;
}
.welcome-text { min-width: 0; }
.eyebrow {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  font-size: 10.5px;
  font-weight: 800;
  letter-spacing: 0.16em;
  text-transform: uppercase;
  color: var(--vio, #7c3aed);
  margin-bottom: 10px;
  padding: 5px 11px;
  background: rgba(124,58,237,0.06);
  border: 1px solid rgba(124,58,237,0.18);
  border-radius: 999px;
}
.eyebrow-dot {
  width: 6px; height: 6px;
  border-radius: 50%;
  background: var(--vio, #7c3aed);
  box-shadow: 0 0 0 3px rgba(124,58,237,0.15);
}
.welcome h1 {
  font-size: 26px;
  font-weight: 800;
  letter-spacing: -0.03em;
  color: var(--txt, #16121f);
  margin-bottom: 6px;
}
.welcome p { font-size: 13px; color: var(--dim, #6f6a80); }

.refresh-btn {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 10px 16px;
  background: #ffffff;
  border: 1px solid var(--line, #eceaf4);
  border-radius: 10px;
  color: var(--txt, #16121f);
  font-size: 12.5px;
  font-weight: 700;
  font-family: inherit;
  cursor: pointer;
  transition: all 0.15s;
  flex-shrink: 0;
  white-space: nowrap;
  -webkit-tap-highlight-color: transparent;
  box-shadow: 0 1px 2px rgba(88,60,160,0.05), 0 4px 14px rgba(88,60,160,0.06);
}
.refresh-btn:hover:not(:disabled) {
  border-color: var(--vio-2, #a78bfa);
  color: var(--vio, #7c3aed);
}
.refresh-btn:disabled { opacity: 0.5; cursor: not-allowed; }
.refresh-btn svg { width: 14px; height: 14px; }
.refresh-btn svg.spinning { animation: spin 1s linear infinite; }

/* ===== STATS ===== */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
  margin-bottom: 20px;
}
@media (max-width: 1024px) { .stats-grid { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 480px) { .stats-grid { grid-template-columns: 1fr; } }

.stat-card {
  padding: 18px;
  background: #ffffff;
  border: 1px solid var(--line, #eceaf4);
  border-radius: 14px;
  transition: all 0.2s;
  box-shadow: 0 1px 2px rgba(88,60,160,0.05), 0 4px 14px rgba(88,60,160,0.05);
  position: relative;
  overflow: hidden;
}
.stat-card::before {
  content: '';
  position: absolute;
  top: 0; left: 0; right: 0; height: 3px;
  background: var(--grad, linear-gradient(135deg, #7c3aed, #d946ef));
  opacity: 0;
  transition: opacity 0.2s;
}
.stat-card:hover {
  border-color: var(--line-2, #ddd9ee);
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(88,60,160,0.06), 0 20px 50px rgba(88,60,160,0.12);
}
.stat-card:hover::before { opacity: 1; }
.stat-head {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 10px;
  margin-bottom: 12px;
}
.stat-label {
  font-size: 10.5px;
  font-weight: 800;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: var(--dim, #6f6a80);
}
.stat-icon {
  width: 30px; height: 30px;
  border-radius: 9px;
  background: rgba(124,58,237,0.07);
  border: 1px solid rgba(124,58,237,0.15);
  color: var(--vio, #7c3aed);
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
}
.stat-icon--ok {
  background: rgba(16,185,129,0.08);
  border-color: rgba(16,185,129,0.22);
  color: #059669;
}
.stat-icon--warn {
  background: rgba(245,158,11,0.09);
  border-color: rgba(245,158,11,0.25);
  color: #d97706;
}
.stat-icon svg { width: 14px; height: 14px; }
.stat-value {
  font-size: 26px;
  font-weight: 800;
  letter-spacing: -0.03em;
  color: var(--txt, #16121f);
  font-variant-numeric: tabular-nums;
  word-break: break-word;
}

/* ===== CARD ===== */
.card {
  padding: 22px;
  background: #ffffff;
  border: 1px solid var(--line, #eceaf4);
  border-radius: 16px;
  margin-bottom: 16px;
  box-shadow: 0 1px 2px rgba(88,60,160,0.05), 0 4px 14px rgba(88,60,160,0.05);
}
.card-head {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 18px;
  gap: 12px;
  flex-wrap: wrap;
}
.card h2 {
  font-size: 15px;
  font-weight: 750;
  color: var(--txt, #16121f);
  margin-bottom: 3px;
}
.card-sub { font-size: 12px; color: var(--dim, #6f6a80); }

/* LIVE INDICATOR */
.live-indicator {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  padding: 5px 12px;
  background: rgba(16,185,129,0.07);
  border: 1px solid rgba(16,185,129,0.22);
  border-radius: 999px;
  font-size: 11px;
  font-weight: 750;
  color: #059669;
  letter-spacing: 0.06em;
  text-transform: uppercase;
}
.live-dot {
  width: 6px; height: 6px;
  border-radius: 50%;
  background: #10b981;
  box-shadow: 0 0 0 3px rgba(16,185,129,0.15);
  animation: pulse 2s infinite;
}
@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.4; }
}

/* ===== MONITOR GRID ===== */
.monitor-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 10px;
  margin-bottom: 14px;
}
@media (max-width: 640px) { .monitor-grid { grid-template-columns: repeat(2, 1fr); } }

.monitor-item {
  padding: 12px 14px;
  background: var(--bg-soft, #f9f8fc);
  border: 1px solid var(--line, #eceaf4);
  border-radius: 11px;
  min-width: 0;
}
.mi-label {
  font-size: 10px;
  font-weight: 800;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: var(--dim, #6f6a80);
  margin-bottom: 6px;
}
.mi-value {
  font-size: 14px;
  font-weight: 700;
  color: var(--txt, #16121f);
  word-break: break-word;
  overflow: hidden;
  text-overflow: ellipsis;
}
.mi-value-sm {
  font-size: 11.5px;
  font-weight: 600;
  color: var(--dim, #6f6a80);
}

/* ===== PROGRESS ===== */
.progress-wrap {
  padding: 14px 16px;
  background: var(--bg-soft, #f9f8fc);
  border: 1px solid var(--line, #eceaf4);
  border-radius: 11px;
  margin-bottom: 12px;
}
.progress-head {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  gap: 10px;
  margin-bottom: 8px;
}
.progress-head .mi-label { margin-bottom: 0; }
.progress-bar {
  height: 6px;
  background: var(--line, #eceaf4);
  border-radius: 999px;
  overflow: hidden;
  margin-bottom: 6px;
}
.progress-fill {
  height: 100%;
  background: var(--grad, linear-gradient(135deg, #7c3aed, #d946ef));
  border-radius: 999px;
  transition: width 0.4s ease;
}
.progress-foot { font-size: 11px; color: var(--dim, #6f6a80); }

/* ===== MONITOR FOOT ===== */
.monitor-foot {
  display: flex;
  flex-wrap: wrap;
  gap: 14px;
  padding-top: 14px;
  border-top: 1px solid var(--line, #eceaf4);
}
.mf-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 11.5px;
  color: var(--dim, #6f6a80);
}
.mf-dot {
  width: 5px; height: 5px;
  background: #10b981;
  border-radius: 50%;
  flex-shrink: 0;
  box-shadow: 0 0 0 3px rgba(16,185,129,0.12);
}
.mf-dot.offline {
  background: #e11d48;
  box-shadow: 0 0 0 3px rgba(225,29,72,0.12);
}

/* ===== QUICK LINKS ===== */
.quick-links {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 10px;
}
@media (max-width: 640px) { .quick-links { grid-template-columns: 1fr; } }

.quick-link {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 16px;
  background: var(--bg-soft, #f9f8fc);
  border: 1px solid var(--line, #eceaf4);
  border-radius: 12px;
  text-decoration: none;
  transition: all 0.2s;
  -webkit-tap-highlight-color: transparent;
}
.quick-link:hover {
  border-color: rgba(124,58,237,0.3);
  background: #ffffff;
  transform: translateY(-2px);
  box-shadow: 0 8px 24px -8px rgba(124,58,237,0.2);
}
.ql-icon {
  width: 38px; height: 38px;
  border-radius: 10px;
  background: rgba(124,58,237,0.07);
  border: 1px solid rgba(124,58,237,0.15);
  color: var(--vio, #7c3aed);
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
  transition: all 0.2s;
}
.ql-icon svg { width: 16px; height: 16px; }
.ql-body { flex: 1; min-width: 0; }
.ql-title {
  font-size: 13.5px;
  font-weight: 700;
  color: var(--txt, #16121f);
  margin-bottom: 3px;
}
.ql-desc {
  font-size: 12px;
  color: var(--dim, #6f6a80);
  line-height: 1.4;
}
.ql-arrow {
  width: 16px; height: 16px;
  color: var(--line-2, #ddd9ee);
  flex-shrink: 0;
  transition: all 0.2s;
}
.quick-link:hover .ql-arrow {
  color: var(--vio, #7c3aed);
  transform: translateX(3px);
}

/* ===== MOBILE ===== */
@media (max-width: 480px) {
  .welcome { margin-bottom: 22px; }
  .welcome h1 { font-size: 22px; }
  .refresh-btn { padding: 9px 14px; font-size: 12px; }
  .stat-card { padding: 16px; }
  .stat-value { font-size: 22px; }
  .card { padding: 18px; }
  .monitor-item { padding: 10px 12px; }
  .mi-value { font-size: 13px; }
  .ql-icon { width: 34px; height: 34px; }
}
</style>