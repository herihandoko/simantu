<template>
  <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-4 hover:shadow-md transition-shadow">
    <!-- Task Header -->
    <div class="flex items-start justify-between mb-3">
      <div class="flex-1 min-w-0">
        <h4 class="text-sm font-medium text-gray-900 truncate">
          {{ task.title || task.nama_pekerjaan || 'Untitled Task' }}
        </h4>
        <p class="text-xs text-gray-500 mt-1">
          {{ task.task_id || `TASK-${task.id}` }}
        </p>
      </div>
      
      <!-- Priority Badge -->
      <span class="ml-2 flex-shrink-0 inline-flex items-center px-2 py-1 rounded-full text-xs font-medium"
            :class="getPriorityClass(task.priority || task.prioritas)">
        {{ getPriorityText(task.priority || task.prioritas) }}
      </span>
    </div>

    <!-- Task Description -->
    <div v-if="task.description || task.uraian_tugas" class="mb-3">
      <p class="text-sm text-gray-600 line-clamp-2">
        {{ task.description || task.uraian_tugas }}
      </p>
    </div>

    <!-- Progress Bar -->
    <div v-if="task.progress_percentage !== undefined" class="mb-3">
      <div class="flex items-center justify-between mb-1">
        <span class="text-xs text-gray-500">Progress</span>
        <span class="text-xs text-gray-500">{{ task.progress_percentage }}%</span>
      </div>
      <div class="w-full bg-gray-200 rounded-full h-2">
        <div class="bg-blue-600 h-2 rounded-full transition-all duration-300"
             :style="{ width: task.progress_percentage + '%' }"></div>
      </div>
    </div>

    <!-- Task Meta -->
    <div class="space-y-2">
      <!-- Assigned User -->
      <div v-if="task.assigned_to_name" class="flex items-center space-x-2">
        <div class="w-6 h-6 bg-blue-100 rounded-full flex items-center justify-center">
          <span class="text-xs font-medium text-blue-600">
            {{ getInitials(task.assigned_to_name) }}
          </span>
        </div>
        <span class="text-xs text-gray-600">{{ task.assigned_to_name }}</span>
      </div>

      <!-- OPD -->
      <div v-if="task.nama_opd" class="flex items-center space-x-2">
        <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path>
        </svg>
        <span class="text-xs text-gray-600">{{ task.nama_opd }}</span>
      </div>

      <!-- Due Date -->
      <div v-if="task.due_date || task.tanggal_selesai" class="flex items-center space-x-2">
        <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
        </svg>
        <span class="text-xs text-gray-600">
          {{ formatDate(task.due_date || task.tanggal_selesai) }}
        </span>
      </div>

      <!-- Sub Tasks Count -->
      <div v-if="task.sub_tasks_count > 0" class="flex items-center space-x-2">
        <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path>
        </svg>
        <span class="text-xs text-gray-600">{{ task.sub_tasks_count }} sub-tasks</span>
      </div>
    </div>

    <!-- Task Actions -->
    <div class="flex items-center justify-between mt-4 pt-3 border-t border-gray-100">
      <div class="flex items-center space-x-2">
        <!-- Edit Button -->
        <button @click="$emit('edit', task)" 
                class="p-1 text-gray-400 hover:text-blue-600 transition-colors"
                title="Edit task">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
          </svg>
        </button>
        
        <!-- Delete Button -->
        <button @click="$emit('delete', task)" 
                class="p-1 text-gray-400 hover:text-red-600 transition-colors"
                title="Delete task">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
          </svg>
        </button>
      </div>

      <!-- Created Date -->
      <span class="text-xs text-gray-400">
        {{ formatDate(task.created_at) }}
      </span>
    </div>
  </div>
</template>

<script>
export default {
  name: 'TaskCard',
  props: {
    task: {
      type: Object,
      required: true
    }
  },
  emits: ['edit', 'delete'],
  setup() {
    // Get priority class
    const getPriorityClass = (priority) => {
      const classes = {
        low: 'bg-gray-100 text-gray-800',
        medium: 'bg-yellow-100 text-yellow-800',
        high: 'bg-orange-100 text-orange-800',
        urgent: 'bg-red-100 text-red-800'
      }
      return classes[priority] || 'bg-gray-100 text-gray-800'
    }

    // Get priority text
    const getPriorityText = (priority) => {
      const texts = {
        low: 'Low',
        medium: 'Medium',
        high: 'High',
        urgent: 'Urgent'
      }
      return texts[priority] || 'Medium'
    }

    // Get user initials
    const getInitials = (name) => {
      return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)
    }

    // Format date
    const formatDate = (dateString) => {
      if (!dateString) return ''
      const date = new Date(dateString)
      return date.toLocaleDateString('en-US', {
        month: 'short',
        day: 'numeric',
        year: 'numeric'
      })
    }

    return {
      getPriorityClass,
      getPriorityText,
      getInitials,
      formatDate
    }
  }
}
</script>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
