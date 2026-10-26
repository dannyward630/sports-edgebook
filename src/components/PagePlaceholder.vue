<script setup lang="ts">
defineProps<{ title: string; phase: string; description: string }>()
</script>

<template>
  <section class="rounded-xl border border-surface-200 bg-surface-0 p-6">
    <h1 class="m-0 text-2xl font-semibold">{{ title }}</h1>
    <p class="mt-2 text-surface-600">{{ description }}</p>
    <p class="mt-4 text-sm text-surface-500">Chega na {{ phase }}.</p>
  </section>
</template>
