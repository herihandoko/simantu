<template>
  <div class="space-y-8">
    <!-- Welcome Section -->
    <div class="bg-gradient-to-r from-primary-600 via-primary-700 to-primary-800 rounded-2xl p-8 text-white relative overflow-hidden">
      <div class="absolute inset-0 bg-black/10"></div>
      <div class="relative z-10">
        <h1 class="text-3xl font-bold mb-2">Welcome back, {{ authStore.user?.name }}! 👋</h1>
        <p class="text-primary-100 text-lg">Here's what's happening with your system today.</p>
      </div>
      <!-- Floating Elements -->
      <div class="absolute top-4 right-4 w-20 h-20 bg-white/10 rounded-full blur-xl"></div>
      <div class="absolute bottom-4 right-8 w-16 h-16 bg-white/5 rounded-full blur-lg"></div>
    </div>

    <!-- Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <div class="group bg-white rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300 p-6 border border-gray-100 hover:border-primary-200">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600 mb-1">Total Users</p>
            <p class="text-3xl font-bold text-gray-900">{{ stats.users }}</p>
            <p class="text-xs text-primary-600 mt-1">+12% from last month</p>
          </div>
          <div class="p-4 rounded-2xl bg-gradient-to-br from-primary-500 to-primary-600 group-hover:scale-110 transition-transform duration-300">
            <component :is="UsersIcon" class="w-8 h-8 text-white" />
          </div>
        </div>
      </div>

      <div class="group bg-white rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300 p-6 border border-gray-100 hover:border-secondary-200">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600 mb-1">Total Roles</p>
            <p class="text-3xl font-bold text-gray-900">{{ stats.roles }}</p>
            <p class="text-xs text-secondary-600 mt-1">+2 new roles</p>
          </div>
          <div class="p-4 rounded-2xl bg-gradient-to-br from-secondary-500 to-secondary-600 group-hover:scale-110 transition-transform duration-300">
            <component :is="ShieldCheckIcon" class="w-8 h-8 text-white" />
          </div>
        </div>
      </div>

      <div class="group bg-white rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300 p-6 border border-gray-100 hover:border-primary-200">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600 mb-1">Configurations</p>
            <p class="text-3xl font-bold text-gray-900">{{ stats.configs }}</p>
            <p class="text-xs text-primary-600 mt-1">All systems operational</p>
          </div>
          <div class="p-4 rounded-2xl bg-gradient-to-br from-primary-500 to-primary-600 group-hover:scale-110 transition-transform duration-300">
            <component :is="CogIcon" class="w-8 h-8 text-white" />
          </div>
        </div>
      </div>

      <div class="group bg-white rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300 p-6 border border-gray-100 hover:border-secondary-200">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600 mb-1">Active Sessions</p>
            <p class="text-3xl font-bold text-gray-900">{{ stats.sessions }}</p>
            <p class="text-xs text-secondary-600 mt-1">Peak hours</p>
          </div>
          <div class="p-4 rounded-2xl bg-gradient-to-br from-secondary-500 to-secondary-600 group-hover:scale-110 transition-transform duration-300">
            <component :is="ChartBarIcon" class="w-8 h-8 text-white" />
          </div>
        </div>
      </div>
    </div>

    <!-- Recent Activity & System Status -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Recent Users -->
      <div class="bg-white rounded-2xl shadow-lg p-6 border border-gray-100">
        <div class="flex items-center justify-between mb-6">
          <h3 class="text-xl font-bold text-gray-900">Recent Users</h3>
          <div class="p-2 bg-primary-100 rounded-lg">
            <component :is="UsersIcon" class="w-5 h-5 text-primary-600" />
          </div>
        </div>
        <div class="space-y-4">
          <div v-for="user in recentUsers" :key="user.id" class="flex items-center justify-between p-3 bg-gray-50 rounded-xl hover:bg-gray-100 transition-colors duration-200">
            <div class="flex items-center">
              <div class="w-10 h-10 bg-gradient-to-br from-primary-500 to-primary-600 rounded-full flex items-center justify-center">
                <span class="text-sm font-bold text-white">{{ user.name.charAt(0) }}</span>
              </div>
              <div class="ml-3">
                <p class="text-sm font-semibold text-gray-900">{{ user.name }}</p>
                <p class="text-xs text-gray-500">{{ user.email }}</p>
              </div>
            </div>
            <span class="text-xs text-gray-500 bg-white px-2 py-1 rounded-lg">{{ formatDate(user.created_at) }}</span>
          </div>
        </div>
      </div>

      <!-- System Status -->
      <div class="bg-white rounded-2xl shadow-lg p-6 border border-gray-100">
        <div class="flex items-center justify-between mb-6">
          <h3 class="text-xl font-bold text-gray-900">System Status</h3>
          <div class="p-2 bg-primary-100 rounded-lg">
            <component :is="ShieldCheckIcon" class="w-5 h-5 text-primary-600" />
          </div>
        </div>
        <div class="space-y-4">
          <div class="flex items-center justify-between p-3 bg-gray-50 rounded-xl">
            <div class="flex items-center">
              <div class="w-3 h-3 bg-primary-500 rounded-full mr-3 animate-pulse"></div>
              <span class="text-sm font-medium text-gray-700">Database</span>
            </div>
            <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-primary-100 text-primary-800">
              Online
            </span>
          </div>
          <div class="flex items-center justify-between p-3 bg-gray-50 rounded-xl">
            <div class="flex items-center">
              <div class="w-3 h-3 bg-primary-500 rounded-full mr-3 animate-pulse"></div>
              <span class="text-sm font-medium text-gray-700">API Server</span>
            </div>
            <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-primary-100 text-primary-800">
              Online
            </span>
          </div>
          <div class="flex items-center justify-between p-3 bg-gray-50 rounded-xl">
            <div class="flex items-center">
              <div class="w-3 h-3 bg-primary-500 rounded-full mr-3 animate-pulse"></div>
              <span class="text-sm font-medium text-gray-700">Frontend</span>
            </div>
            <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-primary-100 text-primary-800">
              Online
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- Quick Actions -->
    <div class="bg-white rounded-2xl shadow-lg p-6 border border-gray-100">
      <h3 class="text-xl font-bold text-gray-900 mb-6">Quick Actions</h3>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <button class="flex items-center p-4 bg-gradient-to-r from-primary-50 to-primary-100 rounded-xl hover:from-primary-100 hover:to-primary-200 transition-all duration-200 group">
          <div class="p-3 bg-primary-500 rounded-lg group-hover:scale-110 transition-transform duration-200">
            <component :is="UsersIcon" class="w-6 h-6 text-white" />
          </div>
          <div class="ml-4 text-left">
            <p class="font-semibold text-gray-900">Manage Users</p>
            <p class="text-xs text-gray-600">Add, edit, or remove users</p>
          </div>
        </button>
        
        <button class="flex items-center p-4 bg-gradient-to-r from-secondary-50 to-secondary-100 rounded-xl hover:from-secondary-100 hover:to-secondary-200 transition-all duration-200 group">
          <div class="p-3 bg-secondary-500 rounded-lg group-hover:scale-110 transition-transform duration-200">
            <component :is="ShieldCheckIcon" class="w-6 h-6 text-white" />
          </div>
          <div class="ml-4 text-left">
            <p class="font-semibold text-gray-900">Manage Roles</p>
            <p class="text-xs text-gray-600">Configure permissions</p>
          </div>
        </button>
        
        <button class="flex items-center p-4 bg-gradient-to-r from-primary-50 to-primary-100 rounded-xl hover:from-primary-100 hover:to-primary-200 transition-all duration-200 group">
          <div class="p-3 bg-primary-500 rounded-lg group-hover:scale-110 transition-transform duration-200">
            <component :is="CogIcon" class="w-6 h-6 text-white" />
          </div>
          <div class="ml-4 text-left">
            <p class="font-semibold text-gray-900">System Config</p>
            <p class="text-xs text-gray-600">Update settings</p>
          </div>
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { useAuthStore } from '../stores/auth'
import {
  UsersIcon,
  ShieldCheckIcon,
  CogIcon,
  ChartBarIcon
} from '@heroicons/vue/24/outline'

export default {
  name: 'Dashboard',
  setup() {
    const authStore = useAuthStore()
    const stats = ref({
      users: 0,
      roles: 0,
      configs: 0,
      sessions: 0
    })

    const recentUsers = ref([])

    const formatDate = (dateString) => {
      return new Date(dateString).toLocaleDateString()
    }

    const fetchDashboardData = async () => {
      // Simulate API calls
      stats.value = {
        users: 156,
        roles: 8,
        configs: 24,
        sessions: 12
      }

      recentUsers.value = [
        { id: 1, name: 'John Doe', email: 'john@example.com', created_at: '2024-01-15' },
        { id: 2, name: 'Jane Smith', email: 'jane@example.com', created_at: '2024-01-14' },
        { id: 3, name: 'Bob Johnson', email: 'bob@example.com', created_at: '2024-01-13' }
      ]
    }

    onMounted(() => {
      fetchDashboardData()
    })

    return {
      authStore,
      stats,
      recentUsers,
      formatDate,
      UsersIcon,
      ShieldCheckIcon,
      CogIcon,
      ChartBarIcon
    }
  }
}
</script>
