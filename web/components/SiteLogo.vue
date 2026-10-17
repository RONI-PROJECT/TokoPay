<!-- components/SiteLogo.vue -->
<template>
  <img
    v-if="logoUrl"
    :src="logoUrl"
    :alt="alt || siteName"
    :class="$attrs.class"
    @error="logoFailed = true"
  />
  <span v-else-if="logoFailed || !logoUrl" class="logo-fallback">{{ siteName || 'Ronipayment' }}</span>
</template>

<script setup lang="ts">
defineProps<{ alt?: string }>()
const { logoUrl, siteName } = useSiteSettings()
const logoFailed = ref(false)
</script>

<style scoped>
.logo-fallback {
  font-weight: 800;
  font-size: 18px;
  letter-spacing: -0.02em;
  color: var(--txt, #16121f);
  white-space: nowrap;
}
img { height: 30px; width: auto; display: block; }
</style>