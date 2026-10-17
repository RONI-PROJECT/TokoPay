<!-- app.vue -->
<template>
  <div class="app-root">
    <div class="app-bg" aria-hidden="true">
      <div class="bg-glow bg-glow--a"></div>
      <div class="bg-glow bg-glow--b"></div>
    </div>

    <NuxtLayout>
      <NuxtPage />
    </NuxtLayout>
  </div>
</template>

<script setup lang="ts">
const config = useRuntimeConfig()
const route = useRoute()

const {
  siteTitle, siteName, siteDescription, siteKeywords,
  logoUrl, faviconUrl, maintenance, load,
} = useSiteSettings()

const siteUrl = computed(() =>
  (config.public.publicUrl || 'https://ronipayment.vercel.app').replace(/\/$/, '')
)

const favicon = computed(() => faviconUrl.value || '/favicon.ico')

const ogImage = computed(() => {
  const l = logoUrl.value || faviconUrl.value
  if (!l) return `${siteUrl.value}/og-default.png`
  return l.startsWith('http') ? l : siteUrl.value + l
})

const MAINTENANCE_ALLOWED = [
  '/maintenance', '/panel', '/api', '/_nuxt', '/favicon.ico', '/docs-assets',
]

function checkMaintenance() {
  if (!maintenance?.value) return
  const allowed = MAINTENANCE_ALLOWED.some(
    p => route.path === p || route.path.startsWith(p + '/')
  )
  if (!allowed) navigateTo('/maintenance')
}

onMounted(async () => {
  // settings dimuat di background — UI langsung render, nggak nunggu API
  await load(true)
  checkMaintenance()
})

watch(() => route.path, checkMaintenance)

useHead(() => {
  const name = siteName.value || 'Ronipayment'
  const title = siteTitle.value || `${name} — Payment Gateway QRIS`
  const desc = siteDescription.value || 'Payment gateway QRIS untuk merchant Indonesia.'
  const url = siteUrl.value
  const img = ogImage.value

  const jsonLd = (data: Record<string, unknown>) =>
    JSON.stringify({ '@context': 'https://schema.org', ...data })

  return {
    htmlAttrs: { lang: 'id' },
    title,
    link: [
      { rel: 'icon', type: 'image/png', href: favicon.value },
      { rel: 'apple-touch-icon', sizes: '180x180', href: favicon.value },
      { rel: 'canonical', href: url + route.path },
    ],
    meta: [
      { name: 'description', content: desc },
      { name: 'keywords', content: siteKeywords.value },
      { name: 'theme-color', content: '#ffffff' },
      { name: 'google-site-verification', content: 'V5yjNGmuNCCgyMGhIZ4y69cfTgFO7BahxbN_Fcm_Vmk' },

      { property: 'og:type', content: 'website' },
      { property: 'og:site_name', content: name },
      { property: 'og:title', content: title },
      { property: 'og:description', content: desc },
      { property: 'og:image', content: img },
      { property: 'og:image:secure_url', content: img },
      { property: 'og:url', content: url + route.path },

      { name: 'twitter:card', content: 'summary_large_image' },
      { name: 'twitter:title', content: title },
      { name: 'twitter:description', content: desc },
      { name: 'twitter:image', content: img },
    ],
    script: [
      { type: 'application/ld+json', innerHTML: jsonLd({ '@type': 'Organization', name, url, logo: img, description: desc, sameAs: ['https://github.com/RONI-PROJECT/gobiz-payment'] }) },
      { type: 'application/ld+json', innerHTML: jsonLd({ '@type': 'WebSite', name, url, potentialAction: { '@type': 'SearchAction', target: `${url}/?s={search_term_string}`, 'query-input': 'required name=search_term_string' } }) },
      { type: 'application/ld+json', innerHTML: jsonLd({ '@type': 'SoftwareApplication', name: 'Ronipayment', applicationCategory: 'FinanceApplication', operatingSystem: 'Web', url, description: desc, offers: { '@type': 'Offer', price: '0', priceCurrency: 'IDR' } }) },
    ],
  }
})
</script>

<style>
/* ambient glow ungu — halus, di belakang semua */
.app-root { position: relative; min-height: 100vh; overflow-x: hidden; }
.app-content { position: relative; z-index: 1; }

.app-bg { position: fixed; inset: 0; z-index: 0; pointer-events: none; }
.bg-glow {
  position: absolute; border-radius: 50%;
  filter: blur(140px); opacity: 0.06;
}
.bg-glow--a {
  width: 620px; height: 620px; top: -240px; right: -160px;
  background: radial-gradient(circle, #7c3aed, transparent 70%);
  animation: float 20s ease-in-out infinite;
}
.bg-glow--b {
  width: 560px; height: 560px; bottom: -220px; left: -140px;
  background: radial-gradient(circle, #d946ef, transparent 70%);
  animation: float 26s ease-in-out infinite reverse;
}
@keyframes float {
  0%, 100% { transform: translate(0, 0) scale(1); }
  50% { transform: translate(-40px, 40px) scale(1.08); }
}

@media (prefers-reduced-motion: reduce) {
  .bg-glow { animation: none; }
}
</style>