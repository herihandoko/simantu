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
        component: () => import('../views/Dashboard.vue'),
        meta: { permission: 'dashboard.read' }
      },
      {
        path: '/users',
        name: 'Users',
        component: () => import('../views/Users.vue'),
        meta: { permission: 'users.read' }
      },
      {
        path: '/roles',
        name: 'Roles',
        component: () => import('../views/Roles.vue'),
        meta: { permission: 'roles.read' }
      },
      {
        path: '/configs',
        name: 'Configs',
        component: () => import('../views/Configs.vue'),
        meta: { permission: 'configs.read' }
      },
      {
        path: '/tasks',
        name: 'Tasks',
        component: () => import('../views/Tasks.vue'),
        meta: { permission: 'tasks.read' }
      },
      {
        path: '/opd',
        name: 'OPD',
        component: () => import('../views/OPD.vue'),
        meta: { permission: 'opd.read' }
      },
      {
        path: '/analytics',
        name: 'AnalyticsDashboard',
        component: () => import('../views/AnalyticsDashboard.vue'),
        meta: { permission: 'analytics.read' }
      },
      {
        path: '/expert-dashboard',
        name: 'ExpertDashboard',
        component: () => import('../views/ExpertDashboard.vue'),
        meta: { permission: 'dashboard.read' }
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
    // Redirect to first available page after login
    const firstAvailablePath = getFirstAvailablePath(authStore.user)
    next(firstAvailablePath)
  } else if (to.path === '/' && authStore.isAuthenticated) {
    // If accessing root path and authenticated, check if user has permission for dashboard
    if (authStore.user && authStore.user.permissions && authStore.user.permissions.includes('dashboard.read')) {
      next() // Allow access to dashboard
    } else {
      // Redirect to first available page if no dashboard permission
      const firstAvailablePath = getFirstAvailablePath(authStore.user)
      next(firstAvailablePath)
    }
  } else if (to.meta.permission && authStore.isAuthenticated) {
    // Check if user has permission to access this route
    if (!authStore.user || !authStore.user.permissions || !authStore.user.permissions.includes(to.meta.permission)) {
      // Redirect to first available page if no permission
      const firstAvailablePath = getFirstAvailablePath(authStore.user)
      next(firstAvailablePath)
    } else {
      next()
    }
  } else {
    next()
  }
})

// Function to get first available path based on user permissions
function getFirstAvailablePath(user) {
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

// Function to determine dashboard path based on user role (kept for backward compatibility)
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
