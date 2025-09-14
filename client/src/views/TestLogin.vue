<template>
  <div class="min-h-screen bg-gray-50 flex items-center justify-center">
    <div class="max-w-md w-full bg-white p-8 rounded-lg shadow-lg">
      <h1 class="text-2xl font-bold text-center mb-6">Test Login</h1>
      
      <div class="space-y-4">
        <button @click="testBackendConnection" class="w-full btn-primary">
          Test Backend Connection
        </button>
        
        <button @click="testLogin" class="w-full btn-primary">
          Test Login API
        </button>
        
        <div v-if="result" class="p-4 bg-gray-100 rounded-lg">
          <pre class="text-sm">{{ result }}</pre>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'TestLogin',
  data() {
    return {
      result: ''
    }
  },
  methods: {
    async testBackendConnection() {
      try {
        const response = await axios.get('/api/health')
        this.result = JSON.stringify(response.data, null, 2)
      } catch (error) {
        this.result = 'Error: ' + error.message
      }
    },
    
    async testLogin() {
      try {
        const response = await axios.post('/api/auth/login', {
          email: 'admin@simantu.com',
          password: 'admin123'
        })
        this.result = JSON.stringify(response.data, null, 2)
      } catch (error) {
        this.result = 'Error: ' + error.message
      }
    }
  }
}
</script>
