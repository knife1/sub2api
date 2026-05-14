<template>
  <AppLayout>
    <div class="space-y-6">
      <div class="grid grid-cols-1 gap-6 xl:grid-cols-[420px_minmax(0,1fr)]">
        <form class="card p-6" @submit.prevent="generateImage">
          <div class="mb-6 flex items-center justify-between gap-3">
            <div>
              <h1 class="text-xl font-semibold text-gray-900 dark:text-white">{{ t('imageGeneration.title') }}</h1>
              <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">{{ t('imageGeneration.description') }}</p>
            </div>
            <div class="flex h-11 w-11 items-center justify-center rounded-xl bg-primary-50 text-primary-600 dark:bg-primary-900/30 dark:text-primary-300">
              <Icon name="sparkles" size="lg" :stroke-width="2" />
            </div>
          </div>

          <div class="space-y-4">
            <div>
              <label for="image-base-url" class="input-label">{{ t('imageGeneration.baseUrl') }}</label>
              <input
                id="image-base-url"
                v-model.trim="baseUrl"
                type="url"
                class="input"
                autocomplete="off"
                spellcheck="false"
                :placeholder="t('imageGeneration.baseUrlPlaceholder')"
              />
              <p class="input-hint">{{ t('imageGeneration.baseUrlHint') }}</p>
            </div>

            <div>
              <label for="image-api-key" class="input-label">{{ t('imageGeneration.apiKey') }}</label>
              <div class="relative">
                <input
                  id="image-api-key"
                  v-model="apiKey"
                  :type="showApiKey ? 'text' : 'password'"
                  class="input pr-11"
                  autocomplete="off"
                  spellcheck="false"
                  :placeholder="t('imageGeneration.apiKeyPlaceholder')"
                />
                <button
                  type="button"
                  class="absolute right-2 top-1/2 -translate-y-1/2 rounded-lg p-2 text-gray-400 transition-colors hover:bg-gray-100 hover:text-gray-600 dark:hover:bg-dark-700 dark:hover:text-gray-200"
                  :title="showApiKey ? t('imageGeneration.hideApiKey') : t('imageGeneration.showApiKey')"
                  @click="showApiKey = !showApiKey"
                >
                  <Icon :name="showApiKey ? 'eyeOff' : 'eye'" size="sm" :stroke-width="2" />
                </button>
              </div>
              <p class="input-hint">{{ t('imageGeneration.apiKeyHint') }}</p>
            </div>

            <div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
              <div>
                <label for="image-model" class="input-label">{{ t('imageGeneration.model') }}</label>
                <input
                  id="image-model"
                  v-model.trim="model"
                  type="text"
                  class="input"
                  autocomplete="off"
                  spellcheck="false"
                />
              </div>
              <div>
                <label for="image-size" class="input-label">{{ t('imageGeneration.size') }}</label>
                <Select id="image-size" v-model="size" :options="sizeOptions" />
              </div>
            </div>

            <div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
              <div>
                <label for="image-quality" class="input-label">{{ t('imageGeneration.quality') }}</label>
                <Select id="image-quality" v-model="quality" :options="qualityOptions" />
              </div>
              <div>
                <label for="image-count" class="input-label">{{ t('imageGeneration.count') }}</label>
                <input
                  id="image-count"
                  v-model.number="count"
                  type="number"
                  min="1"
                  max="4"
                  class="input"
                />
              </div>
            </div>

            <div>
              <label for="image-prompt" class="input-label">{{ t('imageGeneration.prompt') }}</label>
              <textarea
                id="image-prompt"
                v-model="prompt"
                class="input min-h-[180px] resize-y leading-relaxed"
                :placeholder="t('imageGeneration.promptPlaceholder')"
              ></textarea>
            </div>

            <div class="rounded-xl border border-blue-100 bg-blue-50 p-3 text-xs leading-relaxed text-blue-700 dark:border-blue-900/50 dark:bg-blue-900/20 dark:text-blue-200">
              {{ t('imageGeneration.privacyNote') }}
            </div>

            <div class="flex flex-col gap-3 sm:flex-row">
              <button
                type="submit"
                class="btn btn-primary flex-1"
                :disabled="generating"
              >
                <Icon
                  :name="generating ? 'refresh' : 'sparkles'"
                  size="md"
                  :class="generating ? 'animate-spin' : ''"
                  :stroke-width="2"
                />
                {{ generating ? t('imageGeneration.generating') : t('imageGeneration.generate') }}
              </button>
              <button type="button" class="btn btn-secondary" :disabled="generating" @click="resetResult">
                <Icon name="trash" size="md" :stroke-width="2" />
                {{ t('imageGeneration.clear') }}
              </button>
            </div>
          </div>
        </form>

        <div class="space-y-6">
          <div class="card min-h-[420px] p-6">
            <div class="mb-4 flex flex-wrap items-center justify-between gap-3">
              <div>
                <h2 class="text-base font-semibold text-gray-900 dark:text-white">{{ t('imageGeneration.result') }}</h2>
                <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">{{ statusText }}</p>
              </div>
              <button
                v-if="images.length > 0"
                type="button"
                class="btn btn-secondary btn-sm"
                @click="downloadAll"
              >
                <Icon name="download" size="sm" :stroke-width="2" />
                {{ t('imageGeneration.downloadAll') }}
              </button>
            </div>

            <div v-if="generating" class="flex min-h-[300px] flex-col items-center justify-center text-center">
              <div class="mb-4 flex h-14 w-14 items-center justify-center rounded-2xl bg-primary-50 text-primary-600 dark:bg-primary-900/30 dark:text-primary-300">
                <Icon name="refresh" size="xl" class="animate-spin" :stroke-width="2" />
              </div>
              <p class="text-sm font-medium text-gray-700 dark:text-gray-200">{{ t('imageGeneration.waiting') }}</p>
            </div>

            <div v-else-if="images.length > 0" class="grid grid-cols-1 gap-4 md:grid-cols-2">
              <div
                v-for="(image, index) in images"
                :key="`${image.url}-${index}`"
                class="group relative overflow-hidden rounded-xl border border-gray-100 bg-gray-50 dark:border-dark-700 dark:bg-dark-900"
              >
                <button type="button" class="block w-full" @click="previewImageUrl = image.url">
                  <img :src="image.url" :alt="image.revisedPrompt || `image-${index + 1}`" class="aspect-square w-full object-contain" />
                </button>
                <div class="flex items-center justify-between gap-3 border-t border-gray-100 bg-white px-3 py-2 dark:border-dark-700 dark:bg-dark-800">
                  <span class="truncate text-xs text-gray-500 dark:text-gray-400">{{ image.mimeType || 'image/png' }}</span>
                  <div class="flex items-center gap-1">
                    <button
                      type="button"
                      class="rounded-lg p-1.5 text-gray-400 transition-colors hover:bg-gray-100 hover:text-gray-700 dark:hover:bg-dark-700 dark:hover:text-gray-200"
                      :title="t('imageGeneration.copyImageUrl')"
                      @click="copyImageUrl(image.url)"
                    >
                      <Icon name="copy" size="sm" :stroke-width="2" />
                    </button>
                    <button
                      type="button"
                      class="rounded-lg p-1.5 text-gray-400 transition-colors hover:bg-gray-100 hover:text-gray-700 dark:hover:bg-dark-700 dark:hover:text-gray-200"
                      :title="t('imageGeneration.download')"
                      @click="downloadImage(image, index)"
                    >
                      <Icon name="download" size="sm" :stroke-width="2" />
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <div v-else class="flex min-h-[300px] flex-col items-center justify-center rounded-xl border border-dashed border-gray-200 bg-gray-50 text-center dark:border-dark-700 dark:bg-dark-900/60">
              <Icon name="sparkles" size="xl" class="mb-3 text-gray-300 dark:text-dark-500" :stroke-width="1.5" />
              <p class="text-sm font-medium text-gray-700 dark:text-gray-200">{{ t('imageGeneration.emptyTitle') }}</p>
              <p class="mt-1 max-w-sm text-xs text-gray-500 dark:text-gray-400">{{ t('imageGeneration.emptyDescription') }}</p>
            </div>
          </div>

          <div v-if="rawResponse" class="card p-4">
            <div class="mb-3 flex items-center justify-between gap-3">
              <h2 class="text-sm font-semibold text-gray-900 dark:text-white">{{ t('imageGeneration.rawResponse') }}</h2>
              <button type="button" class="btn btn-secondary btn-sm" @click="copyRawResponse">
                <Icon name="copy" size="sm" :stroke-width="2" />
                {{ t('common.copy') }}
              </button>
            </div>
            <pre class="max-h-80 overflow-auto rounded-xl bg-gray-950 p-4 text-xs leading-relaxed text-gray-100">{{ rawResponse }}</pre>
          </div>
        </div>
      </div>
    </div>

    <Teleport to="body">
      <Transition name="fade">
        <div
          v-if="previewImageUrl"
          class="fixed inset-0 z-[100] flex items-center justify-center bg-black/80 p-4"
          @click.self="previewImageUrl = ''"
        >
          <button
            class="absolute right-4 top-4 rounded-full bg-black/50 p-2 text-white transition-colors hover:bg-black/70"
            @click="previewImageUrl = ''"
          >
            <Icon name="x" size="lg" :stroke-width="2" />
          </button>
          <img :src="previewImageUrl" alt="preview" class="max-h-[90vh] max-w-[90vw] rounded-lg object-contain shadow-2xl" />
        </div>
      </Transition>
    </Teleport>
  </AppLayout>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import AppLayout from '@/components/layout/AppLayout.vue'
import Select from '@/components/common/Select.vue'
import { Icon } from '@/components/icons'
import { useAppStore } from '@/stores/app'
import { useClipboard } from '@/composables/useClipboard'

interface GeneratedImage {
  url: string
  mimeType?: string
  revisedPrompt?: string
}

const { t } = useI18n()
const appStore = useAppStore()
const { copyToClipboard } = useClipboard()

const baseUrl = ref(`${window.location.origin}/v1`)
const apiKey = ref('')
const showApiKey = ref(false)
const model = ref('gpt-image-2')
const size = ref('1024x1024')
const quality = ref('auto')
const count = ref(1)
const prompt = ref('')
const generating = ref(false)
const images = ref<GeneratedImage[]>([])
const rawResponse = ref('')
const errorMessage = ref('')
const previewImageUrl = ref('')

const sizeOptions = computed(() => [
  { value: '1024x1024', label: '1024 x 1024' },
  { value: '1024x1536', label: '1024 x 1536' },
  { value: '1536x1024', label: '1536 x 1024' },
  { value: 'auto', label: t('imageGeneration.auto') }
])

const qualityOptions = computed(() => [
  { value: 'auto', label: t('imageGeneration.auto') },
  { value: 'low', label: t('imageGeneration.low') },
  { value: 'medium', label: t('imageGeneration.medium') },
  { value: 'high', label: t('imageGeneration.high') }
])

const statusText = computed(() => {
  if (generating.value) return t('imageGeneration.statusGenerating')
  if (errorMessage.value) return errorMessage.value
  if (images.value.length > 0) return t('imageGeneration.statusSuccess', { count: images.value.length })
  return t('imageGeneration.statusIdle')
})

function normalizeBaseUrl(value: string): string {
  const trimmed = value.trim().replace(/\/+$/, '')
  if (!trimmed) return ''
  return trimmed.endsWith('/v1') ? trimmed : `${trimmed}/v1`
}

function dataUrlFromBase64(value: string, mimeType = 'image/png'): string {
  const trimmed = value.trim()
  if (trimmed.startsWith('data:')) return trimmed
  return `data:${mimeType};base64,${trimmed}`
}

function collectImages(node: unknown, fallbackMimeType = 'image/png'): GeneratedImage[] {
  const found: GeneratedImage[] = []

  const walk = (value: unknown, inheritedPrompt = '') => {
    if (Array.isArray(value)) {
      value.forEach((item) => walk(item, inheritedPrompt))
      return
    }

    if (!value || typeof value !== 'object') return
    const item = value as Record<string, unknown>
    const revisedPrompt =
      typeof item.revised_prompt === 'string'
        ? item.revised_prompt
        : typeof item.prompt === 'string'
          ? item.prompt
          : inheritedPrompt
    const mimeType =
      typeof item.mime_type === 'string'
        ? item.mime_type
        : typeof item.mimeType === 'string'
          ? item.mimeType
          : fallbackMimeType

    const directUrl = typeof item.url === 'string' ? item.url : typeof item.image_url === 'string' ? item.image_url : ''
    const b64Json =
      typeof item.b64_json === 'string'
        ? item.b64_json
        : typeof item.base64 === 'string'
          ? item.base64
          : typeof item.image_base64 === 'string'
            ? item.image_base64
            : ''

    if (b64Json) {
      found.push({ url: dataUrlFromBase64(b64Json, mimeType), mimeType, revisedPrompt })
    } else if (directUrl) {
      found.push({ url: directUrl, mimeType, revisedPrompt })
    }

    for (const child of Object.values(item)) {
      walk(child, revisedPrompt)
    }
  }

  walk(node)
  return found
}

async function generateImage() {
  const endpointBase = normalizeBaseUrl(baseUrl.value)
  errorMessage.value = ''

  if (!endpointBase) {
    appStore.showWarning(t('imageGeneration.errors.baseUrlRequired'))
    return
  }
  if (!apiKey.value.trim()) {
    appStore.showWarning(t('imageGeneration.errors.apiKeyRequired'))
    return
  }
  if (!prompt.value.trim()) {
    appStore.showWarning(t('imageGeneration.errors.promptRequired'))
    return
  }

  generating.value = true
  images.value = []
  rawResponse.value = ''

  try {
    const body: Record<string, unknown> = {
      model: model.value.trim() || 'gpt-image-2',
      prompt: prompt.value.trim(),
      n: Math.min(Math.max(Number(count.value) || 1, 1), 4),
      response_format: 'b64_json'
    }
    if (size.value && size.value !== 'auto') body.size = size.value
    if (quality.value && quality.value !== 'auto') body.quality = quality.value

    const response = await fetch(`${endpointBase}/images/generations`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey.value.trim()}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(body)
    })

    const text = await response.text()
    rawResponse.value = text

    let payload: unknown = text
    try {
      payload = JSON.parse(text)
    } catch {
      payload = text
    }

    if (!response.ok) {
      const message = extractErrorMessage(payload) || `${response.status} ${response.statusText}`
      throw new Error(message)
    }

    const parsedImages = collectImages(payload)
    if (parsedImages.length === 0) {
      throw new Error(t('imageGeneration.errors.noImage'))
    }

    images.value = parsedImages
    appStore.showSuccess(t('imageGeneration.success', { count: parsedImages.length }))
  } catch (error) {
    const message = error instanceof Error ? error.message : t('imageGeneration.errors.unknown')
    errorMessage.value = message
    appStore.showError(message)
  } finally {
    generating.value = false
  }
}

function extractErrorMessage(payload: unknown): string {
  if (!payload || typeof payload !== 'object') {
    return typeof payload === 'string' ? payload : ''
  }
  const obj = payload as Record<string, unknown>
  if (typeof obj.error === 'string') return obj.error
  if (obj.error && typeof obj.error === 'object') {
    const err = obj.error as Record<string, unknown>
    if (typeof err.message === 'string') return err.message
  }
  if (typeof obj.message === 'string') return obj.message
  return ''
}

function resetResult() {
  images.value = []
  rawResponse.value = ''
  errorMessage.value = ''
  previewImageUrl.value = ''
}

function copyImageUrl(url: string) {
  copyToClipboard(url, t('imageGeneration.copied'))
}

function copyRawResponse() {
  copyToClipboard(rawResponse.value, t('imageGeneration.rawCopied'))
}

function downloadImage(image: GeneratedImage, index: number) {
  const link = document.createElement('a')
  link.href = image.url
  link.download = `image2-${index + 1}.${image.mimeType?.split('/')[1] || 'png'}`
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
}

function downloadAll() {
  images.value.forEach((image, index) => downloadImage(image, index))
}
</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
