<template>
  <div class="space-y-4">
    <div class="flex flex-wrap items-center justify-between gap-3">
      <div>
        <h2 class="text-lg font-semibold text-gray-900 dark:text-white">使用文档</h2>
        <p class="mt-1 text-sm text-gray-500 dark:text-dark-400">CodeX 使用文档在线预览</p>
      </div>
      <a
        :href="codexGuidePdf"
        target="_blank"
        rel="noopener noreferrer"
        class="btn btn-secondary"
      >
        <Icon name="externalLink" size="sm" />
        新窗口打开
      </a>
    </div>

    <div class="overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-sm dark:border-dark-700 dark:bg-dark-900">
      <iframe
        :src="codexGuidePdf"
        title="CodeX 使用文档"
        class="h-[calc(100vh-12rem)] min-h-[36rem] w-full bg-white"
      ></iframe>
    </div>
  </div>
</template>

<script setup lang="ts">
import Icon from '@/components/icons/Icon.vue'
import codexGuidePdf from '@/assets/codex(1)(1)(1)(1).pdf'
</script>
