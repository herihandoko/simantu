<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex justify-between items-center">
      <h1 class="text-2xl font-bold text-gray-900">User Management</h1>
      <button @click="showCreateModal = true" class="btn-primary">
        <component :is="PlusIcon" class="w-4 h-4 mr-2" />
        Add User
      </button>
    </div>

    <!-- Users Table -->
    <div class="card">
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">User</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Role</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Created</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="user in users" :key="user.id" class="hover:bg-gray-50">
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="flex items-center">
                  <div class="w-10 h-10 bg-primary-100 rounded-full flex items-center justify-center">
                    <span class="text-sm font-medium text-primary-600">{{ user.name.charAt(0) }}</span>
                  </div>
                  <div class="ml-4">
                    <div class="text-sm font-medium text-gray-900">{{ user.name }}</div>
                    <div class="text-sm text-gray-500">{{ user.email }}</div>
                  </div>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                  {{ user.role || 'No Role' }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ formatDate(user.created_at) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                <div class="flex space-x-2">
                  <button @click="editUser(user)" class="text-indigo-600 hover:text-indigo-900">
                    <component :is="PencilSquareIcon" class="w-4 h-4" />
                  </button>
                  <button @click="deleteUser(user)" class="text-red-600 hover:text-red-900">
                    <component :is="TrashIcon" class="w-4 h-4" />
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Create/Edit User Modal -->
    <div v-if="showCreateModal || showEditModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
        <div class="mt-3">
          <h3 class="text-lg font-medium text-gray-900 mb-4">
            {{ showCreateModal ? 'Create User' : 'Edit User' }}
          </h3>
          
          <form @submit.prevent="handleSubmit">
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700">Name</label>
                <input
                  v-model="form.name"
                  type="text"
                  required
                  class="input-field mt-1"
                  placeholder="Enter name"
                />
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700">Email</label>
                <input
                  v-model="form.email"
                  type="email"
                  required
                  class="input-field mt-1"
                  placeholder="Enter email"
                />
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700">Password</label>
                <input
                  v-model="form.password"
                  type="password"
                  :required="showCreateModal"
                  class="input-field mt-1"
                  :placeholder="showCreateModal ? 'Enter password' : 'Leave empty to keep current password'"
                />
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700">Role</label>
                <select v-model="form.role_id" required class="input-field mt-1">
                  <option value="">Select a role</option>
                  <option v-for="role in roles" :key="role.id" :value="role.id">
                    {{ role.name }}
                  </option>
                </select>
              </div>
            </div>
            
            <div class="flex justify-end space-x-3 mt-6">
              <button type="button" @click="closeModal" class="btn-secondary">
                Cancel
              </button>
              <button type="submit" class="btn-primary">
                {{ showCreateModal ? 'Create' : 'Update' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, reactive, onMounted } from 'vue'
import axios from 'axios'
import Swal from 'sweetalert2'
import {
  PlusIcon,
  PencilSquareIcon,
  TrashIcon
} from '@heroicons/vue/24/outline'

export default {
  name: 'Users',
  setup() {
    const users = ref([])
    const roles = ref([])
    const showCreateModal = ref(false)
    const showEditModal = ref(false)
    const editingUser = ref(null)
    
    const form = reactive({
      name: '',
      email: '',
      password: '',
      role_id: ''
    })

    const formatDate = (dateString) => {
      return new Date(dateString).toLocaleDateString()
    }

    const fetchUsers = async () => {
      try {
        const response = await axios.get('/api/users')
        users.value = response.data
      } catch (error) {
        console.error('Error fetching users:', error)
      }
    }

    const fetchRoles = async () => {
      try {
        const response = await axios.get('/api/roles')
        roles.value = response.data
      } catch (error) {
        console.error('Error fetching roles:', error)
      }
    }

    const handleSubmit = async () => {
      try {
        // Prepare data for submission
        const submitData = { ...form }
        
        // For update, don't send password if it's empty
        if (!showCreateModal.value && !submitData.password) {
          delete submitData.password
        }
        
        if (showCreateModal.value) {
          await axios.post('/api/users', submitData)
          await Swal.fire({
            icon: 'success',
            title: 'Success!',
            text: 'User created successfully',
            timer: 2000,
            showConfirmButton: false
          })
        } else {
          await axios.put(`/api/users/${editingUser.value.id}`, submitData)
          await Swal.fire({
            icon: 'success',
            title: 'Success!',
            text: 'User updated successfully',
            timer: 2000,
            showConfirmButton: false
          })
        }
        
        await fetchUsers()
        closeModal()
        resetForm()
      } catch (error) {
        console.error('Error saving user:', error)
        const errorMessage = error.response?.data?.message || 'Unknown error'
        await Swal.fire({
          icon: 'error',
          title: 'Error!',
          text: `Error saving user: ${errorMessage}`,
          confirmButtonText: 'OK'
        })
      }
    }

    const editUser = (user) => {
      editingUser.value = user
      form.name = user.name
      form.email = user.email
      form.password = ''
      form.role_id = user.role_id
      showEditModal.value = true
    }

    const deleteUser = async (user) => {
      const result = await Swal.fire({
        title: 'Are you sure?',
        text: `You are about to delete ${user.name}. This action cannot be undone!`,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d33',
        cancelButtonColor: '#3085d6',
        confirmButtonText: 'Yes, delete it!',
        cancelButtonText: 'Cancel'
      })

      if (result.isConfirmed) {
        try {
          await axios.delete(`/api/users/${user.id}`)
          await Swal.fire({
            icon: 'success',
            title: 'Deleted!',
            text: `${user.name} has been deleted successfully`,
            timer: 2000,
            showConfirmButton: false
          })
          await fetchUsers()
        } catch (error) {
          console.error('Error deleting user:', error)
          const errorMessage = error.response?.data?.message || 'Unknown error'
          await Swal.fire({
            icon: 'error',
            title: 'Error!',
            text: `Error deleting user: ${errorMessage}`,
            confirmButtonText: 'OK'
          })
        }
      }
    }

    const closeModal = () => {
      showCreateModal.value = false
      showEditModal.value = false
      editingUser.value = null
      resetForm()
    }

    const resetForm = () => {
      form.name = ''
      form.email = ''
      form.password = ''
      form.role_id = ''
    }

    onMounted(() => {
      fetchUsers()
      fetchRoles()
    })

    return {
      users,
      roles,
      form,
      showCreateModal,
      showEditModal,
      formatDate,
      handleSubmit,
      editUser,
      deleteUser,
      closeModal,
      PlusIcon,
      PencilSquareIcon,
      TrashIcon
    }
  }
}
</script>
