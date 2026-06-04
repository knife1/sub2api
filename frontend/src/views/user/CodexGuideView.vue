<template>
  <div class="space-y-4">
    <div class="flex flex-wrap items-center justify-between gap-3">
      <div>
        <h2 class="text-lg font-semibold text-gray-900 dark:text-white">使用文档</h2>
        <p class="mt-1 text-sm text-gray-500 dark:text-dark-400">CodeX 使用文档已切换为腾讯文档外链</p>
      </div>
      <a
        :href="codexGuideUrl"
        target="_blank"
        rel="noopener noreferrer"
        class="btn btn-secondary"
      >
        <Icon name="externalLink" size="sm" />
        新窗口打开
      </a>
    </div>

    <div class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm dark:border-dark-700 dark:bg-dark-900">
      <p class="text-sm text-gray-600 dark:text-dark-300">
        当前使用文档通过新窗口打开，点击上方按钮即可跳转到最新腾讯文档。
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import Icon from '@/components/icons/Icon.vue'

const codexGuideUrl = 'https://docs.qq.com/doc/DVGZsQ0dQdXVIUXNj?aidPos=detail&no_promotion=1&is_blank_or_template=blank&u=98ecb22822ea4fe2a590ca7620ef3ce9'
</script>
