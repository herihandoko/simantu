<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex justify-between items-center">
      <h1 class="text-2xl font-bold text-gray-900">Formulir Tugas Proyek</h1>
      <div class="flex space-x-3">
        <button @click="exportTasks" class="btn-secondary">
          <component :is="DocumentArrowDownIcon" class="w-4 h-4 mr-2" />
          Export Data
        </button>
        <button @click="openCreateModal" class="btn-primary">
          <component :is="PlusIcon" class="w-4 h-4 mr-2" />
          Tambah Tugas
        </button>
      </div>
    </div>

    <!-- Filters -->
    <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-lg font-medium text-gray-900">Filter & Pencarian</h3>
        <button @click="clearFilters" class="text-sm text-gray-500 hover:text-gray-700">
          Clear Filters
        </button>
      </div>
      
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <!-- Search -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Cari Pekerjaan</label>
          <input v-model="filters.search" type="text" placeholder="Cari nama pekerjaan..."
                 class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500">
        </div>

        <!-- Status Filter -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Status</label>
          <select v-model="filters.status" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500">
            <option value="">Semua Status</option>
            <option value="pending">To Do</option>
            <option value="in_progress">In Progress</option>
            <option value="completed">Done</option>
            <option value="cancelled">Cancelled</option>
          </select>
        </div>

        <!-- Priority Filter -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Prioritas</label>
          <select v-model="filters.priority" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500">
            <option value="">Semua Prioritas</option>
            <option value="low">Rendah</option>
            <option value="medium">Sedang</option>
            <option value="high">Tinggi</option>
            <option value="urgent">Sangat Tinggi</option>
          </select>
        </div>

        <!-- OPD Filter -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">OPD</label>
          <SearchableSelect
            v-model="filters.opd_id"
            :options="opdList.map(opd => ({ value: opd.id, text: `${opd.kode_opd} - ${opd.nama_opd}` }))"
            placeholder="Semua OPD"
            id="filterOpdSelect"
          />
        </div>
      </div>
    </div>

    <!-- Tasks Table -->
    <div class="bg-white rounded-lg shadow-sm border border-gray-200">
      <!-- Results Info -->
      <div class="px-6 py-3 bg-gray-50 border-b border-gray-200">
        <p class="text-sm text-gray-600">
          Menampilkan {{ filteredTasks.length }} dari {{ tasks.length }} tugas
        </p>
      </div>
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID Tugas</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Nama Pekerjaan</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Progress</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Prioritas</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">OPD</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Tenaga Ahli</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Sub Tasks</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Durasi</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Tanggal Selesai</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-if="filteredTasks.length === 0">
              <td colspan="11" class="px-6 py-12 text-center text-gray-500">
                <div class="flex flex-col items-center">
                  <svg class="w-12 h-12 text-gray-300 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                  </svg>
                  <p class="text-lg font-medium text-gray-900 mb-2">Tidak ada tugas ditemukan</p>
                  <p class="text-sm text-gray-500">Coba ubah filter atau hapus beberapa filter untuk melihat lebih banyak hasil.</p>
                </div>
              </td>
            </tr>
            <tr v-for="task in filteredTasks" :key="task.id" class="hover:bg-gray-50">
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                {{ task.task_id || `TASK-${task.id}` }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div>
                  <div class="text-sm font-medium text-gray-900">{{ task.nama_pekerjaan || task.tugas }}</div>
                  <div class="text-sm text-gray-500 truncate max-w-xs">{{ task.uraian_tugas || task.description }}</div>
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
                {{ task.nama_opd ? `${task.kode_opd} - ${task.nama_opd}` : '-' }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {{ task.tenaga_ahli_nama || '-' }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium"
                      :class="getSubTaskCountClass(task.sub_tasks_count)">
                  {{ task.sub_tasks_count || 0 }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {{ task.estimasi_durasi ? `${task.estimasi_durasi} hari` : '-' }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {{ (task.tanggal_selesai || task.due_date) ? formatDate(task.tanggal_selesai || task.due_date) : '-' }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                <div class="flex space-x-2">
                  <button @click="editTask(task)" class="text-indigo-600 hover:text-indigo-900">
                    <component :is="PencilSquareIcon" class="w-4 h-4" />
                  </button>
                  <button @click="deleteTask(task)" class="text-red-600 hover:text-red-900">
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
      <div class="relative top-10 mx-auto p-5 border w-11/12 max-w-6xl shadow-lg rounded-md bg-white">
        <div class="mt-3">
          <h3 class="text-lg font-medium text-gray-900 mb-4">
            {{ showEditModal ? 'Edit Tugas' : 'Formulir Tugas Proyek' }}
          </h3>
          
          <form @submit.prevent="handleSubmit" class="space-y-4">
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <!-- ID Tugas (Auto-generated) -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">ID Tugas</label>
              <input type="text" readonly 
                     :value="editingTask ? editingTask.task_id : 'ID akan dibuat secara otomatis'"
                     class="w-full px-3 py-2 border border-gray-300 rounded-md bg-gray-100 text-gray-500">
            </div>
            
            <!-- Tanggal (Auto-generated) -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Tanggal</label>
              <input type="text" readonly 
                     :value="editingTask ? formatDateTime(editingTask.created_at) : formatDateTime(new Date())"
                     class="w-full px-3 py-2 border border-gray-300 rounded-md bg-gray-100 text-gray-500">
            </div>
            
            <!-- Nama OPD -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">
                Nama OPD 
                <span class="text-red-500">*</span>
              </label>
              <SearchableSelect
                v-model="form.opd_id"
                :options="opdList.map(opd => ({ value: opd.id, text: `${opd.kode_opd} - ${opd.nama_opd}` }))"
                placeholder="Pilih OPD..."
                id="opdSelect"
              />
            </div>
            
            <!-- Nama Pekerjaan -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">
                Nama Pekerjaan 
                <span class="text-red-500">*</span>
              </label>
              <input v-model="form.nama_pekerjaan" type="text" required
                     class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
                     placeholder="Masukkan nama pekerjaan">
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
            
            <!-- Tugas -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Tugas</label>
              <input v-model="form.tugas" type="text"
                     class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500">
            </div>
            
            <!-- Uraian Tugas -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Uraian Tugas</label>
              <textarea v-model="form.uraian_tugas" rows="3"
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"></textarea>
            </div>
            
            <!-- Prioritas -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Prioritas</label>
              <select v-model="form.prioritas"
                      class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500">
                <option value="low">Rendah</option>
                <option value="medium">Sedang</option>
                <option value="high">Tinggi</option>
                <option value="urgent">Sangat Tinggi</option>
              </select>
            </div>
            
            <!-- Tenaga Ahli -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Tenaga Ahli</label>
              <SearchableSelect
                v-model="form.tenaga_ahli_id"
                :options="tenagaAhliList.map(ahli => ({ value: ahli.id, text: `${ahli.name} - ${ahli.email}` }))"
                :placeholder="authStore.user && authStore.user.role && authStore.user.role.toLowerCase() === 'tenaga ahli' ? 'Otomatis terpilih (Anda)' : 'Pilih Tenaga Ahli...'"
                id="tenagaAhliSelect"
              />
            </div>
            
            <!-- Tanggal Mulai -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Tanggal Mulai</label>
              <input v-model="form.start_date" type="date"
                     class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500">
            </div>
            
            <!-- Tanggal Selesai -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Tanggal Selesai</label>
              <input v-model="form.tanggal_selesai" type="date"
                     class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500">
            </div>
            
            <!-- Estimasi Durasi -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Estimasi Durasi (Hari)</label>
              <input v-model="form.estimasi_durasi" type="number" min="1"
                     class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500">
            </div>
            
            
            <!-- Progress Percentage -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Progress (%)</label>
              <div class="flex items-center space-x-2">
                <input v-model="form.progress_percentage" type="range" min="0" max="100" step="5"
                       class="flex-1 h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer">
                <span class="text-sm font-medium text-gray-700 w-12">{{ form.progress_percentage }}%</span>
              </div>
            </div>
            
            <!-- Milestone -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Milestone/Fase</label>
              <input v-model="form.milestone" type="text" placeholder="Contoh: Fase 1, Sprint 1, dll"
                     class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500">
            </div>
            
            
            <!-- Risk Level -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Tingkat Risiko</label>
              <select v-model="form.risk_level"
                      class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500">
                <option value="low">Rendah</option>
                <option value="medium">Sedang</option>
                <option value="high">Tinggi</option>
                <option value="critical">Kritis</option>
              </select>
            </div>
            
            <!-- Complexity -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Tingkat Kompleksitas</label>
              <select v-model="form.complexity"
                      class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500">
                <option value="simple">Sederhana</option>
                <option value="moderate">Sedang</option>
                <option value="complex">Kompleks</option>
                <option value="very_complex">Sangat Kompleks</option>
              </select>
            </div>
            
            <!-- Tags -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Tags</label>
              <div class="flex flex-wrap gap-2 mb-2">
                <span v-for="(tag, index) in form.tags" :key="index"
                      class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-primary-100 text-primary-800">
                  {{ tag }}
                  <button type="button" @click="removeTag(index)" class="ml-1 text-primary-600 hover:text-primary-800">
                    ×
                  </button>
                </span>
              </div>
              <div class="flex space-x-2">
                <input v-model="newTag" type="text" placeholder="Tambah tag..." @keyup.enter="addTag"
                       class="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500">
                <button type="button" @click="addTag"
                        class="px-3 py-2 text-sm font-medium text-primary-600 bg-primary-50 hover:bg-primary-100 rounded-md">
                  Tambah
                </button>
              </div>
            </div>
            
            <!-- Additional Task Fields (available for all roles) -->
            <!-- Sub Tasks -->
            <div class="lg:col-span-2">
              <label class="block text-sm font-medium text-gray-700 mb-1">Sub Tasks (Breakdown Pekerjaan)</label>
              <div class="space-y-2">
                <div v-for="(subTask, index) in form.sub_tasks" :key="index" 
                     class="flex items-center space-x-2 p-2 bg-gray-50 rounded-md">
                  <input v-model="subTask.title" type="text" placeholder="Judul sub task..."
                         class="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500">
                  <select v-model="subTask.status" class="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500">
                    <option value="pending">To Do</option>
                    <option value="in_progress">In Progress</option>
                    <option value="completed">Done</option>
                    <option value="cancelled">Cancelled</option>
                  </select>
                  <button type="button" @click="removeSubTask(index)" 
                          class="px-2 py-1 text-red-600 hover:text-red-800">
                    <component :is="TrashIcon" class="w-4 h-4" />
                  </button>
                </div>
                <button type="button" @click="addSubTask"
                        class="w-full px-3 py-2 text-sm font-medium text-primary-600 bg-primary-50 hover:bg-primary-100 rounded-md border border-dashed border-primary-300">
                  + Tambah Sub Task
                </button>
              </div>
            </div>
            
            <!-- Narasi Pekerjaan -->
            <div class="lg:col-span-2">
              <label class="block text-sm font-medium text-gray-700 mb-1">Narasi Pekerjaan</label>
              <textarea v-model="form.narasi_pekerjaan" rows="4" placeholder="Jelaskan pekerjaan yang telah dilakukan..."
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"></textarea>
            </div>
            
            <!-- Evidence Upload -->
            <div class="lg:col-span-2">
              <label class="block text-sm font-medium text-gray-700 mb-1">Evidence (Upload File)</label>
              <div class="space-y-2">
                <!-- File Preview List -->
                <div v-for="(file, index) in form.evidence_files" :key="index" 
                     class="flex items-center justify-between p-3 bg-gray-50 rounded-md border"
                     :class="file.file ? 'border-green-300 bg-green-50' : 'border-gray-300'">
                  <div class="flex items-center space-x-3">
                    <!-- File Icon -->
                    <div class="flex-shrink-0">
                      <div v-if="file.type.startsWith('image/')" class="w-8 h-8 bg-green-100 rounded flex items-center justify-center">
                        <svg class="w-4 h-4 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                        </svg>
                      </div>
                      <div v-else-if="file.type === 'application/pdf'" class="w-8 h-8 bg-red-100 rounded flex items-center justify-center">
                        <svg class="w-4 h-4 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"></path>
                        </svg>
                      </div>
                      <div v-else class="w-8 h-8 bg-blue-100 rounded flex items-center justify-center">
                        <svg class="w-4 h-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                        </svg>
                      </div>
                    </div>
                    
                    <!-- File Info -->
                    <div class="flex-1 min-w-0">
                      <div class="flex items-center space-x-2">
                        <p class="text-sm font-medium text-gray-900 truncate">{{ file.name }}</p>
                        <span v-if="file.file" class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
                          Baru
                        </span>
                        <span v-else class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-gray-100 text-gray-600">
                          Tersimpan
                        </span>
                      </div>
                      <p class="text-xs text-gray-500">{{ formatFileSize(file.size) }}</p>
                    </div>
                  </div>
                  
                  <!-- Action Buttons -->
                  <div class="flex items-center space-x-2">
                    <!-- Preview Button -->
                    <button type="button" @click="previewFile(file)" 
                            class="text-blue-600 hover:text-blue-800 p-1 rounded"
                            title="Preview file">
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
                      </svg>
                    </button>
                    
                    <!-- Download Button -->
                    <button type="button" @click="downloadFile(file)" 
                            class="text-green-600 hover:text-green-800 p-1 rounded"
                            title="Download file">
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                      </svg>
                    </button>
                    
                    <!-- Remove Button -->
                    <button type="button" @click="removeEvidenceFile(index)" 
                            class="text-red-600 hover:text-red-800 p-1 rounded"
                            title="Remove file">
                      <component :is="TrashIcon" class="w-4 h-4" />
                    </button>
                  </div>
                </div>
                
                <!-- Upload Input -->
                <input type="file" @change="handleEvidenceUpload" multiple
                       class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500">
                <p class="text-xs text-gray-500">Upload file evidence pekerjaan (PDF, DOC, JPG, PNG)</p>
              </div>
            </div>
            
            <!-- Link URL -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Link URL</label>
              <input v-model="form.link_url" type="url" placeholder="https://example.com"
                     class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500">
            </div>
            
            <!-- Status Update -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Update Status</label>
              <textarea v-model="form.status_update" rows="3" placeholder="Update status pekerjaan..."
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"></textarea>
            </div>
            </div>
            
            <div class="flex justify-end space-x-3 pt-4">
              <button type="button" @click="closeModal" 
                      class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-md">
                Batal
              </button>
              <button type="submit" :disabled="isLoading"
                      class="px-4 py-2 text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 rounded-md disabled:opacity-50">
                {{ isLoading ? 'Menyimpan...' : 'Simpan Tugas' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- File Preview Modal -->
    <div v-if="showPreviewModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div class="relative top-10 mx-auto p-5 border w-11/12 max-w-4xl shadow-lg rounded-md bg-white">
        <div class="flex justify-between items-center mb-4">
          <h3 class="text-lg font-medium text-gray-900">Preview File</h3>
          <button @click="closePreviewModal" class="text-gray-400 hover:text-gray-600">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>
        </div>
        
        <div class="mb-4">
          <h4 class="text-sm font-medium text-gray-700">{{ previewFileData.name }}</h4>
          <p class="text-xs text-gray-500">{{ formatFileSize(previewFileData.size) }}</p>
        </div>
        
        <div class="max-h-96 overflow-auto">
          <!-- Image Preview -->
          <div v-if="previewFileData.type.startsWith('image/')" class="text-center">
            <img :src="previewFileData.url" :alt="previewFileData.name" 
                 class="max-w-full max-h-96 mx-auto rounded-lg shadow-lg">
          </div>
          
          <!-- PDF Preview -->
          <div v-else-if="previewFileData.type === 'application/pdf'" class="w-full h-96">
            <embed :src="previewFileData.url" type="application/pdf" width="100%" height="100%">
          </div>
          
          <!-- Other Files -->
          <div v-else class="text-center py-8">
            <svg class="w-16 h-16 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
            </svg>
            <p class="text-gray-600 mb-4">File ini tidak dapat di-preview</p>
            <button @click="downloadFile(previewFileData)" 
                    class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700">
              Download File
            </button>
          </div>
        </div>
        
        <div class="flex justify-end space-x-3 mt-4">
          <button @click="downloadFile(previewFileData)" 
                  class="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700">
            Download
          </button>
          <button @click="closePreviewModal" 
                  class="px-4 py-2 bg-gray-300 text-gray-700 rounded-md hover:bg-gray-400">
            Tutup
          </button>
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
import {
  PlusIcon,
  PencilSquareIcon,
  TrashIcon,
  DocumentArrowDownIcon
} from '@heroicons/vue/24/outline'
import SearchableSelect from '../components/SearchableSelect.vue'

export default {
  name: 'Tasks',
  components: {
    SearchableSelect
  },
  setup() {
    const authStore = useAuthStore()
    const tasks = ref([])
    const users = ref([])
    const opdList = ref([])
    const tenagaAhliList = ref([])
    const showCreateModal = ref(false)
    const showEditModal = ref(false)
    const showPreviewModal = ref(false)
    const isLoading = ref(false)
    const editingTask = ref(null)
    const newTag = ref('')
    const previewFileData = ref({})

    // Helper function to get today's date in YYYY-MM-DD format
    const getTodayDate = () => {
      const today = new Date()
      return today.toISOString().split('T')[0]
    }

    // Helper function to get default tenaga ahli ID
    const getDefaultTenagaAhliId = () => {
      if (authStore.user && authStore.user.role && authStore.user.role.toLowerCase() === 'tenaga ahli') {
        return authStore.user.id
      }
      return ''
    }

    const form = ref({
      nama_pekerjaan: '',
      status: 'pending',
      tugas: '',
      uraian_tugas: '',
      prioritas: 'medium',
      opd_id: '',
      tenaga_ahli_id: getDefaultTenagaAhliId(),
      tanggal_selesai: '',
      estimasi_durasi: '',
      progress_percentage: 0,
      tags: [],
      start_date: getTodayDate(),
      milestone: '',
      risk_level: 'low',
      complexity: 'moderate',
      // New TA fields
      sub_tasks: [],
      narasi_pekerjaan: '',
      evidence_files: [],
      link_url: '',
      status_update: ''
    })

    // Filters
    const filters = ref({
      search: '',
      status: '',
      priority: '',
      opd_id: ''
    })

    // Computed filtered tasks
    const filteredTasks = computed(() => {
      let filtered = tasks.value

      // Search filter
      if (filters.value.search) {
        const searchTerm = filters.value.search.toLowerCase()
        filtered = filtered.filter(task => 
          (task.nama_pekerjaan && task.nama_pekerjaan.toLowerCase().includes(searchTerm)) ||
          (task.tugas && task.tugas.toLowerCase().includes(searchTerm)) ||
          (task.uraian_tugas && task.uraian_tugas.toLowerCase().includes(searchTerm))
        )
      }

      // Status filter
      if (filters.value.status) {
        filtered = filtered.filter(task => task.status === filters.value.status)
      }

      // Priority filter
      if (filters.value.priority) {
        filtered = filtered.filter(task => (task.prioritas || task.priority) === filters.value.priority)
      }

      // OPD filter
      if (filters.value.opd_id) {
        filtered = filtered.filter(task => task.opd_id == filters.value.opd_id)
      }

      return filtered
    })

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

    const getSubTaskCountClass = (count) => {
      if (!count || count === 0) {
        return 'bg-gray-100 text-gray-600'
      } else if (count <= 2) {
        return 'bg-green-100 text-green-800'
      } else if (count <= 5) {
        return 'bg-yellow-100 text-yellow-800'
      } else {
        return 'bg-red-100 text-red-800'
      }
    }

    const formatDate = (dateString) => {
      return new Date(dateString).toLocaleDateString()
    }

    const formatDateTime = (dateString) => {
      const date = new Date(dateString)
      return date.toLocaleDateString('id-ID', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
      })
    }

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

    const fetchUsers = async () => {
      try {
        const response = await axios.get('/api/users')
        users.value = response.data
      } catch (error) {
        console.error('Error fetching users:', error)
      }
    }

    const fetchOPD = async () => {
      try {
        const response = await axios.get('/api/tasks/opd')
        opdList.value = response.data
      } catch (error) {
        console.error('Error fetching OPD:', error)
      }
    }

    const fetchTenagaAhli = async () => {
      try {
        const response = await axios.get('/api/tasks/tenaga-ahli')
        tenagaAhliList.value = response.data
      } catch (error) {
        console.error('Error fetching Tenaga Ahli:', error)
      }
    }

    const handleSubmit = async () => {
      isLoading.value = true
      try {
        const taskData = {
          nama_pekerjaan: form.value.nama_pekerjaan,
          status: form.value.status,
          tugas: form.value.tugas,
          uraian_tugas: form.value.uraian_tugas,
          prioritas: form.value.prioritas,
          opd_id: form.value.opd_id || null,
          tenaga_ahli_id: form.value.tenaga_ahli_id || null,
          tanggal_selesai: form.value.tanggal_selesai || null,
          estimasi_durasi: form.value.estimasi_durasi || null,
          progress_percentage: form.value.progress_percentage || 0,
          tags: form.value.tags,
          start_date: form.value.start_date || null,
          milestone: form.value.milestone || null,
          risk_level: form.value.risk_level || 'low',
          complexity: form.value.complexity || 'moderate',
          // New TA fields
          sub_tasks: form.value.sub_tasks,
          narasi_pekerjaan: form.value.narasi_pekerjaan || null,
          evidence_files: form.value.evidence_files,
          link_url: form.value.link_url || null,
          status_update: form.value.status_update || null
        }

        if (showEditModal.value) {
          await axios.put(`/api/tasks/${editingTask.value.id}`, taskData)
        } else {
          await axios.post('/api/tasks', taskData)
        }

        await fetchTasks()
        closeModal()
        Swal.fire({
          title: 'Berhasil!',
          text: showEditModal.value ? 'Task berhasil diupdate.' : 'Task berhasil dibuat.',
          icon: 'success',
          timer: 2000,
          showConfirmButton: false
        })
      } catch (error) {
        console.error('Error saving task:', error)
        Swal.fire({
          title: 'Error!',
          text: 'Terjadi kesalahan saat menyimpan task.',
          icon: 'error'
        })
      } finally {
        isLoading.value = false
      }
    }

    const editTask = (task) => {
      editingTask.value = task
      form.value = {
        nama_pekerjaan: task.nama_pekerjaan || '',
        status: task.status,
        tugas: task.tugas || '',
        uraian_tugas: task.uraian_tugas || '',
        prioritas: task.prioritas || 'medium',
        opd_id: task.opd_id || '',
        tenaga_ahli_id: task.tenaga_ahli_id || '',
        tanggal_selesai: task.tanggal_selesai || '',
        estimasi_durasi: task.estimasi_durasi || '',
        progress_percentage: task.progress_percentage || 0,
        tags: task.tags ? (typeof task.tags === 'string' ? JSON.parse(task.tags) : task.tags) : [],
        start_date: task.start_date || '',
        milestone: task.milestone || '',
        risk_level: task.risk_level || 'low',
        complexity: task.complexity || 'moderate',
        // New TA fields
        sub_tasks: task.sub_tasks ? (typeof task.sub_tasks === 'string' ? JSON.parse(task.sub_tasks) : task.sub_tasks) : [],
        narasi_pekerjaan: task.narasi_pekerjaan || '',
        evidence_files: task.evidence_files ? (typeof task.evidence_files === 'string' ? JSON.parse(task.evidence_files) : task.evidence_files) : [],
        link_url: task.link_url || '',
        status_update: task.status_update || ''
      }
      showEditModal.value = true
    }

    const deleteTask = async (task) => {
      const result = await Swal.fire({
        title: 'Konfirmasi Hapus',
        text: `Apakah Anda yakin ingin menghapus "${task.nama_pekerjaan || task.tugas}"?`,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d33',
        cancelButtonColor: '#3085d6',
        confirmButtonText: 'Ya, Hapus!',
        cancelButtonText: 'Batal'
      })

      if (result.isConfirmed) {
        try {
          await axios.delete(`/api/tasks/${task.id}`)
          await fetchTasks()
          Swal.fire({
            title: 'Berhasil!',
            text: 'Task berhasil dihapus.',
            icon: 'success',
            timer: 2000,
            showConfirmButton: false
          })
        } catch (error) {
          console.error('Error deleting task:', error)
          Swal.fire({
            title: 'Error!',
            text: 'Terjadi kesalahan saat menghapus task.',
            icon: 'error'
          })
        }
      }
    }

    const openCreateModal = () => {
      showCreateModal.value = true
    }

    const clearFilters = () => {
      filters.value = {
        search: '',
        status: '',
        priority: '',
        opd_id: ''
      }
    }

    const closeModal = () => {
      showCreateModal.value = false
      showEditModal.value = false
      editingTask.value = null
      newTag.value = ''
      form.value = {
        nama_pekerjaan: '',
        status: 'pending',
        tugas: '',
        uraian_tugas: '',
        prioritas: 'medium',
        opd_id: '',
        tenaga_ahli_id: getDefaultTenagaAhliId(),
        tanggal_selesai: '',
        estimasi_durasi: '',
        progress_percentage: 0,
        tags: [],
        start_date: getTodayDate(),
        milestone: '',
        risk_level: 'low',
        complexity: 'moderate',
        // New TA fields
        sub_tasks: [],
        narasi_pekerjaan: '',
        evidence_files: [],
        link_url: '',
        status_update: ''
      }
    }

    const addTag = () => {
      if (newTag.value.trim() && !form.value.tags.includes(newTag.value.trim())) {
        form.value.tags.push(newTag.value.trim())
        newTag.value = ''
      }
    }

    const removeTag = (index) => {
      form.value.tags.splice(index, 1)
    }

    // Sub task management functions
    const addSubTask = () => {
      form.value.sub_tasks.push({
        title: '',
        status: 'pending'
      })
    }

    const removeSubTask = (index) => {
      form.value.sub_tasks.splice(index, 1)
    }

    // Evidence file management functions
    const handleEvidenceUpload = (event) => {
      const files = Array.from(event.target.files)
      files.forEach(file => {
        // Validate file type
        const allowedTypes = ['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'image/jpeg', 'image/png']
        if (allowedTypes.includes(file.type)) {
          form.value.evidence_files.push({
            name: file.name,
            size: file.size,
            type: file.type,
            file: file
          })
        } else {
          Swal.fire({
            title: 'File tidak didukung',
            text: 'Hanya file PDF, DOC, DOCX, JPG, dan PNG yang diperbolehkan.',
            icon: 'warning'
          })
        }
      })
      // Clear the input
      event.target.value = ''
    }

    const removeEvidenceFile = (index) => {
      form.value.evidence_files.splice(index, 1)
    }

    // File utility functions
    const formatFileSize = (bytes) => {
      if (bytes === 0) return '0 Bytes'
      const k = 1024
      const sizes = ['Bytes', 'KB', 'MB', 'GB']
      const i = Math.floor(Math.log(bytes) / Math.log(k))
      return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
    }

    const previewFile = (file) => {
      // Check if file has a file property (newly uploaded) or is already processed
      const fileObject = file.file || file
      
      if (fileObject instanceof File) {
        // For newly uploaded files
        const reader = new FileReader()
        reader.onload = (e) => {
          previewFileData.value = {
            name: file.name,
            size: file.size,
            type: file.type,
            url: e.target.result,
            file: fileObject
          }
          showPreviewModal.value = true
        }
        reader.readAsDataURL(fileObject)
      } else {
        // For files from database (already processed)
        // Show file info without preview
        Swal.fire({
          title: 'File Preview',
          html: `
            <div class="text-left">
              <p><strong>Nama File:</strong> ${file.name}</p>
              <p><strong>Ukuran:</strong> ${formatFileSize(file.size)}</p>
              <p><strong>Tipe:</strong> ${file.type}</p>
              <p class="mt-3 text-sm text-gray-600">File ini sudah tersimpan di database. Preview tidak tersedia untuk file yang sudah disimpan.</p>
            </div>
          `,
          showConfirmButton: true,
          confirmButtonText: 'Download',
          showCancelButton: true,
          cancelButtonText: 'Tutup'
        }).then((result) => {
          if (result.isConfirmed) {
            downloadFile(file)
          }
        })
      }
    }

    const closePreviewModal = () => {
      showPreviewModal.value = false
      previewFileData.value = {}
    }

    const downloadFile = (file) => {
      const fileObject = file.file || file
      
      if (fileObject instanceof File) {
        // For newly uploaded files
        const url = URL.createObjectURL(fileObject)
        const link = document.createElement('a')
        link.href = url
        link.download = file.name
        document.body.appendChild(link)
        link.click()
        document.body.removeChild(link)
        URL.revokeObjectURL(url)
      } else {
        // For files from database, show message
        Swal.fire({
          title: 'Download File',
          text: 'File ini sudah tersimpan di database. Untuk download, silakan hubungi administrator atau gunakan fitur export.',
          icon: 'info',
          confirmButtonText: 'OK'
        })
      }
    }

    const exportTasks = async () => {
      try {
        isLoading.value = true
        const response = await axios.get('/api/tasks/export/excel', {
          responseType: 'blob'
        })
        
        const url = window.URL.createObjectURL(new Blob([response.data]))
        const link = document.createElement('a')
        link.href = url
        link.setAttribute('download', 'tasks_export.csv')
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


    onMounted(async () => {
      await fetchTasks()
      await fetchUsers()
      await fetchOPD()
      await fetchTenagaAhli()
    })

    return {
      authStore,
      tasks,
      filteredTasks,
      users,
      opdList,
      tenagaAhliList,
      showCreateModal,
      showEditModal,
      showPreviewModal,
      isLoading,
      editingTask,
      form,
      previewFileData,
      filters,
      getStatusClass,
      getPriorityClass,
      getSubTaskCountClass,
      formatDate,
      formatDateTime,
      handleSubmit,
      editTask,
      deleteTask,
      openCreateModal,
      clearFilters,
      closeModal,
      addTag,
      removeTag,
      newTag,
      addSubTask,
      removeSubTask,
      handleEvidenceUpload,
      removeEvidenceFile,
      formatFileSize,
      previewFile,
      closePreviewModal,
      downloadFile,
      exportTasks,
      PlusIcon,
      PencilSquareIcon,
      TrashIcon,
      DocumentArrowDownIcon
    }
  }
}
</script>

