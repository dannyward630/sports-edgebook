<script setup lang="ts">
import { ref } from 'vue'
import Button from 'primevue/button'
import InputText from 'primevue/inputtext'
import Message from 'primevue/message'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
const email = ref('')
const sending = ref(false)
const sent = ref(false)
const error = ref<string | null>(null)

async function submit() {
  sending.value = true
  error.value = null
  try {
    await auth.sendMagicLink(email.value.trim())
    sent.value = true
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Não foi possível enviar o link.'
  } finally {
    sending.value = false
  }
}
</script>

<template>
  <section class="mx-auto max-w-sm rounded-xl border border-surface-200 bg-surface-0 p-6">
    <h1 class="m-0 text-2xl font-semibold">Entrar</h1>
    <p class="mt-2 text-surface-600">Recebes um link de acesso por email.</p>
    <Message v-if="sent" severity="success" class="mt-4">
      Link enviado. Abre o email neste dispositivo.
    </Message>
    <form v-else class="mt-4 flex flex-col gap-3" @submit.prevent="submit">
      <label for="email" class="text-sm font-medium">Email</label>
      <InputText id="email" v-model="email" type="email" autocomplete="email" required />
      <Button type="submit" label="Enviar link" :loading="sending" />
      <Message v-if="error" severity="error">{{ error }}</Message>
    </form>
  </section>
</template>
