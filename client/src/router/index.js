import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const routes = [
  {
    path: '/test',
    name: 'Test',
    component: () => import('../views/Test.vue')
  },
  {
    path: '/test-login',
    name: 'TestLogin',
    component: () => import('../views/TestLogin.vue')
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/Login.vue'),
    meta: { requiresGuest: true }
  },
  {
    path: '/',
    component: () => import('../layouts/DashboardLayout.vue'),
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        name: 'Dashboard',
        component: () => import('../views/Dashboard.vue')
      },
      {
        path: '/users',
        name: 'Users',
        component: () => import('../views/Users.vue')
      },
      {
        path: '/roles',
        name: 'Roles',
        component: () => import('../views/Roles.vue')
      },
      {
        path: '/configs',
        name: 'Configs',
        component: () => import('../views/Configs.vue')
      },
      {
        path: '/tasks',
        name: 'Tasks',
        component: () => import('../views/Tasks.vue')
      },
      {
        path: '/opd',
        name: 'OPD',
        component: () => import('../views/OPD.vue')
      },
      {
        path: '/analytics',
        name: 'AnalyticsDashboard',
        component: () => import('../views/AnalyticsDashboard.vue')
      },
      {
        path: '/expert-dashboard',
        name: 'ExpertDashboard',
        component: () => import('../views/ExpertDashboard.vue')
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore()
  
  // If user has token but no user data, try to fetch user
  if (authStore.token && !authStore.user) {
    try {
      await authStore.fetchUser()
    } catch (error) {
      authStore.logout()
    }
  }
  
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    next('/login')
  } else if (to.meta.requiresGuest && authStore.isAuthenticated) {
    // Redirect to role-based dashboard after login
    const roleBasedPath = getRoleBasedPath(authStore.userRole)
    next(roleBasedPath)
  } else if (to.path === '/' && authStore.isAuthenticated) {
    // If accessing root path and authenticated, redirect to role-based dashboard
    const roleBasedPath = getRoleBasedPath(authStore.userRole)
    next(roleBasedPath)
  } else {
    next()
  }
})

// Function to determine dashboard path based on user role
function getRoleBasedPath(userRole) {
  switch (userRole?.toLowerCase()) {
    case 'manager':
    case 'pm':
    case 'project manager':
      return '/analytics'
    case 'tenaga ahli':
    case 'expert':
    case 'staff':
      return '/expert-dashboard'
    default:
      return '/analytics' // Default to analytics dashboard
  }
}

export default router
