<template>
  <div class="p-6">
    <!-- Header -->
    <div class="mb-6">
      <div class="flex justify-between items-center">
        <div>
          <h1 class="text-2xl font-bold text-gray-900">Task Board</h1>
          <p class="text-gray-600">Drag and drop tasks to update their status</p>
          <div v-if="authStore.user && authStore.user.role && authStore.user.role.toLowerCase() === 'tenaga ahli'" 
               class="mt-2 inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-blue-100 text-blue-800">
            <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
            </svg>
            Showing only your assigned tasks
          </div>
          <div v-else class="mt-2 inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800">
            <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
            Showing all tasks ({{ authStore.user?.role || 'User' }})
          </div>
        </div>
        <div class="flex space-x-3">
          <button @click="refreshBoard" 
                  class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 flex items-center space-x-2">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
            </svg>
            <span>Refresh</span>
          </button>
          <button @click="openCreateModal" 
                  class="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 flex items-center space-x-2">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
            </svg>
            <span>Add Task</span>
          </button>
        </div>
      </div>
    </div>

    <!-- Board Container -->
    <div class="flex space-x-6 overflow-x-auto pb-6">
      <!-- To Do Column -->
      <div class="flex-shrink-0 w-80">
        <div class="bg-gray-50 rounded-lg p-4 min-h-96">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-semibold text-gray-800">To Do</h3>
            <span class="bg-gray-200 text-gray-700 px-2 py-1 rounded-full text-sm font-medium">
              {{ getTasksByStatus('pending').length }}
            </span>
          </div>
          <div class="space-y-3" 
               @drop="handleDrop($event, 'pending')" 
               @dragover="handleDragOver"
               @dragenter="handleDragEnter">
            <div v-for="task in getTasksByStatus('pending')" 
                 :key="task.id"
                 class="bg-white rounded-lg shadow-sm border border-gray-200 p-4 cursor-move hover:shadow-md transition-shadow"
                 :draggable="true"
                 @dragstart="handleDragStart($event, task)"
                 @dragend="handleDragEnd($event)">
              <TaskCard :task="task" @edit="editTask" @delete="deleteTask" />
            </div>
            <div v-if="getTasksByStatus('pending').length === 0" 
                 class="text-center py-8 text-gray-500">
              <svg class="w-12 h-12 mx-auto mb-2 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
              </svg>
              <p>No tasks</p>
            </div>
          </div>
        </div>
      </div>

      <!-- In Progress Column -->
      <div class="flex-shrink-0 w-80">
        <div class="bg-blue-50 rounded-lg p-4 min-h-96">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-semibold text-blue-800">In Progress</h3>
            <span class="bg-blue-200 text-blue-700 px-2 py-1 rounded-full text-sm font-medium">
              {{ getTasksByStatus('in_progress').length }}
            </span>
          </div>
          <div class="space-y-3" 
               @drop="handleDrop($event, 'in_progress')" 
               @dragover="handleDragOver"
               @dragenter="handleDragEnter">
            <div v-for="task in getTasksByStatus('in_progress')" 
                 :key="task.id"
                 class="bg-white rounded-lg shadow-sm border border-gray-200 p-4 cursor-move hover:shadow-md transition-shadow"
                 :draggable="true"
                 @dragstart="handleDragStart($event, task)"
                 @dragend="handleDragEnd($event)">
              <TaskCard :task="task" @edit="editTask" @delete="deleteTask" />
            </div>
            <div v-if="getTasksByStatus('in_progress').length === 0" 
                 class="text-center py-8 text-gray-500">
              <svg class="w-12 h-12 mx-auto mb-2 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
              </svg>
              <p>No tasks</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Done Column -->
      <div class="flex-shrink-0 w-80">
        <div class="bg-green-50 rounded-lg p-4 min-h-96">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-semibold text-green-800">Done</h3>
            <span class="bg-green-200 text-green-700 px-2 py-1 rounded-full text-sm font-medium">
              {{ getTasksByStatus('completed').length }}
            </span>
          </div>
          <div class="space-y-3" 
               @drop="handleDrop($event, 'completed')" 
               @dragover="handleDragOver"
               @dragenter="handleDragEnter">
            <div v-for="task in getTasksByStatus('completed')" 
                 :key="task.id"
                 class="bg-white rounded-lg shadow-sm border border-gray-200 p-4 cursor-move hover:shadow-md transition-shadow"
                 :draggable="true"
                 @dragstart="handleDragStart($event, task)"
                 @dragend="handleDragEnd($event)">
              <TaskCard :task="task" @edit="editTask" @delete="deleteTask" />
            </div>
            <div v-if="getTasksByStatus('completed').length === 0" 
                 class="text-center py-8 text-gray-500">
              <svg class="w-12 h-12 mx-auto mb-2 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
              </svg>
              <p>No tasks</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Cancelled Column -->
      <div class="flex-shrink-0 w-80">
        <div class="bg-red-50 rounded-lg p-4 min-h-96">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-semibold text-red-800">Cancelled</h3>
            <span class="bg-red-200 text-red-700 px-2 py-1 rounded-full text-sm font-medium">
              {{ getTasksByStatus('cancelled').length }}
            </span>
          </div>
          <div class="space-y-3" 
               @drop="handleDrop($event, 'cancelled')" 
               @dragover="handleDragOver"
               @dragenter="handleDragEnter">
            <div v-for="task in getTasksByStatus('cancelled')" 
                 :key="task.id"
                 class="bg-white rounded-lg shadow-sm border border-gray-200 p-4 cursor-move hover:shadow-md transition-shadow"
                 :draggable="true"
                 @dragstart="handleDragStart($event, task)"
                 @dragend="handleDragEnd($event)">
              <TaskCard :task="task" @edit="editTask" @delete="deleteTask" />
            </div>
            <div v-if="getTasksByStatus('cancelled').length === 0" 
                 class="text-center py-8 text-gray-500">
              <svg class="w-12 h-12 mx-auto mb-2 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
              </svg>
              <p>No tasks</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Create/Edit Task Modal -->
    <div v-if="showCreateModal || showEditModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div class="relative top-10 mx-auto p-5 border w-11/12 max-w-4xl shadow-lg rounded-md bg-white">
        <div class="mt-3">
          <h3 class="text-lg font-medium text-gray-900 mb-4">
            {{ showEditModal ? 'Edit Task' : 'Create New Task' }}
          </h3>
          
          <form @submit.prevent="handleSubmit" class="space-y-4">
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
              <!-- Task Title -->
              <div class="lg:col-span-2">
                <label class="block text-sm font-medium text-gray-700 mb-1">Task Title</label>
                <input v-model="form.title" type="text" required
                       class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500">
              </div>
              
              <!-- Description -->
              <div class="lg:col-span-2">
                <label class="block text-sm font-medium text-gray-700 mb-1">Description</label>
                <textarea v-model="form.description" rows="3"
                          class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"></textarea>
              </div>
              
              <!-- Status -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Status</label>
                <select v-model="form.status" 
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500">
                  <option value="pending">To Do</option>
                  <option value="in_progress">In Progress</option>
                  <option value="completed">Done</option>
                  <option value="cancelled">Cancelled</option>
                </select>
              </div>
              
              <!-- Priority -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Priority</label>
                <select v-model="form.priority" 
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500">
                  <option value="low">Low</option>
                  <option value="medium">Medium</option>
                  <option value="high">High</option>
                  <option value="urgent">Urgent</option>
                </select>
              </div>
              
              <!-- Due Date -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Due Date</label>
                <input v-model="form.due_date" type="date"
                       class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500">
              </div>
              
              <!-- Assigned To -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Assigned To</label>
                <select v-model="form.assigned_to" 
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500">
                  <option value="">Select User</option>
                  <option v-for="user in users" :key="user.id" :value="user.id">
                    {{ user.name }}
                  </option>
                </select>
              </div>
            </div>
            
            <div class="flex justify-end space-x-3 pt-4">
              <button type="button" @click="closeModal" 
                      class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-md">
                Cancel
              </button>
              <button type="submit" :disabled="isLoading"
                      class="px-4 py-2 text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 rounded-md disabled:opacity-50">
                {{ isLoading ? 'Saving...' : 'Save Task' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted, computed } from 'vue'
import axios from 'axios'
import { useAuthStore } from '../stores/auth'
import Swal from 'sweetalert2'
import TaskCard from '../components/TaskCard.vue'

export default {
  name: 'Board',
  components: {
    TaskCard
  },
  setup() {
    const authStore = useAuthStore()
    const tasks = ref([])
    const users = ref([])
    const showCreateModal = ref(false)
    const showEditModal = ref(false)
    const isLoading = ref(false)
    const editingTask = ref(null)
    const draggedTask = ref(null)

    const form = ref({
      title: '',
      description: '',
      status: 'pending',
      priority: 'medium',
      due_date: '',
      assigned_to: ''
    })

    // Get tasks by status
    const getTasksByStatus = (status) => {
      return tasks.value.filter(task => task.status === status)
    }

    // Drag and Drop handlers
    const handleDragStart = (event, task) => {
      draggedTask.value = task
      event.dataTransfer.effectAllowed = 'move'
      event.dataTransfer.setData('text/html', event.target.outerHTML)
      event.target.style.opacity = '0.5'
      event.target.style.transform = 'rotate(5deg)'
    }

    const handleDragEnd = (event) => {
      event.target.style.opacity = '1'
      event.target.style.transform = 'rotate(0deg)'
    }

    const handleDragOver = (event) => {
      event.preventDefault()
      event.dataTransfer.dropEffect = 'move'
    }

    const handleDragEnter = (event) => {
      event.preventDefault()
      event.target.closest('.space-y-3').classList.add('bg-blue-100', 'border-2', 'border-blue-300', 'border-dashed')
    }

    const handleDrop = async (event, newStatus) => {
      event.preventDefault()
      const dropZone = event.target.closest('.space-y-3')
      dropZone.classList.remove('bg-blue-100', 'border-2', 'border-blue-300', 'border-dashed')
      
      if (draggedTask.value && draggedTask.value.status !== newStatus) {
        try {
          // Show loading state
          const loadingToast = Swal.fire({
            title: 'Updating...',
            text: 'Please wait while we update the task status.',
            allowOutsideClick: false,
            showConfirmButton: false,
            didOpen: () => {
              Swal.showLoading()
            }
          })

          await updateTaskStatus(draggedTask.value.id, newStatus)
          
          // Update the task in the local array
          const taskIndex = tasks.value.findIndex(t => t.id === draggedTask.value.id)
          if (taskIndex !== -1) {
            tasks.value[taskIndex].status = newStatus
          }

          // Close loading and show success
          await Swal.close()
          Swal.fire({
            title: 'Success!',
            text: 'Task status updated successfully.',
            icon: 'success',
            timer: 2000,
            showConfirmButton: false
          })
        } catch (error) {
          console.error('Error updating task status:', error)
          await Swal.close()
          Swal.fire({
            title: 'Error!',
            text: 'Failed to update task status. Please try again.',
            icon: 'error'
          })
        }
      }
      
      draggedTask.value = null
    }

    // Update task status
    const updateTaskStatus = async (taskId, newStatus) => {
      try {
        // Find the task to get its current data
        const task = tasks.value.find(t => t.id === taskId)
        if (!task) {
          throw new Error('Task not found')
        }

        // Prepare update data with current task data
        const updateData = {
          nama_pekerjaan: task.nama_pekerjaan || task.title || '',
          status: newStatus,
          tugas: task.tugas || task.title || '',
          uraian_tugas: task.uraian_tugas || task.description || '',
          prioritas: task.prioritas || task.priority || 'medium',
          opd_id: task.opd_id || null,
          tenaga_ahli_id: task.tenaga_ahli_id || null,
          tanggal_selesai: task.tanggal_selesai || task.due_date || null,
          estimasi_durasi: task.estimasi_durasi || null,
          progress_percentage: task.progress_percentage || 0,
          tags: task.tags || [],
          estimated_hours: task.estimated_hours || null,
          start_date: task.start_date || null,
          milestone: task.milestone || null,
          risk_level: task.risk_level || 'low',
          complexity: task.complexity || 'moderate',
          sub_tasks: task.sub_tasks || [],
          narasi_pekerjaan: task.narasi_pekerjaan || null,
          evidence_files: task.evidence_files || [],
          link_url: task.link_url || null,
          status_update: task.status_update || null
        }

        await axios.put(`/api/tasks/${taskId}`, updateData)
      } catch (error) {
        console.error('Error updating task:', error)
        throw error
      }
    }

    // Fetch tasks
    const fetchTasks = async () => {
      try {
        let response
        // Filter data berdasarkan role
        if (authStore.user && authStore.user.role && authStore.user.role.toLowerCase() === 'tenaga ahli') {
          // Untuk Tenaga Ahli, hanya tampilkan tasks yang assigned ke user tersebut
          response = await axios.get(`/api/tasks/user/${authStore.user.id}`)
        } else {
          // Untuk role lain, tampilkan semua tasks
          response = await axios.get('/api/tasks')
        }
        tasks.value = response.data
      } catch (error) {
        console.error('Error fetching tasks:', error)
      }
    }

    // Fetch users
    const fetchUsers = async () => {
      try {
        const response = await axios.get('/api/users')
        users.value = response.data
      } catch (error) {
        console.error('Error fetching users:', error)
      }
    }

    // Refresh board
    const refreshBoard = async () => {
      await fetchTasks()
      Swal.fire({
        title: 'Refreshed!',
        text: 'Board data has been updated.',
        icon: 'success',
        timer: 1500,
        showConfirmButton: false
      })
    }

    // Open create modal
    const openCreateModal = () => {
      showCreateModal.value = true
      form.value = {
        title: '',
        description: '',
        status: 'pending',
        priority: 'medium',
        due_date: '',
        assigned_to: ''
      }
    }

    // Edit task
    const editTask = (task) => {
      editingTask.value = task
      form.value = {
        title: task.title || task.nama_pekerjaan || '',
        description: task.description || task.uraian_tugas || '',
        status: task.status,
        priority: task.priority || task.prioritas || 'medium',
        due_date: task.due_date || task.tanggal_selesai || '',
        assigned_to: task.assigned_to || ''
      }
      showEditModal.value = true
    }

    // Delete task
    const deleteTask = async (task) => {
      const result = await Swal.fire({
        title: 'Are you sure?',
        text: 'This task will be deleted permanently!',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d33',
        cancelButtonColor: '#3085d6',
        confirmButtonText: 'Yes, delete it!'
      })

      if (result.isConfirmed) {
        try {
          await axios.delete(`/api/tasks/${task.id}`)
          tasks.value = tasks.value.filter(t => t.id !== task.id)
          Swal.fire('Deleted!', 'Task has been deleted.', 'success')
        } catch (error) {
          console.error('Error deleting task:', error)
          Swal.fire('Error!', 'Failed to delete task.', 'error')
        }
      }
    }

    // Handle form submit
    const handleSubmit = async () => {
      try {
        isLoading.value = true
        
        if (showEditModal.value) {
          await axios.put(`/api/tasks/${editingTask.value.id}`, form.value)
          const index = tasks.value.findIndex(t => t.id === editingTask.value.id)
          if (index !== -1) {
            tasks.value[index] = { ...tasks.value[index], ...form.value }
          }
        } else {
          const response = await axios.post('/api/tasks', form.value)
          tasks.value.unshift(response.data)
        }
        
        closeModal()
        Swal.fire('Success!', 'Task saved successfully.', 'success')
      } catch (error) {
        console.error('Error saving task:', error)
        Swal.fire('Error!', 'Failed to save task.', 'error')
      } finally {
        isLoading.value = false
      }
    }

    // Close modal
    const closeModal = () => {
      showCreateModal.value = false
      showEditModal.value = false
      editingTask.value = null
    }

    onMounted(async () => {
      await fetchTasks()
      await fetchUsers()
    })

    return {
      authStore,
      tasks,
      users,
      showCreateModal,
      showEditModal,
      isLoading,
      editingTask,
      form,
      getTasksByStatus,
      handleDragStart,
      handleDragEnd,
      handleDragOver,
      handleDragEnter,
      handleDrop,
      refreshBoard,
      openCreateModal,
      editTask,
      deleteTask,
      handleSubmit,
      closeModal
    }
  }
}
</script>
