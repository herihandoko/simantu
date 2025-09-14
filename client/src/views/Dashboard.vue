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
            <p class="text-xs text-primary-600 mt-1">{{ stats.users > 0 ? 'Active users' : 'No users yet' }}</p>
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
            <p class="text-xs text-secondary-600 mt-1">{{ stats.roles > 0 ? 'Permission sets' : 'No roles defined' }}</p>
          </div>
          <div class="p-4 rounded-2xl bg-gradient-to-br from-secondary-500 to-secondary-600 group-hover:scale-110 transition-transform duration-300">
            <component :is="ShieldCheckIcon" class="w-8 h-8 text-white" />
          </div>
        </div>
      </div>

      <div class="group bg-white rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300 p-6 border border-gray-100 hover:border-primary-200">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600 mb-1">Total Tasks</p>
            <p class="text-3xl font-bold text-gray-900">{{ stats.tasks }}</p>
            <p class="text-xs text-primary-600 mt-1">{{ stats.tasks > 0 ? 'Project tasks' : 'No tasks yet' }}</p>
          </div>
          <div class="p-4 rounded-2xl bg-gradient-to-br from-primary-500 to-primary-600 group-hover:scale-110 transition-transform duration-300">
            <component :is="ClipboardDocumentListIcon" class="w-8 h-8 text-white" />
          </div>
        </div>
      </div>

      <div class="group bg-white rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300 p-6 border border-gray-100 hover:border-secondary-200">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600 mb-1">Total OPD</p>
            <p class="text-3xl font-bold text-gray-900">{{ stats.opd }}</p>
            <p class="text-xs text-secondary-600 mt-1">{{ stats.opd > 0 ? 'Organizations' : 'No OPD data' }}</p>
          </div>
          <div class="p-4 rounded-2xl bg-gradient-to-br from-secondary-500 to-secondary-600 group-hover:scale-110 transition-transform duration-300">
            <component :is="BuildingOfficeIcon" class="w-8 h-8 text-white" />
          </div>
        </div>
      </div>
    </div>

    <!-- Recent Activity & System Status -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Recent Tasks -->
      <div class="bg-white rounded-2xl shadow-lg p-6 border border-gray-100">
        <div class="flex items-center justify-between mb-6">
          <h3 class="text-xl font-bold text-gray-900">Recent Tasks</h3>
          <div class="p-2 bg-primary-100 rounded-lg">
            <component :is="ClipboardDocumentListIcon" class="w-5 h-5 text-primary-600" />
          </div>
        </div>
        <div class="space-y-4">
          <div v-if="recentTasks.length === 0" class="text-center py-8">
            <component :is="ClipboardDocumentListIcon" class="w-12 h-12 text-gray-300 mx-auto mb-4" />
            <p class="text-gray-500">No tasks available</p>
          </div>
          <div v-for="task in recentTasks" :key="task.id" class="flex items-center justify-between p-3 bg-gray-50 rounded-xl hover:bg-gray-100 transition-colors duration-200">
            <div class="flex items-center">
              <div class="w-10 h-10 bg-gradient-to-br from-primary-500 to-primary-600 rounded-full flex items-center justify-center">
                <span class="text-sm font-bold text-white">{{ task.nama_pekerjaan ? task.nama_pekerjaan.charAt(0) : 'T' }}</span>
              </div>
              <div class="ml-3">
                <p class="text-sm font-semibold text-gray-900">{{ task.nama_pekerjaan || task.title || 'Untitled Task' }}</p>
                <p class="text-xs text-gray-500">{{ getStatusText(task.status) }}</p>
              </div>
            </div>
            <span class="text-xs text-gray-500 bg-white px-2 py-1 rounded-lg">{{ formatDate(task.created_at) }}</span>
          </div>
        </div>
      </div>

      <!-- System Health -->
      <div class="bg-white rounded-2xl shadow-lg p-6 border border-gray-100">
        <div class="flex items-center justify-between mb-6">
          <h3 class="text-xl font-bold text-gray-900">System Health</h3>
          <div class="p-2 bg-primary-100 rounded-lg">
            <component :is="ShieldCheckIcon" class="w-5 h-5 text-primary-600" />
          </div>
        </div>
        <div class="space-y-4">
          <div class="flex items-center justify-between p-3 bg-gray-50 rounded-xl">
            <div class="flex items-center">
              <div :class="systemHealth.database ? 'w-3 h-3 bg-green-500 rounded-full mr-3 animate-pulse' : 'w-3 h-3 bg-red-500 rounded-full mr-3'"></div>
              <span class="text-sm font-medium text-gray-700">Database</span>
            </div>
            <span :class="systemHealth.database ? 'inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-800' : 'inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-red-100 text-red-800'">
              {{ systemHealth.database ? 'Healthy' : 'Error' }}
            </span>
          </div>
          <div class="flex items-center justify-between p-3 bg-gray-50 rounded-xl">
            <div class="flex items-center">
              <div :class="systemHealth.api ? 'w-3 h-3 bg-green-500 rounded-full mr-3 animate-pulse' : 'w-3 h-3 bg-red-500 rounded-full mr-3'"></div>
              <span class="text-sm font-medium text-gray-700">API Server</span>
            </div>
            <span :class="systemHealth.api ? 'inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-800' : 'inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-red-100 text-red-800'">
              {{ systemHealth.api ? 'Running' : 'Down' }}
            </span>
          </div>
          <div class="flex items-center justify-between p-3 bg-gray-50 rounded-xl">
            <div class="flex items-center">
              <div :class="systemHealth.frontend ? 'w-3 h-3 bg-green-500 rounded-full mr-3 animate-pulse' : 'w-3 h-3 bg-red-500 rounded-full mr-3'"></div>
              <span class="text-sm font-medium text-gray-700">Frontend</span>
            </div>
            <span :class="systemHealth.frontend ? 'inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-800' : 'inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-red-100 text-red-800'">
              {{ systemHealth.frontend ? 'Active' : 'Offline' }}
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- Quick Actions -->
    <div class="bg-white rounded-2xl shadow-lg p-6 border border-gray-100">
      <h3 class="text-xl font-bold text-gray-900 mb-6">Quick Actions</h3>
      <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
        <button @click="$router.push('/users')" class="flex items-center p-4 bg-gradient-to-r from-primary-50 to-primary-100 rounded-xl hover:from-primary-100 hover:to-primary-200 transition-all duration-200 group">
          <div class="p-3 bg-primary-500 rounded-lg group-hover:scale-110 transition-transform duration-200">
            <component :is="UsersIcon" class="w-6 h-6 text-white" />
          </div>
          <div class="ml-4 text-left">
            <p class="font-semibold text-gray-900">Manage Users</p>
            <p class="text-xs text-gray-600">Add, edit, or remove users</p>
          </div>
        </button>
        
        <button @click="$router.push('/tasks')" class="flex items-center p-4 bg-gradient-to-r from-secondary-50 to-secondary-100 rounded-xl hover:from-secondary-100 hover:to-secondary-200 transition-all duration-200 group">
          <div class="p-3 bg-secondary-500 rounded-lg group-hover:scale-110 transition-transform duration-200">
            <component :is="ClipboardDocumentListIcon" class="w-6 h-6 text-white" />
          </div>
          <div class="ml-4 text-left">
            <p class="font-semibold text-gray-900">Manage Tasks</p>
            <p class="text-xs text-gray-600">Create and track tasks</p>
          </div>
        </button>
        
        <button @click="$router.push('/opd')" class="flex items-center p-4 bg-gradient-to-r from-primary-50 to-primary-100 rounded-xl hover:from-primary-100 hover:to-primary-200 transition-all duration-200 group">
          <div class="p-3 bg-primary-500 rounded-lg group-hover:scale-110 transition-transform duration-200">
            <component :is="BuildingOfficeIcon" class="w-6 h-6 text-white" />
          </div>
          <div class="ml-4 text-left">
            <p class="font-semibold text-gray-900">Manage OPD</p>
            <p class="text-xs text-gray-600">Organizational data</p>
          </div>
        </button>
        
        <button @click="$router.push('/roles')" class="flex items-center p-4 bg-gradient-to-r from-secondary-50 to-secondary-100 rounded-xl hover:from-secondary-100 hover:to-secondary-200 transition-all duration-200 group">
          <div class="p-3 bg-secondary-500 rounded-lg group-hover:scale-110 transition-transform duration-200">
            <component :is="ShieldCheckIcon" class="w-6 h-6 text-white" />
          </div>
          <div class="ml-4 text-left">
            <p class="font-semibold text-gray-900">Manage Roles</p>
            <p class="text-xs text-gray-600">Configure permissions</p>
          </div>
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { useAuthStore } from '../stores/auth'
import { useRouter } from 'vue-router'
import axios from 'axios'
import {
  UsersIcon,
  ShieldCheckIcon,
  ClipboardDocumentListIcon,
  BuildingOfficeIcon
} from '@heroicons/vue/24/outline'

export default {
  name: 'Dashboard',
  setup() {
    const authStore = useAuthStore()
    const router = useRouter()
    
    const stats = ref({
      users: 0,
      roles: 0,
      tasks: 0,
      opd: 0
    })

    const recentTasks = ref([])
    const systemHealth = ref({
      database: true,
      api: true,
      frontend: true
    })

    const formatDate = (dateString) => {
      return new Date(dateString).toLocaleDateString('id-ID', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      })
    }

    const getStatusText = (status) => {
      const statusMap = {
        'pending': 'To Do',
        'in_progress': 'In Progress',
        'completed': 'Done',
        'cancelled': 'Cancelled'
      }
      return statusMap[status] || status
    }

    const fetchDashboardData = async () => {
      try {
        // Fetch real data from APIs
        const [usersRes, rolesRes, tasksRes, opdRes] = await Promise.allSettled([
          axios.get('/api/users'),
          axios.get('/api/roles'),
          axios.get('/api/tasks'),
          axios.get('/api/opd')
        ])

        // Update stats with real data
        stats.value = {
          users: usersRes.status === 'fulfilled' ? usersRes.value.data.length : 0,
          roles: rolesRes.status === 'fulfilled' ? rolesRes.value.data.length : 0,
          tasks: tasksRes.status === 'fulfilled' ? tasksRes.value.data.length : 0,
          opd: opdRes.status === 'fulfilled' ? opdRes.value.data.length : 0
        }

        // Get recent tasks (last 5)
        if (tasksRes.status === 'fulfilled') {
          recentTasks.value = tasksRes.value.data
            .sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
            .slice(0, 5)
        }

        // Check system health
        systemHealth.value = {
          database: usersRes.status === 'fulfilled' && rolesRes.status === 'fulfilled',
          api: true, // If we got here, API is working
          frontend: true // Frontend is obviously working
        }

      } catch (error) {
        console.error('Error fetching dashboard data:', error)
        // Set system health to false if there are errors
        systemHealth.value = {
          database: false,
          api: false,
          frontend: true
        }
      }
    }

    onMounted(() => {
      fetchDashboardData()
    })

    return {
      authStore,
      router,
      stats,
      recentTasks,
      systemHealth,
      formatDate,
      getStatusText,
      UsersIcon,
      ShieldCheckIcon,
      ClipboardDocumentListIcon,
      BuildingOfficeIcon
    }
  }
}
</script>
