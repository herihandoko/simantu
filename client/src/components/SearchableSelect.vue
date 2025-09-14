<template>
  <select :id="id" :value="modelValue" @change="handleChange" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
    <option value="">{{ placeholder }}</option>
    <option v-for="option in options" :key="option.value" :value="option.value">
      {{ option.text }}
    </option>
  </select>
</template>

<script>
import { ref, onMounted, watch, nextTick } from 'vue'
import TomSelect from 'tom-select'

export default {
  name: 'SearchableSelect',
  props: {
    modelValue: [String, Number],
    options: {
      type: Array,
      default: () => []
    },
    placeholder: {
      type: String,
      default: 'Pilih...'
    },
    id: {
      type: String,
      required: true
    }
  },
  emits: ['update:modelValue'],
  setup(props, { emit }) {
    const tomSelectInstance = ref(null)

    const handleChange = (event) => {
      emit('update:modelValue', event.target.value)
    }

    const initializeTomSelect = () => {
      nextTick(() => {
        // Destroy existing instance
        if (tomSelectInstance.value) {
          tomSelectInstance.value.destroy()
        }

        const element = document.getElementById(props.id)
        if (element) {
          tomSelectInstance.value = new TomSelect(element, {
            placeholder: props.placeholder,
            allowEmptyOption: true,
            onChange: (value) => {
              emit('update:modelValue', value)
            }
          })
        }
      })
    }

    const setValue = (value) => {
      if (tomSelectInstance.value) {
        tomSelectInstance.value.setValue(value)
      }
    }

    watch(() => props.modelValue, (newValue) => {
      if (tomSelectInstance.value) {
        tomSelectInstance.value.setValue(newValue)
      }
    })

    onMounted(() => {
      setTimeout(() => {
        initializeTomSelect()
      }, 100)
    })

    return {
      handleChange,
      setValue
    }
  }
}
</script>

<style>
@import 'tom-select/dist/css/tom-select.css';

.ts-control {
  border: 1px solid #d1d5db !important;
  border-radius: 0.375rem !important;
  padding: 0.5rem 0.75rem !important;
}

.ts-control:focus {
  outline: none !important;
  border-color: #3b82f6 !important;
  box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.1) !important;
}

.ts-dropdown {
  border: 1px solid #d1d5db !important;
  border-radius: 0.375rem !important;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1) !important;
}

.ts-option {
  padding: 0.5rem 0.75rem !important;
}

.ts-option:hover {
  background-color: #f3f4f6 !important;
}

.ts-option.ts-selected {
  background-color: #3b82f6 !important;
  color: white !important;
}
</style>
