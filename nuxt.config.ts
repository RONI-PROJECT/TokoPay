import { createRequire } from 'node:module'
import { dirname, resolve } from 'node:path'

// cwd = ~/gobiz-payment (home). Di Vercel, cwd = root project. Valid di dua-duanya.
const ROOT = process.cwd()

const swaggerUiDir = dirname(
  createRequire(resolve(ROOT, 'package.json')).resolve('swagger-ui-dist/package.json')
)

const PUBLIC_URL = process.env.PUBLIC_URL || 'https://ronipayment.vercel.app'
const OG_IMAGE = process.env.PUBLIC_OG_IMAGE || 'https://cdn.phototourl.com/member/2026-10-17-2fc2fbd9-ed6f-4fbd-aa69-6b9fcaacbd79.png'
const FAVICON = process.env.PUBLIC_FAVICON_URL || 'https://cdn.phototourl.com/member/2026-10-17-0b756d8f-9d25-4483-8d78-ff9c4845a55f.png'

export default defineNuxtConfig({
  rootDir: ROOT,
  srcDir: resolve(ROOT, 'web'),
  serverDir: resolve(ROOT, 'server'),
  compatibilityDate: '2026-09-30',

  alias: {
    '~': resolve(ROOT, 'web'),
    '@': resolve(ROOT, 'web'),
    '#src': resolve(ROOT, 'src'),
  },

  ssr: true,
  devtools: { enabled: false },
  telemetry: false,
  css: ['~/assets/css/main.css'],

  app: {
    head: {
      title: 'TokoPayVIP — Payment Gateway QRIS untuk Merchant Indonesia',
      htmlAttrs: { lang: 'id' },
      meta: [
        { charset: 'utf-8' },
        { name: 'google-site-verification', content: 'V5yjNGmuNCCgyMGhIZ4y69cfTgFO7BahxbN_Fcm_Vmk' },
        { name: 'msvalidate.01', content: '19279482692DDF83B7473AD2D989AC15' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'theme-color', content: '#ffffff' },
        { name: 'description', content: 'TokoPayVIP adalah payment gateway QRIS untuk merchant Indonesia. Terima pembayaran QRIS, kelola transaksi, dan tarik dana dari satu dashboard.' },

        { property: 'og:type', content: 'website' },
        { property: 'og:site_name', content: 'TokoPayVIP' },
        { property: 'og:title', content: 'TokoPayVIP — Payment Gateway QRIS untuk Merchant Indonesia' },
        { property: 'og:description', content: 'Payment gateway QRIS untuk merchant Indonesia. Terima pembayaran QRIS, kelola transaksi, dan tarik dana dari satu dashboard.' },
        { property: 'og:image', content: OG_IMAGE },
        { property: 'og:image:secure_url', content: OG_IMAGE },
        { property: 'og:image:width', content: '1200' },
        { property: 'og:image:height', content: '630' },
        { property: 'og:image:type', content: 'image/png' },
        { property: 'og:image:alt', content: 'TokoPayVIP' },
        { property: 'og:url', content: PUBLIC_URL },

        { name: 'twitter:card', content: 'summary_large_image' },
        { name: 'twitter:title', content: 'TokoPayVIP — Payment Gateway QRIS' },
        { name: 'twitter:description', content: 'Payment gateway QRIS untuk merchant Indonesia.' },
        { name: 'twitter:image', content: OG_IMAGE },
        { name: 'twitter:image:alt', content: 'TokoPayVIP' },
      ],
      link: [
        { rel: 'icon', type: 'image/png', href: FAVICON },
        { rel: 'apple-touch-icon', sizes: '180x180', href: OG_IMAGE },
      ],
    },
  },

  runtimeConfig: {
    public: {
      apiBaseUrl: process.env.PUBLIC_API_BASE_URL || process.env.PUBLIC_URL || '',
      publicUrl: PUBLIC_URL,
      brandName: 'TokoPayVIP',
      turnstileSiteKey: process.env.NUXT_PUBLIC_TURNSTILE_SITE_KEY || '',
    },
  },

  nitro: {
    preset: 'vercel',
    externals: process.env.NODE_ENV !== 'production'
      ? { noExternal: true }
      : { external: ['@electric-sql/pglite'] },
    publicAssets: [{ dir: swaggerUiDir, baseURL: '/docs-assets', maxAge: 31_536_000 }],
  },

  routeRules: {
    '/robots.txt': { headers: { 'content-type': 'text/plain' } },
    '/sitemap.xml': { headers: { 'content-type': 'application/xml' } },
  },

  vite: {
    build: { target: 'esnext' },
    server: { allowedHosts: true },
  },
})