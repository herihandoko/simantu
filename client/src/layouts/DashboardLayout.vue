<template>
  <div class="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100">
    <!-- Sidebar -->
    <div class="fixed inset-y-0 left-0 z-50 bg-white/95 backdrop-blur-sm shadow-2xl border-r border-gray-200/50 transition-all duration-300"
         :class="isCollapsed ? 'w-16' : 'w-64'">
      <!-- Logo Section -->
      <div class="flex items-center justify-center h-16 px-4 bg-gradient-to-r from-primary-600 via-primary-700 to-primary-800 relative overflow-hidden">
        <div class="absolute inset-0 bg-black/10"></div>
        <div class="relative z-10 flex items-center">
          <div class="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center"
               :class="isCollapsed ? 'mr-0' : 'mr-3'">
            <span class="text-lg font-bold text-white">S</span>
          </div>
          <h1 v-if="!isCollapsed" class="text-xl font-bold text-white">SIMANTU</h1>
        </div>
        <!-- Floating Elements -->
        <div class="absolute top-1 right-1 w-6 h-6 bg-white/10 rounded-full blur-sm"></div>
        <div class="absolute bottom-1 right-2 w-4 h-4 bg-white/5 rounded-full blur-sm"></div>
      </div>
      
      <!-- Navigation -->
      <nav class="mt-6 px-2">
        <div class="space-y-1">
          <router-link
            v-for="item in menuItems"
            :key="item.name"
            :to="item.path"
            class="group flex items-center text-gray-700 hover:bg-gradient-to-r hover:from-primary-50 hover:to-secondary-50 hover:text-primary-600 rounded-lg transition-all duration-300 relative overflow-hidden"
            :class="{ 
              'bg-gradient-to-r from-primary-500 to-primary-600 text-white shadow-lg': $route.path === item.path,
              'hover:shadow-md': $route.path !== item.path,
              'px-3 py-2.5': isCollapsed,
              'px-3 py-2.5': !isCollapsed
            }"
          >
            <!-- Active indicator -->
            <div v-if="$route.path === item.path" class="absolute inset-0 bg-gradient-to-r from-primary-500 to-primary-600 rounded-lg"></div>
            <div class="relative z-10 flex items-center w-full"
                 :class="isCollapsed ? 'justify-center' : ''">
              <div class="p-1.5 rounded-md transition-all duration-300"
                   :class="$route.path === item.path ? 'bg-white/20' : 'bg-gray-100 group-hover:bg-primary-100'">
                <component :is="item.icon" class="w-4 h-4" 
                           :class="$route.path === item.path ? 'text-white' : 'text-gray-600 group-hover:text-primary-600'" />
              </div>
              <span v-if="!isCollapsed" class="ml-2.5 text-sm font-medium">{{ item.name }}</span>
            </div>
          </router-link>
        </div>
      </nav>

      <!-- User Info Section -->
      <div class="absolute bottom-4 left-2 right-2">
        <div class="bg-gradient-to-r from-gray-50 to-gray-100 rounded-lg p-3 border border-gray-200">
          <div class="flex items-center" :class="isCollapsed ? 'justify-center' : ''">
            <div class="w-8 h-8 bg-gradient-to-br from-primary-500 to-primary-600 rounded-full flex items-center justify-center">
              <span class="text-xs font-bold text-white">{{ authStore.user?.name?.charAt(0) || 'U' }}</span>
            </div>
            <div v-if="!isCollapsed" class="ml-2.5 flex-1">
              <p class="text-xs font-semibold text-gray-900">{{ authStore.user?.name || 'User' }}</p>
              <p class="text-xs text-gray-500 truncate">{{ authStore.user?.email || 'user@example.com' }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Main Content -->
    <div class="transition-all duration-300" :class="isCollapsed ? 'ml-16' : 'ml-64'">
      <!-- Top Bar -->
      <header class="bg-white/95 backdrop-blur-sm shadow-lg border-b border-gray-200/50 sticky top-0 z-40 h-16">
        <div class="flex items-center justify-between px-6 py-4 h-full">
          <!-- Left Section -->
          <div class="flex items-center">
            <!-- Toggle Button -->
            <button
              @click="toggleSidebar"
              class="p-2 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors duration-200 mr-4"
            >
              <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
              </svg>
            </button>
            
            <!-- Page Title Section -->
            <div class="flex items-center">
              <div class="p-1.5 bg-gradient-to-r from-primary-500 to-primary-600 rounded-lg mr-3">
                <component :is="currentPageIcon" class="w-4 h-4 text-white" />
              </div>
              <div>
                <h2 class="text-lg font-bold text-gray-900">{{ currentPageTitle }}</h2>
                <p class="text-xs text-gray-500">Manage your system efficiently</p>
              </div>
            </div>
          </div>
          
          <!-- Right Section -->
          <div class="flex items-center space-x-3">
            <!-- Notifications -->
            <button class="relative p-2 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors duration-200 group">
              <svg class="w-4 h-4 text-gray-600 group-hover:text-gray-800" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-5 5v-5zM12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"></path>
              </svg>
              <span class="absolute top-0.5 right-0.5 w-2 h-2 bg-red-500 rounded-full"></span>
            </button>
            
            <!-- User Profile -->
            <div class="flex items-center space-x-2 bg-gray-50 rounded-lg p-1.5">
              <div class="w-6 h-6 bg-gradient-to-br from-primary-500 to-primary-600 rounded-full flex items-center justify-center">
                <span class="text-xs font-bold text-white">{{ authStore.user?.name?.charAt(0) || 'U' }}</span>
              </div>
              <div class="text-right">
                <p class="text-xs font-semibold text-gray-900">{{ authStore.user?.name || 'User' }}</p>
                <p class="text-xs text-gray-500">{{ authStore.userRole || 'User' }}</p>
              </div>
            </div>
            
            <!-- Logout Button -->
            <button
              @click="handleLogout"
              class="flex items-center px-3 py-1.5 text-xs text-gray-600 hover:text-red-600 hover:bg-red-50 rounded-lg transition-all duration-200 group border border-gray-200 hover:border-red-200"
            >
              <component :is="ArrowRightOnRectangleIcon" class="w-3 h-3 mr-1.5 group-hover:scale-110 transition-transform duration-200" />
              Logout
            </button>
          </div>
        </div>
      </header>

      <!-- Page Content -->
      <main class="p-6">
        <router-view />
      </main>
    </div>
  </div>
</template>

<script>
import { computed, ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import {
  HomeIcon,
  UsersIcon,
  ShieldCheckIcon,
  CogIcon,
  ClipboardDocumentListIcon,
  BuildingOfficeIcon,
  ChartBarIcon,
  UserIcon,
  ArrowRightOnRectangleIcon
} from '@heroicons/vue/24/outline'

export default {
  name: 'DashboardLayout',
  setup() {
    const route = useRoute()
    const router = useRouter()
    const authStore = useAuthStore()
    
    // Sidebar collapse state
    const isCollapsed = ref(false)

    const menuItems = computed(() => {
      const roleName = authStore.user?.role ? authStore.user.role.toLowerCase() : ''
      
      const allMenuItems = [
        { name: 'Dashboard', path: '/', icon: HomeIcon, permission: 'dashboard.read', hideForTenagaAhli: true },
        { name: 'Analytics', path: '/analytics', icon: ChartBarIcon, permission: 'analytics.read' },
        { name: 'My Dashboard', path: '/expert-dashboard', icon: UserIcon, permission: 'dashboard.read' },
        { name: 'Users', path: '/users', icon: UsersIcon, permission: 'users.read' },
        { name: 'Roles', path: '/roles', icon: ShieldCheckIcon, permission: 'roles.read' },
        { name: 'Configs', path: '/configs', icon: CogIcon, permission: 'configs.read' },
        { name: 'Tasks', path: '/tasks', icon: ClipboardDocumentListIcon, permission: 'tasks.read' },
        { name: 'Master OPD', path: '/opd', icon: BuildingOfficeIcon, permission: 'opd.read' }
      ]
      
      // Filter menu items based on user permissions and role
      return allMenuItems.filter(item => {
        if (!authStore.user || !authStore.user.permissions) return false
        
        // Hide Dashboard menu for Tenaga Ahli role
        if (roleName === 'tenaga ahli' && item.hideForTenagaAhli) {
          return false
        }
        
        return authStore.user.permissions.includes(item.permission)
      })
    })

    const currentPageTitle = computed(() => {
      const currentItem = menuItems.value?.find(item => item.path === route.path)
      if (currentItem) {
        return currentItem.name
      }
      
      // Special handling for Tenaga Ahli accessing expert-dashboard
      const roleName = authStore.user?.role ? authStore.user.role.toLowerCase() : ''
      if (roleName === 'tenaga ahli' && route.path === '/expert-dashboard') {
        return 'My Dashboard'
      }
      
      return 'Dashboard'
    })

    const currentPageIcon = computed(() => {
      const currentItem = menuItems.value?.find(item => item.path === route.path)
      if (currentItem) {
        return currentItem.icon
      }
      
      // Special handling for Tenaga Ahli accessing expert-dashboard
      const roleName = authStore.user?.role ? authStore.user.role.toLowerCase() : ''
      if (roleName === 'tenaga ahli' && route.path === '/expert-dashboard') {
        return UserIcon
      }
      
      return HomeIcon
    })

    const toggleSidebar = () => {
      isCollapsed.value = !isCollapsed.value
    }

    const handleLogout = async () => {
      await authStore.logout()
      router.push('/login')
    }

    // Fetch user data on component mount
    onMounted(() => {
      if (authStore.isAuthenticated && !authStore.user) {
        authStore.fetchUser()
      }
    })

    return {
      authStore,
      menuItems,
      currentPageTitle,
      currentPageIcon,
      isCollapsed,
      toggleSidebar,
      handleLogout,
      ArrowRightOnRectangleIcon
    }
  }
}
</script>
