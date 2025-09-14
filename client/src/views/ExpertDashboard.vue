<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex justify-between items-center">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Dashboard Tenaga Ahli</h1>
        <p class="text-sm text-gray-600">Selamat datang, {{ userInfo?.name || 'Tenaga Ahli' }}</p>
      </div>
      <div class="flex space-x-3">
        <button @click="exportMyReport" class="btn-secondary">
          <component :is="DocumentArrowDownIcon" class="w-4 h-4 mr-2" />
          Export Laporan Saya
        </button>
        <button @click="refreshData" :disabled="isLoading" class="btn-primary">
          <component :is="ArrowPathIcon" class="w-4 h-4 mr-2" :class="{ 'animate-spin': isLoading }" />
          Refresh
        </button>
      </div>
    </div>

    <!-- My Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div class="flex items-center">
          <div class="p-2 bg-primary-100 rounded-lg">
            <component :is="ClipboardDocumentListIcon" class="w-6 h-6 text-primary-600" />
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-600">Total Tugas Saya</p>
            <p class="text-2xl font-bold text-gray-900">{{ userStats?.total_assigned_tasks || 0 }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div class="flex items-center">
          <div class="p-2 bg-green-100 rounded-lg">
            <component :is="CheckCircleIcon" class="w-6 h-6 text-green-600" />
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-600">Selesai</p>
            <p class="text-2xl font-bold text-gray-900">{{ userStats?.completed_tasks || 0 }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div class="flex items-center">
          <div class="p-2 bg-yellow-100 rounded-lg">
            <component :is="ClockIcon" class="w-6 h-6 text-yellow-600" />
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-600">Sedang Dikerjakan</p>
            <p class="text-2xl font-bold text-gray-900">{{ userStats?.in_progress_tasks || 0 }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div class="flex items-center">
          <div class="p-2 bg-red-100 rounded-lg">
            <component :is="ExclamationTriangleIcon" class="w-6 h-6 text-red-600" />
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-600">Overdue</p>
            <p class="text-2xl font-bold text-gray-900">{{ userStats?.overdue_tasks || 0 }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Progress Overview -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- My Progress -->
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h3 class="text-lg font-medium text-gray-900 mb-4">Progress Saya</h3>
        <div class="text-center">
          <div class="relative w-32 h-32 mx-auto mb-4">
            <svg class="w-32 h-32 transform -rotate-90" viewBox="0 0 36 36">
              <path
                d="M18 2.0845
                  a 15.9155 15.9155 0 0 1 0 31.831
                  a 15.9155 15.9155 0 0 1 0 -31.831"
                fill="none"
                stroke="#e5e7eb"
                stroke-width="2"
              />
              <path
                d="M18 2.0845
                  a 15.9155 15.9155 0 0 1 0 31.831
                  a 15.9155 15.9155 0 0 1 0 -31.831"
                fill="none"
                stroke="#16a34a"
                stroke-width="2"
                :stroke-dasharray="`${userStats?.avg_progress || 0}, 100`"
              />
            </svg>
            <div class="absolute inset-0 flex items-center justify-center">
              <span class="text-2xl font-bold text-gray-900">{{ Math.round(userStats?.avg_progress || 0) }}%</span>
            </div>
          </div>
          <p class="text-sm text-gray-600">Rata-rata Progress Tugas</p>
        </div>
      </div>

      <!-- Time Tracking -->
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h3 class="text-lg font-medium text-gray-900 mb-4">Time Tracking</h3>
        <div class="space-y-4">
          <div class="flex justify-between items-center">
            <span class="text-sm font-medium text-gray-600">Estimasi Total</span>
            <span class="text-sm text-gray-900">{{ userStats?.total_estimated_hours || 0 }} jam</span>
          </div>
          <div class="flex justify-between items-center">
            <span class="text-sm font-medium text-gray-600">Aktual Total</span>
            <span class="text-sm text-gray-900">{{ userStats?.total_actual_hours || 0 }} jam</span>
          </div>
          <div class="flex justify-between items-center">
            <span class="text-sm font-medium text-gray-600">Efisiensi</span>
            <span class="text-sm font-medium" :class="getEfficiencyClass()">
              {{ getEfficiencyText() }}
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- My Recent Tasks -->
    <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
      <div class="flex justify-between items-center mb-4">
        <h3 class="text-lg font-medium text-gray-900">Tugas Terbaru Saya</h3>
        <router-link to="/tasks" class="text-sm text-blue-600 hover:text-blue-800">
          Lihat Semua →
        </router-link>
      </div>
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Tugas</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Progress</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Prioritas</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Deadline</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="task in recentTasks" :key="task.id" class="hover:bg-gray-50">
              <td class="px-6 py-4 whitespace-nowrap">
                <div>
                  <div class="text-sm font-medium text-gray-900">{{ task.nama_pekerjaan || task.tugas }}</div>
                  <div class="text-sm text-gray-500">{{ task.nama_opd }}</div>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="inline-flex px-2 py-1 text-xs font-semibold rounded-full"
                      :class="getStatusClass(task.status)">
                  {{ task.status === 'pending' ? 'To Do' : task.status === 'in_progress' ? 'In Progress' : task.status === 'completed' ? 'Done' : 'Cancelled' }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="flex items-center">
                  <div class="w-16 bg-gray-200 rounded-full h-2 mr-2">
                    <div class="bg-primary-600 h-2 rounded-full" :style="{ width: (task.progress_percentage || 0) + '%' }"></div>
                  </div>
                  <span class="text-sm text-gray-600">{{ task.progress_percentage || 0 }}%</span>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="inline-flex px-2 py-1 text-xs font-semibold rounded-full"
                      :class="getPriorityClass(task.prioritas || task.priority)">
                  {{ (task.prioritas || task.priority) === 'low' ? 'Rendah' : (task.prioritas || task.priority) === 'medium' ? 'Sedang' : (task.prioritas || task.priority) === 'high' ? 'Tinggi' : 'Sangat Tinggi' }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {{ task.tanggal_selesai ? formatDate(task.tanggal_selesai) : '-' }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                <div class="flex space-x-2">
                  <button @click="updateProgress(task)" class="text-primary-600 hover:text-primary-900">
                    <component :is="PencilSquareIcon" class="w-4 h-4" />
                  </button>
                  <button @click="viewTask(task)" class="text-green-600 hover:text-green-900">
                    <component :is="EyeIcon" class="w-4 h-4" />
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Progress Update Modal -->
    <div v-if="showProgressModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
        <div class="mt-3">
          <h3 class="text-lg font-medium text-gray-900 mb-4">Update Progress</h3>
          
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Tugas</label>
              <p class="text-sm text-gray-900">{{ selectedTask?.nama_pekerjaan || selectedTask?.tugas }}</p>
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Progress (%)</label>
              <div class="flex items-center space-x-2">
                <input v-model="progressValue" type="range" min="0" max="100" step="5"
                       class="flex-1 h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer">
                <span class="text-sm font-medium text-gray-700 w-12">{{ progressValue }}%</span>
              </div>
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Catatan (Opsional)</label>
              <textarea v-model="progressNote" rows="3"
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                        placeholder="Tambahkan catatan tentang progress..."></textarea>
            </div>
          </div>
          
          <div class="flex justify-end space-x-3 pt-4">
            <button type="button" @click="closeProgressModal" 
                    class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-md">
              Batal
            </button>
            <button type="button" @click="saveProgress" :disabled="isLoading"
                    class="px-4 py-2 text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 rounded-md disabled:opacity-50">
              {{ isLoading ? 'Menyimpan...' : 'Simpan Progress' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'
import {
  ClipboardDocumentListIcon,
  CheckCircleIcon,
  ClockIcon,
  ExclamationTriangleIcon,
  DocumentArrowDownIcon,
  ArrowPathIcon,
  PencilSquareIcon,
  EyeIcon
} from '@heroicons/vue/24/outline'

export default {
  name: 'ExpertDashboard',
  setup() {
    const router = useRouter()
    const userStats = ref({})
    const recentTasks = ref([])
    const userInfo = ref({})
    const isLoading = ref(false)
    const showProgressModal = ref(false)
    const selectedTask = ref(null)
    const progressValue = ref(0)
    const progressNote = ref('')

    const fetchUserInfo = async () => {
      try {
        const response = await axios.get('/api/users/me')
        userInfo.value = response.data
      } catch (error) {
        console.error('Error fetching user info:', error)
      }
    }

    const fetchUserAnalytics = async () => {
      try {
        if (!userInfo.value.id) return
        
        const response = await axios.get(`/api/tasks/analytics/user/${userInfo.value.id}`)
        userStats.value = response.data.userStats
        recentTasks.value = response.data.recentTasks
      } catch (error) {
        console.error('Error fetching user analytics:', error)
      }
    }

    const refreshData = async () => {
      isLoading.value = true
      try {
        await fetchUserInfo()
        await fetchUserAnalytics()
      } finally {
        isLoading.value = false
      }
    }

    const updateProgress = (task) => {
      selectedTask.value = task
      progressValue.value = task.progress_percentage || 0
      progressNote.value = ''
      showProgressModal.value = true
    }

    const saveProgress = async () => {
      try {
        isLoading.value = true
        await axios.patch(`/api/tasks/${selectedTask.value.id}/progress`, {
          progress_percentage: progressValue.value
        })
        
        // Add comment if provided
        if (progressNote.value.trim()) {
          await axios.post(`/api/tasks/${selectedTask.value.id}/comments`, {
            comment: progressNote.value
          })
        }
        
        await refreshData()
        closeProgressModal()
      } catch (error) {
        console.error('Error updating progress:', error)
      } finally {
        isLoading.value = false
      }
    }

    const closeProgressModal = () => {
      showProgressModal.value = false
      selectedTask.value = null
      progressValue.value = 0
      progressNote.value = ''
    }

    const viewTask = (task) => {
      router.push(`/tasks?view=${task.id}`)
    }

    const exportMyReport = async () => {
      try {
        if (!userInfo.value.id) {
          alert('User info tidak ditemukan')
          return
        }
        
        isLoading.value = true
        const response = await axios.get(`/api/tasks/export/user/${userInfo.value.id}/excel`, {
          responseType: 'blob'
        })
        
        const url = window.URL.createObjectURL(new Blob([response.data]))
        const link = document.createElement('a')
        link.href = url
        link.setAttribute('download', `my_tasks_report_${userInfo.value.name?.replace(/\s+/g, '_') || 'user'}.csv`)
        document.body.appendChild(link)
        link.click()
        link.remove()
        window.URL.revokeObjectURL(url)
      } catch (error) {
        console.error('Export error:', error)
        alert('Error saat export data')
      } finally {
        isLoading.value = false
      }
    }

    const getStatusClass = (status) => {
      const classes = {
        pending: 'bg-yellow-100 text-yellow-800',
        in_progress: 'bg-blue-100 text-blue-800',
        completed: 'bg-green-100 text-green-800',
        cancelled: 'bg-red-100 text-red-800'
      }
      return classes[status] || 'bg-gray-100 text-gray-800'
    }

    const getPriorityClass = (priority) => {
      const classes = {
        low: 'bg-gray-100 text-gray-800',
        medium: 'bg-yellow-100 text-yellow-800',
        high: 'bg-orange-100 text-orange-800',
        urgent: 'bg-red-100 text-red-800'
      }
      return classes[priority] || 'bg-gray-100 text-gray-800'
    }

    const getEfficiencyClass = () => {
      const efficiency = getEfficiency()
      if (efficiency >= 90) return 'text-green-600'
      if (efficiency >= 70) return 'text-yellow-600'
      return 'text-red-600'
    }

    const getEfficiencyText = () => {
      const efficiency = getEfficiency()
      if (efficiency >= 90) return 'Excellent'
      if (efficiency >= 70) return 'Good'
      return 'Needs Improvement'
    }

    const getEfficiency = () => {
      const estimated = userStats.value?.total_estimated_hours || 0
      const actual = userStats.value?.total_actual_hours || 0
      if (estimated === 0) return 100
      return Math.round((estimated / actual) * 100)
    }

    const formatDate = (dateString) => {
      return new Date(dateString).toLocaleDateString('id-ID')
    }

    onMounted(() => {
      refreshData()
    })

    return {
      userStats,
      recentTasks,
      userInfo,
      isLoading,
      showProgressModal,
      selectedTask,
      progressValue,
      progressNote,
      fetchUserInfo,
      fetchUserAnalytics,
      refreshData,
      updateProgress,
      saveProgress,
      closeProgressModal,
      viewTask,
      exportMyReport,
      getStatusClass,
      getPriorityClass,
      getEfficiencyClass,
      getEfficiencyText,
      formatDate,
      ClipboardDocumentListIcon,
      CheckCircleIcon,
      ClockIcon,
      ExclamationTriangleIcon,
      DocumentArrowDownIcon,
      ArrowPathIcon,
      PencilSquareIcon,
      EyeIcon
    }
  }
}
</script>
