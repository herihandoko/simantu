<template>
  <div class="min-h-screen flex items-center justify-center relative overflow-hidden">
    <!-- Animated Background -->
    <div class="absolute inset-0 bg-gradient-to-br from-primary-600 via-primary-700 to-primary-800">
      <div class="absolute inset-0 bg-black/20"></div>
      <!-- Floating Elements -->
      <div class="absolute top-20 left-20 w-32 h-32 bg-white/10 rounded-full blur-xl animate-pulse"></div>
      <div class="absolute top-40 right-32 w-24 h-24 bg-secondary-300/20 rounded-full blur-lg animate-bounce"></div>
      <div class="absolute bottom-32 left-1/3 w-40 h-40 bg-primary-300/15 rounded-full blur-2xl animate-pulse"></div>
      <div class="absolute bottom-20 right-20 w-28 h-28 bg-secondary-300/20 rounded-full blur-xl animate-bounce"></div>
    </div>
    
    <div class="max-w-sm w-full mx-4 relative z-10">
      <!-- Login Card -->
      <div class="bg-white/95 backdrop-blur-sm rounded-3xl shadow-2xl p-6 border border-white/20">
        <!-- Header -->
        <div class="text-center mb-6">
          <div class="mx-auto h-16 w-16 bg-gradient-to-r from-primary-600 to-primary-700 rounded-2xl flex items-center justify-center shadow-lg">
            <span class="text-2xl font-bold text-white">S</span>
          </div>
          <h2 class="mt-4 text-2xl font-bold bg-gradient-to-r from-gray-900 to-gray-600 bg-clip-text text-transparent">
            SIMANTU
          </h2>
          <p class="mt-1 text-xs text-gray-500">System Management</p>
        </div>
        
        <!-- Login Form -->
        <form class="space-y-4" @submit.prevent="handleLogin">
          <div class="space-y-4">
            <div>
              <label for="email" class="block text-xs font-semibold text-gray-700 mb-1">
                Email
              </label>
              <div class="relative">
                <input
                  id="email"
                  v-model="form.email"
                  type="email"
                  required
                  class="w-full px-3 py-2.5 text-sm border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all duration-200 bg-gray-50 focus:bg-white"
                  placeholder="admin@simantu.com"
                />
                <div class="absolute inset-y-0 right-0 pr-3 flex items-center">
                  <svg class="h-4 w-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207"></path>
                  </svg>
                </div>
              </div>
            </div>
            
            <div>
              <label for="password" class="block text-xs font-semibold text-gray-700 mb-1">
                Password
              </label>
              <div class="relative">
                <input
                  id="password"
                  v-model="form.password"
                  type="password"
                  required
                  class="w-full px-3 py-2.5 text-sm border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all duration-200 bg-gray-50 focus:bg-white"
                  placeholder="Enter password"
                />
                <div class="absolute inset-y-0 right-0 pr-3 flex items-center">
                  <svg class="h-4 w-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
                  </svg>
                </div>
              </div>
            </div>
          </div>

          <!-- Error Message -->
          <div v-if="errorMessage" class="bg-red-50 border-l-4 border-red-400 p-3 rounded-lg">
            <div class="flex">
              <div class="flex-shrink-0">
                <svg class="h-4 w-4 text-red-400" viewBox="0 0 20 20" fill="currentColor">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
                </svg>
              </div>
              <div class="ml-2">
                <p class="text-xs text-red-700">{{ errorMessage }}</p>
              </div>
            </div>
          </div>

          <!-- Login Button -->
          <div>
            <button
              type="submit"
              :disabled="authStore.isLoading"
              class="w-full bg-gradient-to-r from-primary-600 to-primary-700 hover:from-primary-700 hover:to-primary-800 text-white font-semibold py-2.5 px-4 rounded-lg transition-all duration-200 transform hover:scale-[1.02] focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none text-sm"
            >
              <span v-if="authStore.isLoading" class="flex items-center justify-center">
                <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                Signing in...
              </span>
              <span v-else class="flex items-center justify-center">
                <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1"></path>
                </svg>
                Sign In
              </span>
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'

export default {
  name: 'Login',
  setup() {
    const router = useRouter()
    const authStore = useAuthStore()
    
    const form = reactive({
      email: '',
      password: ''
    })
    
    const errorMessage = ref('')

    const handleLogin = async () => {
      errorMessage.value = ''
      
      const result = await authStore.login(form)
      
      if (result.success) {
        // Get first available path based on user permissions
        const getFirstAvailablePath = (user) => {
          if (!user || !user.permissions) {
            return '/'
          }
          
          // Define available routes with their permissions
          const availableRoutes = [
            { path: '/', permission: 'dashboard.read' },
            { path: '/users', permission: 'users.read' },
            { path: '/roles', permission: 'roles.read' },
            { path: '/configs', permission: 'configs.read' },
            { path: '/tasks', permission: 'tasks.read' },
            { path: '/opd', permission: 'opd.read' },
            { path: '/analytics', permission: 'analytics.read' },
            { path: '/expert-dashboard', permission: 'dashboard.read' }
          ]
          
          // Find first route user has permission for
          for (const route of availableRoutes) {
            if (user.permissions.includes(route.permission)) {
              return route.path
            }
          }
          
          // Fallback to root if no permissions found
          return '/'
        }
        
        const dashboardPath = getFirstAvailablePath(authStore.user)
        router.push(dashboardPath)
      } else {
        errorMessage.value = result.message
      }
    }

    return {
      form,
      errorMessage,
      authStore,
      handleLogin
    }
  }
}
</script>
