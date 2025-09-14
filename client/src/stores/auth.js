import { defineStore } from 'pinia'
import axios from 'axios'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    token: localStorage.getItem('token') || null,
    isLoading: false
  }),


  getters: {
    isAuthenticated: (state) => !!state.token,
    userRole: (state) => state.user?.role || null
  },

  actions: {
    init() {
      if (this.token) {
        axios.defaults.headers.common['Authorization'] = `Bearer ${this.token}`
      } else {
        delete axios.defaults.headers.common['Authorization']
      }
    },

    async login(credentials) {
      this.isLoading = true
      console.log('Auth store: Starting login with credentials:', credentials)
      try {
        const response = await axios.post('/api/auth/login', credentials)
        console.log('Auth store: Login response:', response.data)
        const { token, user } = response.data
        
        this.token = token
        this.user = user
        localStorage.setItem('token', token)
        
        axios.defaults.headers.common['Authorization'] = `Bearer ${token}`
        console.log('Auth store: Login successful, user set:', this.user)
        return { success: true }
      } catch (error) {
        console.error('Auth store: Login error:', error)
        return {
          success: false,
          message: error.response?.data?.message || 'Login failed'
        }
      } finally {
        this.isLoading = false
      }
    },

    async logout() {
      this.user = null
      this.token = null
      localStorage.removeItem('token')
      delete axios.defaults.headers.common['Authorization']
    },

    async fetchUser() {
      if (!this.token) return
      
      try {
        axios.defaults.headers.common['Authorization'] = `Bearer ${this.token}`
        const response = await axios.get('/api/auth/me')
        this.user = response.data
      } catch (error) {
        this.logout()
      }
    }
  }
})
