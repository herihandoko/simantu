<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex justify-between items-center">
      <h1 class="text-2xl font-bold text-gray-900">Master OPD</h1>
      <button @click="showCreateModal = true" class="btn-primary">
        <component :is="PlusIcon" class="w-4 h-4 mr-2" />
        Tambah OPD
      </button>
    </div>

    <!-- OPD Table -->
    <div class="bg-white rounded-lg shadow-sm border border-gray-200">
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Kode OPD</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Nama OPD</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Tanggal Dibuat</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="opd in opdList" :key="opd.id" class="hover:bg-gray-50">
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                {{ opd.id }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                <span class="inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-blue-100 text-blue-800">
                  {{ opd.kode_opd }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {{ opd.nama_opd }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ formatDate(opd.created_at) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                <div class="flex space-x-2">
                  <button @click="editOPD(opd)" class="text-indigo-600 hover:text-indigo-900">
                    <component :is="PencilSquareIcon" class="w-4 h-4" />
                  </button>
                  <button @click="deleteOPD(opd)" class="text-red-600 hover:text-red-900">
                    <component :is="TrashIcon" class="w-4 h-4" />
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Create/Edit Modal -->
    <div v-if="showCreateModal || showEditModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
        <div class="mt-3">
          <h3 class="text-lg font-medium text-gray-900 mb-4">
            {{ showEditModal ? 'Edit OPD' : 'Tambah OPD Baru' }}
          </h3>
          
          <form @submit.prevent="handleSubmit" class="space-y-4">
            <!-- Kode OPD -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Kode OPD *</label>
              <input v-model="form.kode_opd" type="text" required
                     class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                     placeholder="Contoh: DINDIK">
            </div>
            
            <!-- Nama OPD -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Nama OPD *</label>
              <input v-model="form.nama_opd" type="text" required
                     class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                     placeholder="Contoh: Dinas Pendidikan">
            </div>
            
            <div class="flex justify-end space-x-3 pt-4">
              <button type="button" @click="closeModal" 
                      class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-md">
                Batal
              </button>
              <button type="submit" :disabled="isLoading"
                      class="px-4 py-2 text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 rounded-md disabled:opacity-50">
                {{ isLoading ? 'Menyimpan...' : (showEditModal ? 'Update OPD' : 'Simpan OPD') }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import {
  PlusIcon,
  PencilSquareIcon,
  TrashIcon
} from '@heroicons/vue/24/outline'

export default {
  name: 'OPD',
  setup() {
    const opdList = ref([])
    const showCreateModal = ref(false)
    const showEditModal = ref(false)
    const isLoading = ref(false)
    const editingOPD = ref(null)

    const form = ref({
      kode_opd: '',
      nama_opd: ''
    })

    const formatDate = (dateString) => {
      return new Date(dateString).toLocaleDateString('id-ID', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      })
    }

    const fetchOPD = async () => {
      try {
        const response = await axios.get('/api/opd')
        opdList.value = response.data
      } catch (error) {
        console.error('Error fetching OPD:', error)
      }
    }

    const handleSubmit = async () => {
      isLoading.value = true
      try {
        const opdData = {
          kode_opd: form.value.kode_opd.toUpperCase(),
          nama_opd: form.value.nama_opd
        }

        if (showEditModal.value) {
          await axios.put(`/api/opd/${editingOPD.value.id}`, opdData)
        } else {
          await axios.post('/api/opd', opdData)
        }

        await fetchOPD()
        closeModal()
      } catch (error) {
        console.error('Error saving OPD:', error)
        alert('Terjadi kesalahan saat menyimpan data OPD')
      } finally {
        isLoading.value = false
      }
    }

    const editOPD = (opd) => {
      editingOPD.value = opd
      form.value = {
        kode_opd: opd.kode_opd,
        nama_opd: opd.nama_opd
      }
      showEditModal.value = true
    }

    const deleteOPD = async (opd) => {
      if (confirm(`Apakah Anda yakin ingin menghapus OPD "${opd.nama_opd}"?`)) {
        try {
          await axios.delete(`/api/opd/${opd.id}`)
          await fetchOPD()
        } catch (error) {
          console.error('Error deleting OPD:', error)
          alert('Terjadi kesalahan saat menghapus data OPD')
        }
      }
    }

    const closeModal = () => {
      showCreateModal.value = false
      showEditModal.value = false
      editingOPD.value = null
      form.value = {
        kode_opd: '',
        nama_opd: ''
      }
    }

    onMounted(() => {
      fetchOPD()
    })

    return {
      opdList,
      showCreateModal,
      showEditModal,
      isLoading,
      editingOPD,
      form,
      formatDate,
      handleSubmit,
      editOPD,
      deleteOPD,
      closeModal,
      PlusIcon,
      PencilSquareIcon,
      TrashIcon
    }
  }
}
</script>
