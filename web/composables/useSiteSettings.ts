import { ref, computed } from 'vue'

export interface SiteSettings {
  site_name: string
  site_title: string
  site_description: string
  site_keywords: string
  logo_url: string
  favicon_url: string
  hero_title: string
  hero_lead: string
  marquee_text: string
  marquee_items: string
  footer_text: string
  footer_copyright: string
  wd_min: number
  wd_fee_percent: number
  wd_fee_flat: number
  fee_transaction_percent: number
  maintenance_mode?: string
  maintenance_message?: string
  maintenance_eta?: string
}

const defaultSettings: SiteSettings = {
  site_name: 'UnoPay',
  site_title: 'UnoPay — Payment Gateway QRIS',
  site_description: 'Payment gateway QRIS untuk merchant Indonesia.',
  site_keywords: 'qris, payment gateway, indonesia',
  logo_url: '',
  favicon_url: '',
  hero_title: 'Terima pembayaran QRIS tanpa ribet',
  hero_lead: 'Satu dashboard untuk merchant: buat QRIS dinamis, pantau transaksi masuk, dan integrasi API yang siap dipasang.',
  marquee_text: 'Didukung berbagai bank & e-wallet',
  marquee_items: 'BCA,Mandiri,BNI,BRI,GoPay,OVO,DANA,ShopeePay',
  footer_text: 'UnoPay — payment gateway QRIS untuk merchant Indonesia.',
  footer_copyright: '© 2026 UnoPay. All rights reserved.',
  wd_min: 65000,
  wd_fee_percent: 2.5,
  wd_fee_flat: 4500,
  fee_transaction_percent: 1.8,
}

const settings = ref<SiteSettings>({ ...defaultSettings })
let loadingPromise: Promise<void> | null = null
let lastLoadAt = 0

const NUMERIC_KEYS = ['wd_min', 'wd_fee_percent', 'wd_fee_flat', 'fee_transaction_percent']

function normalize(raw: any): SiteSettings {
  const out: any = { ...defaultSettings }
  if (!raw || typeof raw !== 'object') return out
  for (const [k, v] of Object.entries(raw)) {
    if (v == null || v === '') continue
    if (NUMERIC_KEYS.includes(k)) {
      const n = Number(v)
      if (Number.isFinite(n)) out[k] = n
    } else {
      out[k] = v
    }
  }
  return out
}

export function useSiteSettings() {
  async function load(force = false) {
    if (loadingPromise && !force) return loadingPromise
    if (!force && Date.now() - lastLoadAt < 5000) return Promise.resolve()

    loadingPromise = (async () => {
      try {
        const r: any = await $fetch('/api/public/settings').catch(() => null)
        if (r?.success && r.data) {
          settings.value = normalize(r.data)
        }
        lastLoadAt = Date.now()
      } catch {
        // keep defaults
      }
    })()
    return loadingPromise
  }

  // auto-load HANYA di client — SSR fetch internal ke Express
  // bikin crash "Cannot set properties of undefined" di dev
  if (import.meta.client && lastLoadAt === 0) load()

  const siteName = computed(() => settings.value.site_name)
  const siteTitle = computed(() => settings.value.site_title)
  const siteDescription = computed(() => settings.value.site_description)
  const siteKeywords = computed(() => settings.value.site_keywords)
  const logoUrl = computed(() => settings.value.logo_url)
  const faviconUrl = computed(() => settings.value.favicon_url || settings.value.logo_url || '/favicon.ico')
  const heroTitle = computed(() => settings.value.hero_title)
  const heroLead = computed(() => settings.value.hero_lead)
  const marqueeText = computed(() => settings.value.marquee_text)
  const marqueeItems = computed(() => settings.value.marquee_items)
  const footerText = computed(() => settings.value.footer_text)
  const footerCopyright = computed(() => settings.value.footer_copyright)
  const wdMin = computed(() => settings.value.wd_min)
  const wdFeePercent = computed(() => settings.value.wd_fee_percent)
  const wdFeeFlat = computed(() => settings.value.wd_fee_flat)
  const feeTransactionPercent = computed(() => settings.value.fee_transaction_percent)
  const maintenance = computed(() => settings.value.maintenance_mode === 'true')

  return {
    settings,
    load,
    siteName,
    siteTitle,
    siteDescription,
    siteKeywords,
    logoUrl,
    faviconUrl,
    heroTitle,
    heroLead,
    marqueeText,
    marqueeItems,
    footerText,
    footerCopyright,
    wdMin,
    wdFeePercent,
    wdFeeFlat,
    feeTransactionPercent,
    maintenance,
  }
}