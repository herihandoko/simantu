<template>
  <div class="min-h-screen bg-gray-50 flex items-center justify-center">
    <div class="text-center">
      <h1 class="text-4xl font-bold text-gray-900 mb-4">SIMANTU Test Page</h1>
      <p class="text-gray-600 mb-8">If you can see this, Vue.js is working!</p>
      <div class="space-y-4">
        <button @click="testClick" class="btn-primary">
          Test Button
        </button>
        <p v-if="message" class="text-green-600">{{ message }}</p>
      </div>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue'

export default {
  name: 'Test',
  setup() {
    const message = ref('')

    const testClick = () => {
      message.value = 'Button clicked! Vue.js is working perfectly!'
    }

    return {
      message,
      testClick
    }
  }
}
</script>
