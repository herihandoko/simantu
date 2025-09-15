<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex justify-between items-center">
      <h1 class="text-2xl font-bold text-gray-900">Dashboard Analytics</h1>
      <div class="flex space-x-3">
        <button @click="exportReport" class="btn-secondary">
          <component :is="DocumentArrowDownIcon" class="w-4 h-4 mr-2" />
          Export Report
        </button>
        <button @click="refreshData" :disabled="isLoading" class="btn-primary">
          <component :is="ArrowPathIcon" class="w-4 h-4 mr-2" :class="{ 'animate-spin': isLoading }" />
          Refresh
        </button>
      </div>
    </div>

    <!-- Overview Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div class="flex items-center">
          <div class="p-2 bg-primary-100 rounded-lg">
            <component :is="ClipboardDocumentListIcon" class="w-6 h-6 text-primary-600" />
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-600">Total Tugas</p>
            <p class="text-2xl font-bold text-gray-900">{{ analytics.overview?.total_tasks || 0 }}</p>
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
            <p class="text-2xl font-bold text-gray-900">{{ analytics.overview?.completed_tasks || 0 }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div class="flex items-center">
          <div class="p-2 bg-yellow-100 rounded-lg">
            <component :is="ClockIcon" class="w-6 h-6 text-yellow-600" />
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-600">In Progress</p>
            <p class="text-2xl font-bold text-gray-900">{{ analytics.overview?.in_progress_tasks || 0 }}</p>
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
            <p class="text-2xl font-bold text-gray-900">{{ analytics.overview?.overdue_tasks || 0 }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Charts Section -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Task Status Distribution -->
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h3 class="text-lg font-medium text-gray-900 mb-4">Distribusi Status Tugas</h3>
        <div class="space-y-3">
          <div v-for="status in statusData" :key="status.name" class="flex items-center justify-between">
            <div class="flex items-center">
              <div class="w-3 h-3 rounded-full mr-3" :class="status.color"></div>
              <span class="text-sm font-medium text-gray-700">{{ status.name }}</span>
            </div>
            <div class="flex items-center space-x-2">
              <div class="w-24 bg-gray-200 rounded-full h-2">
                <div class="h-2 rounded-full" :class="status.color" :style="{ width: status.percentage + '%' }"></div>
              </div>
              <span class="text-sm text-gray-600 w-8">{{ status.count }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Priority Distribution -->
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h3 class="text-lg font-medium text-gray-900 mb-4">Distribusi Prioritas</h3>
        <div class="space-y-3">
          <div v-for="priority in priorityData" :key="priority.name" class="flex items-center justify-between">
            <div class="flex items-center">
              <div class="w-3 h-3 rounded-full mr-3" :class="priority.color"></div>
              <span class="text-sm font-medium text-gray-700">{{ priority.name }}</span>
            </div>
            <div class="flex items-center space-x-2">
              <div class="w-24 bg-gray-200 rounded-full h-2">
                <div class="h-2 rounded-full" :class="priority.color" :style="{ width: priority.percentage + '%' }"></div>
              </div>
              <span class="text-sm text-gray-600 w-8">{{ priority.count }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- OPD Performance -->
    <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
      <h3 class="text-lg font-medium text-gray-900 mb-4">Performance per OPD</h3>
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">OPD</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Total Tugas</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Progress Rata-rata</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="opd in analytics.opdBreakdown" :key="opd.nama_opd">
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                {{ opd.nama_opd }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {{ opd.task_count }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="flex items-center">
                  <div class="w-20 bg-gray-200 rounded-full h-2 mr-2">
                    <div class="bg-primary-600 h-2 rounded-full" :style="{ width: (opd.avg_progress || 0) + '%' }"></div>
                  </div>
                  <span class="text-sm text-gray-600">{{ Math.round(opd.avg_progress || 0) }}%</span>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="inline-flex px-2 py-1 text-xs font-semibold rounded-full"
                      :class="getPerformanceClass(opd.avg_progress)">
                  {{ getPerformanceText(opd.avg_progress) }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Performance Tenaga Ahli & Upcoming Due Dates -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Performance Tenaga Ahli -->
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h3 class="text-lg font-medium text-gray-900 mb-4">Performance Tenaga Ahli</h3>
        <div class="space-y-4">
          <div v-for="expert in analytics.expertPerformance" :key="expert.id" class="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
            <div class="flex items-center space-x-3">
              <div class="w-10 h-10 bg-gradient-to-br from-primary-500 to-primary-600 rounded-full flex items-center justify-center">
                <span class="text-sm font-bold text-white">{{ expert.name.charAt(0) }}</span>
              </div>
              <div>
                <p class="text-sm font-medium text-gray-900">{{ expert.name }}</p>
                <p class="text-xs text-gray-500">{{ expert.email }}</p>
              </div>
            </div>
            <div class="text-right">
              <div class="flex items-center space-x-2">
                <div class="w-16 bg-gray-200 rounded-full h-2">
                  <div class="bg-primary-600 h-2 rounded-full" :style="{ width: (expert.avg_progress || 0) + '%' }"></div>
                </div>
                <span class="text-sm font-medium text-gray-900">{{ Math.round(expert.avg_progress || 0) }}%</span>
              </div>
              <p class="text-xs text-gray-500">{{ expert.task_count }} tugas</p>
            </div>
          </div>
          <div v-if="!analytics.expertPerformance || analytics.expertPerformance.length === 0" class="text-center py-8 text-gray-500">
            <component :is="UserIcon" class="w-12 h-12 mx-auto mb-2 text-gray-300" />
            <p>Belum ada data performance tenaga ahli</p>
          </div>
        </div>
      </div>

      <!-- Progres yang Mau Due Date -->
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h3 class="text-lg font-medium text-gray-900 mb-4">Progres yang Mau Due Date</h3>
        <div class="space-y-3">
          <div v-for="task in analytics.upcomingDeadlines" :key="task.id" class="p-3 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
            <div class="flex items-start justify-between">
              <div class="flex-1">
                <h4 class="text-sm font-medium text-gray-900 mb-1">{{ task.nama_pekerjaan }}</h4>
                <p class="text-xs text-gray-500 mb-2">{{ task.tenaga_ahli_nama || 'Belum ditugaskan' }}</p>
                <div class="flex items-center space-x-2">
                  <div class="w-20 bg-gray-200 rounded-full h-1.5">
                    <div class="bg-primary-600 h-1.5 rounded-full" :style="{ width: (task.progress_percentage || 0) + '%' }"></div>
                  </div>
                  <span class="text-xs text-gray-600">{{ task.progress_percentage || 0 }}%</span>
                </div>
              </div>
              <div class="text-right ml-3">
                <p class="text-xs font-medium" :class="getDeadlineClass(task.tanggal_selesai)">
                  {{ formatDate(task.tanggal_selesai) }}
                </p>
                <p class="text-xs text-gray-500">{{ getDaysUntilDeadline(task.tanggal_selesai) }}</p>
              </div>
            </div>
          </div>
          <div v-if="!analytics.upcomingDeadlines || analytics.upcomingDeadlines.length === 0" class="text-center py-8 text-gray-500">
            <component :is="ClockIcon" class="w-12 h-12 mx-auto mb-2 text-gray-300" />
            <p>Tidak ada tugas yang mendekati deadline</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Recent Activity -->
    <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
      <h3 class="text-lg font-medium text-gray-900 mb-4">Aktivitas Terbaru</h3>
      <div class="space-y-4">
        <div v-for="activity in recentActivities" :key="activity.id" class="flex items-start space-x-3">
          <div class="flex-shrink-0">
            <div class="w-8 h-8 bg-primary-100 rounded-full flex items-center justify-center">
              <component :is="getActivityIcon(activity.icon)" class="w-4 h-4 text-primary-600" />
            </div>
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm text-gray-900">{{ activity.description }}</p>
            <p class="text-xs text-gray-500">{{ formatDateTime(activity.created_at) }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted, computed } from 'vue'
import axios from 'axios'
import {
  ClipboardDocumentListIcon,
  CheckCircleIcon,
  ClockIcon,
  ExclamationTriangleIcon,
  DocumentArrowDownIcon,
  ArrowPathIcon,
  PencilSquareIcon,
  PlusIcon,
  TrashIcon,
  UserIcon
} from '@heroicons/vue/24/outline'

export default {
  name: 'AnalyticsDashboard',
  setup() {
    const analytics = ref({})
    const recentActivities = ref([])
    const isLoading = ref(false)

    const statusData = computed(() => {
      if (!analytics.value.overview) return []
      
      const total = analytics.value.overview.total_tasks || 1
      return [
        {
          name: 'Pending',
          count: analytics.value.overview.pending_tasks || 0,
          percentage: ((analytics.value.overview.pending_tasks || 0) / total) * 100,
          color: 'bg-yellow-500'
        },
        {
          name: 'In Progress',
          count: analytics.value.overview.in_progress_tasks || 0,
          percentage: ((analytics.value.overview.in_progress_tasks || 0) / total) * 100,
          color: 'bg-blue-500'
        },
        {
          name: 'Completed',
          count: analytics.value.overview.completed_tasks || 0,
          percentage: ((analytics.value.overview.completed_tasks || 0) / total) * 100,
          color: 'bg-green-500'
        },
        {
          name: 'Cancelled',
          count: analytics.value.overview.cancelled_tasks || 0,
          percentage: ((analytics.value.overview.cancelled_tasks || 0) / total) * 100,
          color: 'bg-red-500'
        }
      ]
    })

    const priorityData = computed(() => {
      if (!analytics.value.priorityBreakdown) return []
      
      const total = analytics.value.priorityBreakdown.reduce((sum, p) => sum + p.count, 0) || 1
      return analytics.value.priorityBreakdown.map(priority => ({
        name: priority.priority === 'low' ? 'Rendah' : 
              priority.priority === 'medium' ? 'Sedang' : 
              priority.priority === 'high' ? 'Tinggi' : 'Sangat Tinggi',
        count: priority.count,
        percentage: (priority.count / total) * 100,
        color: priority.priority === 'low' ? 'bg-gray-500' :
               priority.priority === 'medium' ? 'bg-yellow-500' :
               priority.priority === 'high' ? 'bg-orange-500' : 'bg-red-500'
      }))
    })

    const fetchAnalytics = async () => {
      try {
        isLoading.value = true
        const response = await axios.get('/api/tasks/analytics/overview')
        analytics.value = response.data
      } catch (error) {
        console.error('Error fetching analytics:', error)
      } finally {
        isLoading.value = false
      }
    }

    const fetchRecentActivities = async () => {
      try {
        // Fetch real recent activities from tasks
        const response = await axios.get('/api/tasks/recent-activities')
        recentActivities.value = response.data
      } catch (error) {
        console.error('Error fetching recent activities:', error)
        // Fallback to empty array if API fails
        recentActivities.value = []
      }
    }

    const refreshData = async () => {
      await Promise.all([
        fetchAnalytics(),
        fetchRecentActivities()
      ])
    }

    const exportReport = async () => {
      try {
        isLoading.value = true
        const response = await axios.get('/api/tasks/export/excel', {
          responseType: 'blob'
        })
        
        const url = window.URL.createObjectURL(new Blob([response.data]))
        const link = document.createElement('a')
        link.href = url
        link.setAttribute('download', 'analytics_report.csv')
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

    const getPerformanceClass = (avgProgress) => {
      if (avgProgress >= 80) return 'bg-green-100 text-green-800'
      if (avgProgress >= 60) return 'bg-yellow-100 text-yellow-800'
      return 'bg-red-100 text-red-800'
    }

    const getPerformanceText = (avgProgress) => {
      if (avgProgress >= 80) return 'Excellent'
      if (avgProgress >= 60) return 'Good'
      return 'Needs Improvement'
    }

    const formatDateTime = (dateString) => {
      const date = new Date(dateString)
      return date.toLocaleDateString('id-ID', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      })
    }

    const formatDate = (dateString) => {
      if (!dateString) return 'Tidak ada deadline'
      const date = new Date(dateString)
      return date.toLocaleDateString('id-ID', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      })
    }

    const getDaysUntilDeadline = (dateString) => {
      if (!dateString) return 'Tidak ada deadline'
      const deadline = new Date(dateString)
      const today = new Date()
      const diffTime = deadline - today
      const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))
      
      if (diffDays < 0) return `${Math.abs(diffDays)} hari terlambat`
      if (diffDays === 0) return 'Hari ini'
      if (diffDays === 1) return 'Besok'
      return `${diffDays} hari lagi`
    }

    const getDeadlineClass = (dateString) => {
      if (!dateString) return 'text-gray-500'
      const deadline = new Date(dateString)
      const today = new Date()
      const diffTime = deadline - today
      const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))
      
      if (diffDays < 0) return 'text-red-600'
      if (diffDays <= 1) return 'text-orange-600'
      if (diffDays <= 3) return 'text-yellow-600'
      return 'text-gray-600'
    }

    const getActivityIcon = (iconName) => {
      const iconMap = {
        'CheckCircleIcon': CheckCircleIcon,
        'ClockIcon': ClockIcon,
        'PlusIcon': PlusIcon,
        'PencilSquareIcon': PencilSquareIcon
      }
      return iconMap[iconName] || PencilSquareIcon
    }

    onMounted(() => {
      refreshData()
    })

    return {
      analytics,
      recentActivities,
      isLoading,
      statusData,
      priorityData,
      fetchAnalytics,
      fetchRecentActivities,
      refreshData,
      exportReport,
      getPerformanceClass,
      getPerformanceText,
      formatDateTime,
      formatDate,
      getDaysUntilDeadline,
      getDeadlineClass,
      getActivityIcon,
      ClipboardDocumentListIcon,
      CheckCircleIcon,
      ClockIcon,
      ExclamationTriangleIcon,
      DocumentArrowDownIcon,
      ArrowPathIcon,
      PencilSquareIcon,
      PlusIcon,
      TrashIcon,
      UserIcon
    }
  }
}
</script>
