const SKIP_ALWAYS = ['/panel', '/login', '/register', '/tos', '/privacy', '/disclaimer', '/pay', '/docs', '/maintenance']

function isAlwaysSkip(path) {
  return SKIP_ALWAYS.some((p) => path === p || path.startsWith(p + '/'))
}

export default defineNuxtPlugin(() => {
  const router = useRouter()
  let busy = false
  let last = null
  let intervalId = null

  async function tick() {
    if (busy) return
    if (typeof document !== 'undefined' && document.hidden) return

    const path = router.currentRoute.value.path

    // Jangan polling sama sekali di halaman auth/panel/legal
    if (isAlwaysSkip(path)) return

    busy = true
    try {
      const r = await $fetch(`/api/public/settings?_=${Date.now()}`, {
        headers: { 'Cache-Control': 'no-cache' },
      }).catch(() => null)
      if (!r?.data) return

      const maint = r.data.maintenance === true
      const wasMaint = last
      last = maint

      if (maint && path !== '/maintenance') {
        await router.push('/maintenance')
        return
      }
      if (!maint && wasMaint === true && path === '/maintenance') {
        await router.push('/')
      }
    } catch {}
    finally { busy = false }
  }

  // Cek instan sekali
  setTimeout(tick, 800)

  // Polling tiap 5 detik (bukan 1 detik)
  intervalId = setInterval(tick, 5000)

  // Instant check saat tab difokus balik
  if (typeof document !== 'undefined') {
    document.addEventListener('visibilitychange', () => {
      if (!document.hidden) tick()
    })
  }

  router.afterEach(() => setTimeout(tick, 100))
})
