<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex justify-between items-center">
      <h1 class="text-2xl font-bold text-gray-900">Role Management</h1>
      <button @click="showCreateModal = true" class="btn-primary">
        <component :is="PlusIcon" class="w-4 h-4 mr-2" />
        Add Role
      </button>
    </div>

    <!-- Roles Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div v-for="role in roles" :key="role.id" class="card">
        <div class="flex justify-between items-start mb-4">
          <div>
            <h3 class="text-lg font-semibold text-gray-900">{{ role.name }}</h3>
            <p class="text-sm text-gray-600">{{ role.description || 'No description' }}</p>
          </div>
          <div class="flex space-x-2">
            <button @click="editRole(role)" class="text-indigo-600 hover:text-indigo-900">
              <component :is="PencilSquareIcon" class="w-4 h-4" />
            </button>
            <button @click="deleteRole(role)" class="text-red-600 hover:text-red-900">
              <component :is="TrashIcon" class="w-4 h-4" />
            </button>
          </div>
        </div>
        
        <div class="space-y-2">
          <div class="flex justify-between text-sm">
            <span class="text-gray-600">Users:</span>
            <span class="font-medium">{{ role.user_count }}</span>
          </div>
          <div class="flex justify-between text-sm">
            <span class="text-gray-600">Created:</span>
            <span class="font-medium">{{ formatDate(role.created_at) }}</span>
          </div>
        </div>
        
        <div v-if="role.permissions && role.permissions.length > 0" class="mt-4">
          <h4 class="text-sm font-medium text-gray-700 mb-2">Permissions:</h4>
          <div class="flex flex-wrap gap-1">
            <span
              v-for="permission in role.permissions.slice(0, 3)"
              :key="permission"
              class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800"
            >
              {{ permission }}
            </span>
            <span
              v-if="role.permissions.length > 3"
              class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-gray-100 text-gray-800"
            >
              +{{ role.permissions.length - 3 }} more
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- Create/Edit Role Modal -->
    <div v-if="showCreateModal || showEditModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
        <div class="mt-3">
          <h3 class="text-lg font-medium text-gray-900 mb-4">
            {{ showCreateModal ? 'Create Role' : 'Edit Role' }}
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
                  placeholder="Enter role name"
                />
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700">Description</label>
                <textarea
                  v-model="form.description"
                  rows="3"
                  class="input-field mt-1"
                  placeholder="Enter role description"
                ></textarea>
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Permissions</label>
                <div class="space-y-2 max-h-40 overflow-y-auto border border-gray-200 rounded-lg p-3">
                  <label v-for="permission in availablePermissions" :key="permission" class="flex items-center">
                    <input
                      v-model="form.permissions"
                      :value="permission"
                      type="checkbox"
                      class="rounded border-gray-300 text-primary-600 focus:ring-primary-500"
                    />
                    <span class="ml-2 text-sm text-gray-700">{{ permission }}</span>
                  </label>
                </div>
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
import {
  PlusIcon,
  PencilSquareIcon,
  TrashIcon
} from '@heroicons/vue/24/outline'

export default {
  name: 'Roles',
  setup() {
    const roles = ref([])
    const showCreateModal = ref(false)
    const showEditModal = ref(false)
    const editingRole = ref(null)
    
    const form = reactive({
      name: '',
      description: '',
      permissions: []
    })

    const availablePermissions = [
      'users.read',
      'users.create',
      'users.update',
      'users.delete',
      'roles.read',
      'roles.create',
      'roles.update',
      'roles.delete',
      'configs.read',
      'configs.create',
      'configs.update',
      'configs.delete'
    ]

    const formatDate = (dateString) => {
      return new Date(dateString).toLocaleDateString()
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
        const roleData = {
          ...form,
          permissions: form.permissions
        }

        if (showCreateModal.value) {
          await axios.post('/api/roles', roleData)
        } else {
          await axios.put(`/api/roles/${editingRole.value.id}`, roleData)
        }
        
        await fetchRoles()
        closeModal()
        resetForm()
      } catch (error) {
        console.error('Error saving role:', error)
        alert('Error saving role: ' + (error.response?.data?.message || 'Unknown error'))
      }
    }

    const editRole = (role) => {
      editingRole.value = role
      form.name = role.name
      form.description = role.description || ''
      form.permissions = role.permissions || []
      showEditModal.value = true
    }

    const deleteRole = async (role) => {
      if (role.user_count > 0) {
        alert('Cannot delete role that is assigned to users')
        return
      }

      if (confirm(`Are you sure you want to delete ${role.name}?`)) {
        try {
          await axios.delete(`/api/roles/${role.id}`)
          await fetchRoles()
        } catch (error) {
          console.error('Error deleting role:', error)
          alert('Error deleting role: ' + (error.response?.data?.message || 'Unknown error'))
        }
      }
    }

    const closeModal = () => {
      showCreateModal.value = false
      showEditModal.value = false
      editingRole.value = null
      resetForm()
    }

    const resetForm = () => {
      form.name = ''
      form.description = ''
      form.permissions = []
    }

    onMounted(() => {
      fetchRoles()
    })

    return {
      roles,
      form,
      showCreateModal,
      showEditModal,
      availablePermissions,
      formatDate,
      handleSubmit,
      editRole,
      deleteRole,
      closeModal,
      PlusIcon,
      PencilSquareIcon,
      TrashIcon
    }
  }
}
</script>
