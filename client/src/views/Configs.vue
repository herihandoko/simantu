<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex justify-between items-center">
      <h1 class="text-2xl font-bold text-gray-900">Configuration Management</h1>
      <button @click="showCreateModal = true" class="btn-primary">
        <component :is="PlusIcon" class="w-4 h-4 mr-2" />
        Add Configuration
      </button>
    </div>

    <!-- Category Filter -->
    <div class="flex space-x-2">
      <button
        v-for="category in categories"
        :key="category"
        @click="selectedCategory = category"
        :class="[
          'px-4 py-2 rounded-lg text-sm font-medium transition-colors duration-200',
          selectedCategory === category
            ? 'bg-primary-600 text-white'
            : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
        ]"
      >
        {{ category }}
      </button>
    </div>

    <!-- Configurations Table -->
    <div class="card">
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Key</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Value</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Type</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Description</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="config in filteredConfigs" :key="config.id" class="hover:bg-gray-50">
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm font-medium text-gray-900">{{ config.key_name }}</div>
                <div class="text-sm text-gray-500">{{ config.category }}</div>
              </td>
              <td class="px-6 py-4">
                <div class="text-sm text-gray-900 max-w-xs truncate">
                  {{ formatValue(config.value, config.data_type) }}
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                  {{ config.data_type }}
                </span>
              </td>
              <td class="px-6 py-4">
                <div class="text-sm text-gray-500 max-w-xs truncate">
                  {{ config.description || 'No description' }}
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                <div class="flex space-x-2">
                  <button @click="editConfig(config)" class="text-indigo-600 hover:text-indigo-900">
                    <component :is="PencilSquareIcon" class="w-4 h-4" />
                  </button>
                  <button @click="deleteConfig(config)" class="text-red-600 hover:text-red-900">
                    <component :is="TrashIcon" class="w-4 h-4" />
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Create/Edit Config Modal -->
    <div v-if="showCreateModal || showEditModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
        <div class="mt-3">
          <h3 class="text-lg font-medium text-gray-900 mb-4">
            {{ showCreateModal ? 'Create Configuration' : 'Edit Configuration' }}
          </h3>
          
          <form @submit.prevent="handleSubmit">
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700">Key Name</label>
                <input
                  v-model="form.key_name"
                  type="text"
                  required
                  class="input-field mt-1"
                  placeholder="Enter key name"
                />
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700">Category</label>
                <input
                  v-model="form.category"
                  type="text"
                  required
                  class="input-field mt-1"
                  placeholder="Enter category"
                />
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700">Data Type</label>
                <select v-model="form.data_type" required class="input-field mt-1">
                  <option value="string">String</option>
                  <option value="number">Number</option>
                  <option value="boolean">Boolean</option>
                  <option value="json">JSON</option>
                </select>
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700">Value</label>
                <textarea
                  v-model="form.value"
                  rows="3"
                  required
                  class="input-field mt-1"
                  placeholder="Enter value"
                ></textarea>
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700">Description</label>
                <textarea
                  v-model="form.description"
                  rows="2"
                  class="input-field mt-1"
                  placeholder="Enter description"
                ></textarea>
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
import { ref, reactive, computed, onMounted } from 'vue'
import axios from 'axios'
import {
  PlusIcon,
  PencilSquareIcon,
  TrashIcon
} from '@heroicons/vue/24/outline'

export default {
  name: 'Configs',
  setup() {
    const configs = ref([])
    const showCreateModal = ref(false)
    const showEditModal = ref(false)
    const editingConfig = ref(null)
    const selectedCategory = ref('all')
    
    const form = reactive({
      key_name: '',
      value: '',
      category: '',
      description: '',
      data_type: 'string'
    })

    const categories = computed(() => {
      const cats = ['all', ...new Set(configs.value.map(config => config.category))]
      return cats
    })

    const filteredConfigs = computed(() => {
      if (selectedCategory.value === 'all') {
        return configs.value
      }
      return configs.value.filter(config => config.category === selectedCategory.value)
    })

    const formatValue = (value, dataType) => {
      if (dataType === 'json') {
        try {
          return JSON.stringify(JSON.parse(value), null, 2)
        } catch {
          return value
        }
      }
      return value
    }

    const fetchConfigs = async () => {
      try {
        const response = await axios.get('/api/configs')
        configs.value = response.data
      } catch (error) {
        console.error('Error fetching configs:', error)
      }
    }

    const handleSubmit = async () => {
      try {
        if (showCreateModal.value) {
          await axios.post('/api/configs', form)
        } else {
          await axios.put(`/api/configs/${editingConfig.value.id}`, form)
        }
        
        await fetchConfigs()
        closeModal()
        resetForm()
      } catch (error) {
        console.error('Error saving config:', error)
        alert('Error saving config: ' + (error.response?.data?.message || 'Unknown error'))
      }
    }

    const editConfig = (config) => {
      editingConfig.value = config
      form.key_name = config.key_name
      form.value = config.value
      form.category = config.category
      form.description = config.description || ''
      form.data_type = config.data_type
      showEditModal.value = true
    }

    const deleteConfig = async (config) => {
      if (confirm(`Are you sure you want to delete ${config.key_name}?`)) {
        try {
          await axios.delete(`/api/configs/${config.id}`)
          await fetchConfigs()
        } catch (error) {
          console.error('Error deleting config:', error)
          alert('Error deleting config: ' + (error.response?.data?.message || 'Unknown error'))
        }
      }
    }

    const closeModal = () => {
      showCreateModal.value = false
      showEditModal.value = false
      editingConfig.value = null
      resetForm()
    }

    const resetForm = () => {
      form.key_name = ''
      form.value = ''
      form.category = ''
      form.description = ''
      form.data_type = 'string'
    }

    onMounted(() => {
      fetchConfigs()
    })

    return {
      configs,
      form,
      showCreateModal,
      showEditModal,
      selectedCategory,
      categories,
      filteredConfigs,
      formatValue,
      handleSubmit,
      editConfig,
      deleteConfig,
      closeModal,
      PlusIcon,
      PencilSquareIcon,
      TrashIcon
    }
  }
}
</script>
