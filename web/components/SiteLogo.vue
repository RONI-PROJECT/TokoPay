<!-- components/SiteLogo.vue -->
<template>
  <img
    v-if="logoUrl && !logoFailed"
    :src="logoUrl"
    :alt="alt || siteName"
    :class="$attrs.class"
    :style="imgOk ? '' : 'opacity:0'"
    @load="imgOk = true"
    @error="logoFailed = true"
  />
  <span v-else-if="ready && (logoFailed || !logoUrl)" class="logo-fallback">{{ siteName || 'TokoPay' }}</span>
</template>

<script setup lang="ts">
defineProps<{ alt?: string }>()
const { logoUrl, siteName, load } = useSiteSettings()
const logoFailed = ref(false)
const imgOk = ref(false)
const ready = ref(false)
onMounted(async () => { await load(); ready.value = true })
</script>

<style scoped>
.logo-fallback {
  font-weight: 800;
  font-size: 18px;
  letter-spacing: -0.02em;
  color: var(--txt, #16121f);
  white-space: nowrap;
}
img { height: 30px; width: auto; display: block; transition: opacity .25s ease; }
</style>
