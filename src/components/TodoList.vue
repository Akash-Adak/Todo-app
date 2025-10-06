<template>
  <div 
    :class="[
      'min-h-screen transition-all duration-500',
      isDark 
        ? 'bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900' 
        : 'bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50'
    ]"
  >
    <div class="container mx-auto px-4 py-12 max-w-2xl">
      <!-- Header with theme toggle -->
      <div class="flex justify-between items-center mb-8">
        <div>
          <h1 :class="[
            'text-5xl font-bold mb-2',
            isDark ? 'text-white' : 'text-slate-900'
          ]">
            My Tasks
          </h1>
          <p :class="[
            'text-lg',
            isDark ? 'text-purple-300' : 'text-purple-600'
          ]">
            {{ completedCount }} of {{ totalCount }} completed
          </p>
        </div>
        <button
          @click="toggleTheme"
          :class="[
            'p-3 rounded-full transition-all duration-300',
            isDark 
              ? 'bg-purple-500/20 hover:bg-purple-500/30 text-yellow-300' 
              : 'bg-purple-200 hover:bg-purple-300 text-purple-900'
          ]"
        >
          <Sun v-if="isDark" :size="24" />
          <Moon v-else :size="24" />
        </button>
      </div>

      <!-- Input area -->
      <div :class="[
        'backdrop-blur-lg rounded-2xl p-6 mb-6 shadow-2xl border transition-all duration-300',
        isDark 
          ? 'bg-white/10 border-white/20' 
          : 'bg-white/80 border-purple-200'
      ]">
        <div class="flex gap-3">
          <input
            type="text"
            v-model="newTask"
            @keypress="handleKeyPress"
            placeholder="What needs to be done?"
            :class="[
              'flex-1 px-4 py-3 rounded-xl border-2 outline-none transition-all duration-300',
              isDark
                ? 'bg-slate-800/50 border-purple-500/30 text-white placeholder-gray-400 focus:border-purple-400'
                : 'bg-white border-purple-200 text-slate-900 placeholder-gray-500 focus:border-purple-400'
            ]"
          />
          <button
            @click="addTask"
            class="px-6 py-3 bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600 text-white rounded-xl font-semibold shadow-lg hover:shadow-xl transition-all duration-300 flex items-center gap-2"
          >
            <Plus :size="20" />
            Add
          </button>
        </div>
      </div>

      <!-- Tasks list -->
      <div class="space-y-3">
        <div 
          v-if="tasks.length === 0"
          :class="[
            'text-center py-16',
            isDark ? 'text-purple-300' : 'text-purple-400'
          ]"
        >
          <p class="text-xl mb-2">✨ No tasks yet</p>
          <p class="text-sm opacity-70">Add your first task to get started!</p>
        </div>
        
        <div
          v-for="task in tasks"
          :key="task.id"
          :class="[
            'backdrop-blur-lg rounded-xl p-4 shadow-lg border transition-all duration-300 hover:scale-[1.02]',
            isDark
              ? 'bg-white/10 border-white/20 hover:bg-white/15'
              : 'bg-white/90 border-purple-100 hover:bg-white',
            task.done ? 'opacity-60' : ''
          ]"
        >
          <div class="flex items-center gap-3">
            <button
              @click="toggleTask(task.id)"
              :class="[
                'flex-shrink-0 w-6 h-6 rounded-full border-2 flex items-center justify-center transition-all duration-300',
                task.done
                  ? 'bg-gradient-to-r from-green-400 to-emerald-500 border-green-400'
                  : isDark
                  ? 'border-purple-400 hover:border-purple-300'
                  : 'border-purple-300 hover:border-purple-400'
              ]"
            >
              <Check v-if="task.done" :size="14" class="text-white" />
            </button>
            
            <span
              @click="toggleTask(task.id)"
              :class="[
                'flex-1 cursor-pointer transition-all duration-300',
                task.done ? 'line-through' : '',
                isDark ? 'text-white' : 'text-slate-800'
              ]"
            >
              {{ task.text }}
            </span>
            
            <button
              @click="deleteTask(task.id)"
              :class="[
                'flex-shrink-0 p-2 rounded-lg transition-all duration-300',
                isDark
                  ? 'hover:bg-red-500/20 text-red-400 hover:text-red-300'
                  : 'hover:bg-red-100 text-red-500 hover:text-red-600'
              ]"
            >
              <X :size="18" />
            </button>
          </div>
        </div>
      </div>

      <!-- Footer stats -->
      <div 
        v-if="tasks.length > 0"
        :class="[
          'mt-8 text-center text-sm',
          isDark ? 'text-purple-300' : 'text-purple-600'
        ]"
      >
        <p class="opacity-70">
          {{ remainingCount }} task{{ remainingCount !== 1 ? 's' : '' }} remaining
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { Check, X, Plus, Moon, Sun } from 'lucide-vue-next'

const tasks = ref([])
const newTask = ref('')
const isDark = ref(true)

const addTask = () => {
  if (!newTask.value.trim()) return
  tasks.value.push({
    id: Date.now(),
    text: newTask.value,
    done: false
  })
  newTask.value = ''
}

const toggleTask = (id) => {
  const task = tasks.value.find(task => task.id === id)
  if (task) {
    task.done = !task.done
  }
}

const deleteTask = (id) => {
  tasks.value = tasks.value.filter(task => task.id !== id)
}

const handleKeyPress = (e) => {
  if (e.key === 'Enter') addTask()
}

const toggleTheme = () => {
  isDark.value = !isDark.value
}

const completedCount = computed(() => tasks.value.filter(t => t.done).length)
const totalCount = computed(() => tasks.value.length)
const remainingCount = computed(() => tasks.value.filter(t => !t.done).length)
</script>