<template>
  <div 
    :class="[
      'min-h-screen transition-all duration-500',
      themeClass
    ]"
    @click="handleGlobalClick"
  >
    <div class="container mx-auto px-4 py-6 sm:py-12 max-w-2xl">
      <!-- Header with theme toggle and auth status -->
      <div class="flex flex-col sm:flex-row sm:justify-between sm:items-start gap-4 mb-6 sm:mb-8">
        <div class="flex-1 min-w-0">
          <h1 :class="['text-3xl sm:text-5xl font-bold mb-2', textPrimary]">
            My Tasks
          </h1>
          <p :class="['text-base sm:text-lg', accentText]">
            {{ completedCount }} of {{ totalCount }} completed
          </p>
          
          <!-- Auth status message -->
          <div v-if="!currentUser" :class="['text-xs sm:text-sm mt-2 p-2 rounded-lg border-2', warningStyle]">
            ⚠️ Tasks deleted on refresh! 
            <button 
              @click="showAuthModal = true"
              class="underline font-bold hover:opacity-80 transition-opacity"
            >
              Login/Signup
            </button>
            to save!
          </div>
          <div v-else :class="['text-xs sm:text-sm mt-2 p-2 rounded-lg border-2', successStyle]">
            ✅ Welcome, <strong>{{ currentUser.username }}</strong>! Tasks saved permanently.
          </div>
        </div>
        
        <div class="flex items-center gap-2 sm:gap-3 flex-wrap justify-start sm:justify-end">
          <!-- Theme Dropdown - Mobile Optimized -->
          <div class="relative" ref="themeDropdown">
            <button
              @click.stop="toggleThemeMenu"
              :class="[
                'px-3 py-3 sm:px-4 sm:py-3 rounded-xl transition-all duration-300 font-semibold flex items-center gap-2 border-2 text-sm sm:text-base min-h-[44px]',
                buttonSecondary,
                showThemeMenu ? 'ring-2 ring-purple-400 ring-opacity-50' : ''
              ]"
              aria-haspopup="true"
              :aria-expanded="showThemeMenu"
            >
              <component :is="themeIcon" :size="18" class="flex-shrink-0" />
              <span class="hidden sm:inline">{{ currentThemeName }}</span>
              <span class="sm:hidden">Theme</span>
            </button>
            
            <!-- Mobile Full Screen Overlay Dropdown -->
            <transition
              enter-active-class="transition duration-300 ease-out"
              enter-from-class="opacity-0"
              enter-to-class="opacity-100"
              leave-active-class="transition duration-200 ease-in"
              leave-from-class="opacity-100"
              leave-to-class="opacity-0"
            >
              <div 
                v-if="showThemeMenu"
                class="fixed inset-0 z-50 sm:hidden"
                @click="showThemeMenu = false"
              >
                <div class="fixed inset-0 bg-black/50 backdrop-blur-sm"></div>
                <div class="fixed bottom-0 left-0 right-0 max-h-[70vh] overflow-y-auto">
                  <div 
                    :class="[
                      'rounded-t-3xl border-2 p-6 mx-4 mb-4 shadow-2xl',
                      cardStyle
                    ]"
                    @click.stop
                  >
                    <div class="flex justify-between items-center mb-4">
                      <h3 :class="['text-xl font-bold', textPrimary]">Choose Theme</h3>
                      <button
                        @click="showThemeMenu = false"
                        :class="['p-2 rounded-lg transition-all duration-300 hover:scale-110 active:scale-95 min-h-[44px] min-w-[44px] flex items-center justify-center', closeButton]"
                      >
                        <X :size="20" />
                      </button>
                    </div>
                    
                    <div class="space-y-2">
                      <button
                        v-for="theme in themes"
                        :key="theme.value"
                        @click="changeTheme(theme.value)"
                        :class="[
                          'w-full px-4 py-4 rounded-xl transition-all duration-200 flex items-center gap-4 text-left font-semibold text-base min-h-[54px]',
                          'active:scale-95 active:opacity-80',
                          currentTheme === theme.value ? activeThemeOption : inactiveThemeOption
                        ]"
                      >
                        <component 
                          :is="theme.icon" 
                          :size="20" 
                          class="flex-shrink-0" 
                        />
                        <span class="flex-1">{{ theme.name }}</span>
                        
                        <svg 
                          v-if="currentTheme === theme.value"
                          class="w-5 h-5 flex-shrink-0"
                          fill="currentColor" 
                          viewBox="0 0 20 20"
                        >
                          <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
                        </svg>
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </transition>
            
            <!-- Desktop Dropdown -->
            <transition
              enter-active-class="transition duration-200 ease-out"
              enter-from-class="transform scale-95 opacity-0"
              enter-to-class="transform scale-100 opacity-100"
              leave-active-class="transition duration-150 ease-in"
              leave-from-class="transform scale-100 opacity-100"
              leave-to-class="transform scale-95 opacity-0"
            >
              <div 
                v-if="showThemeMenu"
                :class="[
                  'hidden sm:block absolute right-0 mt-2 w-56 rounded-xl shadow-2xl border-2 p-2 z-50 backdrop-blur-lg',
                  cardStyle
                ]"
                role="menu"
                aria-orientation="vertical"
              >
                <button
                  v-for="theme in themes"
                  :key="theme.value"
                  @click="changeTheme(theme.value)"
                  :class="[
                    'w-full px-4 py-3 rounded-lg transition-all duration-200 flex items-center gap-3 text-left font-semibold text-sm',
                    'hover:scale-105 active:scale-95',
                    currentTheme === theme.value ? activeThemeOption : inactiveThemeOption
                  ]"
                  role="menuitem"
                >
                  <component 
                    :is="theme.icon" 
                    :size="16" 
                    class="flex-shrink-0" 
                  />
                  <span class="flex-1">{{ theme.name }}</span>
                  
                  <svg 
                    v-if="currentTheme === theme.value"
                    class="w-4 h-4 flex-shrink-0"
                    fill="currentColor" 
                    viewBox="0 0 20 20"
                  >
                    <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
                  </svg>
                </button>
              </div>
            </transition>
          </div>
          
          <!-- Auth buttons -->
          <button
            v-if="!currentUser"
            @click="showAuthModal = true"
            :class="['px-3 py-3 sm:px-4 sm:py-3 rounded-xl transition-all duration-300 font-semibold border-2 text-sm sm:text-base min-h-[44px] hover:scale-105 active:scale-95', successButton]"
          >
            <span class="hidden sm:inline">💾 Save Tasks</span>
            <span class="sm:hidden">💾 Save</span>
          </button>
          
          <button
            v-else
            @click="logout"
            :class="['px-3 py-3 sm:px-4 sm:py-3 rounded-xl transition-all duration-300 font-semibold border-2 text-sm sm:text-base min-h-[44px] hover:scale-105 active:scale-95', dangerButton]"
          >
            <span class="hidden sm:inline">🚪 Logout</span>
            <span class="sm:hidden">🚪</span>
          </button>
        </div>
      </div>

      <!-- Rest of your existing code remains the same -->
      <!-- Input area -->
      <div :class="['rounded-2xl p-4 sm:p-6 mb-6 shadow-2xl border-2 transition-all duration-300', cardStyle]">
        <div class="flex gap-2 sm:gap-3 flex-col sm:flex-row">
          <input
            type="text"
            v-model="newTask"
            @keypress="handleKeyPress"
            placeholder="What needs to be done?"
            :class="['flex-1 px-4 py-3 rounded-xl border-2 outline-none transition-all duration-300 text-base min-h-[50px] sm:min-h-0', inputStyle]"
          />
          <button
            @click="addTask"
            :disabled="!newTask.trim()"
            :class="[
              'px-4 sm:px-6 py-3 rounded-xl font-bold shadow-lg transition-all duration-300 flex items-center gap-2 border-2 text-base min-h-[50px] sm:min-h-0',
              'hover:scale-105 active:scale-95',
              primaryButton,
              !newTask.trim() ? 'opacity-50 cursor-not-allowed hover:scale-100' : 'hover:shadow-xl'
            ]"
          >
            <Plus :size="18" class="flex-shrink-0" />
            <span class="hidden sm:inline">Add</span>
            <span class="sm:hidden">Add Task</span>
          </button>
        </div>
      </div>

      <!-- Tasks list -->
      <div class="space-y-3">
        <div 
          v-if="tasks.length === 0"
          :class="['text-center py-12 sm:py-16', textTertiary]"
        >
          <p class="text-xl sm:text-2xl mb-2 font-bold">✨ No tasks yet</p>
          <p class="text-sm sm:text-base opacity-70">Add your first task to get started!</p>
        </div>
        
        <div
          v-for="task in tasks"
          :key="task.id"
          :class="[
            'rounded-xl p-3 sm:p-4 shadow-lg border-2 transition-all duration-300 cursor-pointer group',
            'hover:scale-[1.02] active:scale-[0.98]',
            cardStyle,
            task.done ? 'opacity-50' : ''
          ]"
          @click="toggleTask(task.id)"
        >
          <div class="flex items-center gap-3">
            <button
              @click.stop="toggleTask(task.id)"
              :class="[
                'flex-shrink-0 w-6 h-6 sm:w-7 sm:h-7 rounded-full border-3 flex items-center justify-center transition-all duration-300 font-bold',
                'hover:scale-110 active:scale-95',
                task.done? completedCheckbox: checkboxStyle
              ]"
            >
              <Check v-if="task.done" :size="14" class="text-white font-bold" />
            </button>
            
            <span
              :class="[
                'flex-1 cursor-pointer transition-all duration-300 font-medium text-sm sm:text-base break-words',
                task.done ? 'line-through' : '',
                textPrimary
              ]"
            >
              {{ task.text }}
            </span>
            
            <button
              @click.stop="deleteTask(task.id)"
              :class="['flex-shrink-0 p-1 sm:p-2 rounded-lg transition-all duration-300 font-bold min-h-[44px] min-w-[44px] flex items-center justify-center hover:scale-110 active:scale-95', deleteButton]"
            >
              <X :size="16" class="sm:w-5 sm:h-5" />
            </button>
          </div>
        </div>
      </div>

      <!-- Footer stats -->
      <div 
        v-if="tasks.length > 0"
        :class="['mt-6 sm:mt-8 text-center text-sm sm:text-base font-semibold', textSecondary]"
      >
        <p>
          {{ remainingCount }} task{{ remainingCount !== 1 ? 's' : '' }} remaining
        </p>
      </div>

      <!-- Auth Modal -->
      <div 
        v-if="showAuthModal"
        class="fixed inset-0 bg-black/70 backdrop-blur-md flex items-center justify-center z-50 p-4"
        @click="showAuthModal = false"
      >
        <div 
          :class="['rounded-2xl p-6 sm:p-8 shadow-2xl border-2 transition-all duration-300 w-full max-w-md', cardStyle]"
          @click.stop
        >
          <div class="flex justify-between items-center mb-6">
            <h2 :class="['text-2xl sm:text-3xl font-bold', textPrimary]">
              {{ isLogin ? '🔐 Login' : '📝 Sign Up' }}
            </h2>
            <button
              @click="showAuthModal = false"
              :class="['p-2 rounded-lg transition-all duration-300 hover:scale-110 active:scale-95 min-h-[44px] min-w-[44px] flex items-center justify-center', closeButton]"
            >
              <X :size="20" class="sm:w-6 sm:h-6" />
            </button>
          </div>
          
          <form @submit.prevent="handleAuth" class="space-y-4">
            <div>
              <input
                type="text"
                v-model="authForm.username"
                placeholder="Username"
                :class="['w-full px-4 py-3 rounded-xl border-2 outline-none transition-all duration-300 font-medium text-base min-h-[50px]', inputStyle]"
                required
              />
            </div>
            
            <div v-if="!isLogin">
              <input
                type="email"
                v-model="authForm.email"
                placeholder="Email"
                :class="['w-full px-4 py-3 rounded-xl border-2 outline-none transition-all duration-300 font-medium text-base min-h-[50px]', inputStyle]"
                required
              />
            </div>
            
            <div>
              <input
                type="password"
                v-model="authForm.password"
                placeholder="Password"
                :class="['w-full px-4 py-3 rounded-xl border-2 outline-none transition-all duration-300 font-medium text-base min-h-[50px]', inputStyle]"
                required
              />
            </div>
            
            <button
              type="submit"
              :class="['w-full px-6 py-3 rounded-xl font-bold shadow-lg transition-all duration-300 border-2 text-base min-h-[50px] hover:scale-105 active:scale-95', primaryButton]"
            >
              {{ isLogin ? '✅ Login' : '🚀 Sign Up' }}
            </button>
          </form>
          
          <p :class="['text-center mt-6 font-medium text-sm sm:text-base', textSecondary]">
            {{ isLogin ? "Don't have an account?" : "Already have an account?" }}
            <button
              @click="isLogin = !isLogin"
              :class="['font-bold ml-1 hover:opacity-80 transition-opacity', accentText]"
            >
              {{ isLogin ? 'Sign Up' : 'Login' }}
            </button>
          </p>
        </div>
      </div>

      <!-- Toast Container -->
      <div class="fixed top-4 right-4 z-50 space-y-2 max-w-[90vw]">
        <transition-group
          enter-active-class="transition duration-300 ease-out"
          enter-from-class="transform translate-x-full opacity-0"
          enter-to-class="transform translate-x-0 opacity-100"
          leave-active-class="transition duration-200 ease-in"
          leave-from-class="transform translate-x-0 opacity-100"
          leave-to-class="transform translate-x-full opacity-0"
        >
          <div 
            v-for="toast in toasts" 
            :key="toast.id"
            :class="[
              'p-3 sm:p-4 rounded-xl shadow-2xl border-2 transform transition-all duration-300 max-w-sm font-semibold text-sm sm:text-base',
              toastStyle(toast.type)
            ]"
          >
            <div class="flex items-center justify-between gap-3">
              <span class="break-words flex-1">{{ toast.message }}</span>
              <button @click="removeToast(toast.id)" class="hover:opacity-70 transition-opacity flex-shrink-0 ml-2 min-h-[44px] min-w-[44px] flex items-center justify-center">
                <X :size="16" class="sm:w-4 sm:h-4" />
              </button>
            </div>
          </div>
        </transition-group>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { Check, X, Plus, Moon, Sun, Contrast } from 'lucide-vue-next'

// Refs
const themeDropdown = ref(null)
const currentTheme = ref('dark')
const showThemeMenu = ref(false)
const toasts = ref([])
const currentUser = ref(null)
const showAuthModal = ref(false)
const isLogin = ref(true)
const tasks = ref([])
const newTask = ref('')
const users = ref(JSON.parse(localStorage.getItem('todoUsers') || '[]'))
let toastId = 0

// Auth form
const authForm = ref({
  username: '',
  email: '',
  password: ''
})

// Theme configuration
const themes = [
  { value: 'light', name: 'Light Mode', icon: Sun },
  { value: 'dark', name: 'Dark Mode', icon: Moon },
  { value: 'highContrast', name: 'High Contrast', icon: Contrast }
]

// Toast system
const showToast = (message, type = 'info') => {
  const id = toastId++
  toasts.value.push({ id, message, type })
  setTimeout(() => {
    removeToast(id)
  }, 3000)
}

const removeToast = (id) => {
  toasts.value = toasts.value.filter(toast => toast.id !== id)
}

// Theme dropdown interactions
const toggleThemeMenu = () => {
  showThemeMenu.value = !showThemeMenu.value
}

const changeTheme = (theme) => {
  currentTheme.value = theme
  showThemeMenu.value = false
  localStorage.setItem('appTheme', theme)
  showToast(`Theme changed to ${themes.find(t => t.value === theme)?.name}`, 'info')
}

// Global click handler
const handleGlobalClick = (event) => {
  if (showThemeMenu.value && themeDropdown.value && !themeDropdown.value.contains(event.target)) {
    showThemeMenu.value = false
  }
}

// ... rest of your existing JavaScript code remains exactly the same
// (All the auth functions, task management, computed properties, etc.)

// Auth functions
const handleAuth = () => {
  if (isLogin.value) {
    // Login
    const user = users.value.find(u => 
      u.username === authForm.value.username && 
      u.password === authForm.value.password
    )
    
    if (user) {
      currentUser.value = user
      localStorage.setItem('currentUser', JSON.stringify(user))
      loadUserTasks()
      showAuthModal.value = false
      authForm.value = { username: '', email: '', password: '' }
      showToast(`Welcome back, ${user.username}!`, 'success')
    } else {
      showToast('Invalid credentials!', 'error')
    }
  } else {
    // Sign up
    const userExists = users.value.find(u => u.username === authForm.value.username)
    
    if (userExists) {
      showToast('Username already exists!', 'error')
      return
    }
    
    const newUser = {
      id: Date.now(),
      username: authForm.value.username,
      email: authForm.value.email,
      password: authForm.value.password
    }
    
    users.value.push(newUser)
    localStorage.setItem('todoUsers', JSON.stringify(users.value))
    
    currentUser.value = newUser
    localStorage.setItem('currentUser', JSON.stringify(newUser))
    
    saveUserTasks()
    
    showAuthModal.value = false
    authForm.value = { username: '', email: '', password: '' }
    showToast(`Welcome, ${newUser.username}!`, 'success')
  }
}

const logout = () => {
  const username = currentUser.value?.username
  currentUser.value = null
  localStorage.removeItem('currentUser')
  tasks.value = []
  sessionStorage.removeItem('guestTasks')
  showToast(`Goodbye, ${username}!`, 'info')
}

// Task management
const addTask = () => {
  if (!newTask.value.trim()) return
  tasks.value.push({
    id: Date.now(),
    text: newTask.value,
    done: false
  })
  newTask.value = ''
  saveTasks()
  showToast('Task added!', 'success')
}

const toggleTask = (id) => {
  const task = tasks.value.find(task => task.id === id)
  if (task) {
    task.done = !task.done
    saveTasks()
  }
}

const deleteTask = (id) => {
  const taskIndex = tasks.value.findIndex(task => task.id === id)
  if (taskIndex !== -1) {
    tasks.value.splice(taskIndex, 1)
    saveTasks()
    showToast('Task deleted!', 'info')
  }
}

const handleKeyPress = (e) => {
  if (e.key === 'Enter') addTask()
}

// Save/load tasks
const saveTasks = () => {
  if (currentUser.value) {
    saveUserTasks()
  } else {
    sessionStorage.setItem('guestTasks', JSON.stringify(tasks.value))
  }
}

const saveUserTasks = () => {
  if (currentUser.value) {
    const userTasks = JSON.parse(localStorage.getItem('userTasks') || '{}')
    userTasks[currentUser.value.id] = tasks.value
    localStorage.setItem('userTasks', JSON.stringify(userTasks))
  }
}

const loadUserTasks = () => {
  if (currentUser.value) {
    const userTasks = JSON.parse(localStorage.getItem('userTasks') || '{}')
    tasks.value = userTasks[currentUser.value.id] || []
  }
}

// Handle page unload for guests
const handleBeforeUnload = () => {
  if (!currentUser.value) {
    sessionStorage.removeItem('guestTasks')
  }
}

// Keyboard events
const handleEscapeKey = (event) => {
  if (event.key === 'Escape') {
    if (showThemeMenu.value) {
      showThemeMenu.value = false
    }
    if (showAuthModal.value) {
      showAuthModal.value = false
    }
  }
}

// Load initial data
onMounted(() => {
  // Load theme
  const savedTheme = localStorage.getItem('appTheme')
  if (savedTheme) {
    currentTheme.value = savedTheme
  }
  
  // Check if user was logged in
  const savedUser = localStorage.getItem('currentUser')
  if (savedUser) {
    currentUser.value = JSON.parse(savedUser)
    loadUserTasks()
  } else {
    // For guests, load from sessionStorage
    const guestTasks = sessionStorage.getItem('guestTasks')
    if (guestTasks) {
      tasks.value = JSON.parse(guestTasks)
    }
  }
  
  // Add event listeners
  window.addEventListener('beforeunload', handleBeforeUnload)
  document.addEventListener('keydown', handleEscapeKey)
})

onBeforeUnmount(() => {
  window.removeEventListener('beforeunload', handleBeforeUnload)
  document.removeEventListener('keydown', handleEscapeKey)
})

// All your existing computed properties remain exactly the same
const themeClass = computed(() => {
  const themes = {
    light: 'bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50',
    dark: 'bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900',
    highContrast: 'bg-black'
  }
  return themes[currentTheme.value]
})

const textPrimary = computed(() => {
  const styles = {
    light: 'text-slate-900',
    dark: 'text-white',
    highContrast: 'text-white'
  }
  return styles[currentTheme.value]
})

const textSecondary = computed(() => {
  const styles = {
    light: 'text-slate-600',
    dark: 'text-purple-200',
    highContrast: 'text-green-400'
  }
  return styles[currentTheme.value]
})

const textTertiary = computed(() => {
  const styles = {
    light: 'text-purple-400',
    dark: 'text-purple-300',
    highContrast: 'text-yellow-400'
  }
  return styles[currentTheme.value]
})

const accentText = computed(() => {
  const styles = {
    light: 'text-purple-600',
    dark: 'text-purple-300',
    highContrast: 'text-cyan-400'
  }
  return styles[currentTheme.value]
})

const cardStyle = computed(() => {
  const styles = {
    light: 'bg-white/90 border-purple-200 backdrop-blur-lg',
    dark: 'bg-white/10 border-white/20 backdrop-blur-lg',
    highContrast: 'bg-black border-white'
  }
  return styles[currentTheme.value]
})

const inputStyle = computed(() => {
  const styles = {
    light: 'bg-white border-purple-200 text-slate-900 placeholder-gray-500 focus:border-purple-500',
    dark: 'bg-slate-800/50 border-purple-500/30 text-white placeholder-gray-400 focus:border-purple-400',
    highContrast: 'bg-black border-white text-white placeholder-gray-400 focus:border-cyan-400'
  }
  return styles[currentTheme.value]
})

const primaryButton = computed(() => {
  const styles = {
    light: 'bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600 text-white border-purple-500',
    dark: 'bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600 text-white border-purple-400',
    highContrast: 'bg-white hover:bg-green-400 text-black border-white hover:border-green-400'
  }
  return styles[currentTheme.value]
})

const buttonSecondary = computed(() => {
  const styles = {
    light: 'bg-purple-100 hover:bg-purple-200 text-purple-900 border-purple-300',
    dark: 'bg-purple-500/20 hover:bg-purple-500/30 text-purple-300 border-purple-400/50',
    highContrast: 'bg-black hover:bg-cyan-500 text-cyan-400 border-cyan-400 hover:text-black'
  }
  return styles[currentTheme.value]
})

const successButton = computed(() => {
  const styles = {
    light: 'bg-green-100 hover:bg-green-200 text-green-700 border-green-400',
    dark: 'bg-green-500/20 hover:bg-green-500/30 text-green-400 border-green-500/50',
    highContrast: 'bg-black hover:bg-green-400 text-green-400 border-green-400 hover:text-black'
  }
  return styles[currentTheme.value]
})

const dangerButton = computed(() => {
  const styles = {
    light: 'bg-red-100 hover:bg-red-200 text-red-700 border-red-400',
    dark: 'bg-red-500/20 hover:bg-red-500/30 text-red-400 border-red-500/50',
    highContrast: 'bg-black hover:bg-red-500 text-red-500 border-red-500 hover:text-black'
  }
  return styles[currentTheme.value]
})

const deleteButton = computed(() => {
  const styles = {
    light: 'hover:bg-red-100 text-red-600 hover:text-red-700',
    dark: 'hover:bg-red-500/20 text-red-400 hover:text-red-300',
    highContrast: 'hover:bg-red-500 text-red-500 hover:text-black border-2 border-transparent hover:border-red-500'
  }
  return styles[currentTheme.value]
})

const checkboxStyle = computed(() => {
  const styles = {
    light: 'border-2 border-purple-500 hover:border-purple-700 bg-white hover:bg-purple-50',
    dark: 'border-2 border-purple-400 hover:border-purple-300 bg-gray-800/50 hover:bg-purple-500/20',
    highContrast: 'border-2 border-yellow-400 hover:border-green-400 bg-black hover:bg-yellow-400/20'
  }
  return styles[currentTheme.value]
})

const completedCheckbox = computed(() => {
  const styles = {
    light: 'bg-gradient-to-r from-green-500 to-emerald-600 border-2 border-green-600',
    dark: 'bg-gradient-to-r from-green-500 to-emerald-600 border-2 border-green-400',
    highContrast: 'bg-green-500 border-2 border-green-400 hover:border-green-300'
  }
  return styles[currentTheme.value]
})
const closeButton = computed(() => {
  const styles = {
    light: 'hover:bg-purple-100 text-slate-600',
    dark: 'hover:bg-white/10 text-white',
    highContrast: 'hover:bg-red-500 text-white border-2 border-white hover:border-red-500'
  }
  return styles[currentTheme.value]
})

const warningStyle = computed(() => {
  const styles = {
    light: 'text-yellow-700 border-yellow-400 bg-yellow-50',
    dark: 'text-yellow-300 border-yellow-500/50 bg-yellow-500/10',
    highContrast: 'text-yellow-400 border-yellow-400 bg-black'
  }
  return styles[currentTheme.value]
})

const successStyle = computed(() => {
  const styles = {
    light: 'text-green-700 border-green-400 bg-green-50',
    dark: 'text-green-300 border-green-500/50 bg-green-500/10',
    highContrast: 'text-green-400 border-green-400 bg-black'
  }
  return styles[currentTheme.value]
})

const activeThemeOption = computed(() => {
  const styles = {
    light: 'bg-purple-500 text-white',
    dark: 'bg-purple-500 text-white',
    highContrast: 'bg-white text-black'
  }
  return styles[currentTheme.value]
})

const inactiveThemeOption = computed(() => {
  const styles = {
    light: 'hover:bg-purple-50 text-slate-700',
    dark: 'hover:bg-white/10 text-white',
    highContrast: 'hover:bg-cyan-500 text-white hover:text-black'
  }
  return styles[currentTheme.value]
})

const toastStyle = (type) => {
  const baseStyles = {
    light: {
      success: 'bg-green-500 text-white border-green-600',
      error: 'bg-red-500 text-white border-red-600',
      info: 'bg-blue-500 text-white border-blue-600'
    },
    dark: {
      success: 'bg-green-500 text-white border-green-600',
      error: 'bg-red-500 text-white border-red-600',
      info: 'bg-blue-500 text-white border-blue-600'
    },
    highContrast: {
      success: 'bg-green-400 text-black border-green-400',
      error: 'bg-red-500 text-white border-red-500',
      info: 'bg-cyan-400 text-black border-cyan-400'
    }
  }
  return baseStyles[currentTheme.value][type]
}

const currentThemeName = computed(() => {
  return themes.find(t => t.value === currentTheme.value)?.name || 'Dark Mode'
})

const themeIcon = computed(() => {
  return themes.find(t => t.value === currentTheme.value)?.icon || Moon
})

const completedCount = computed(() => tasks.value.filter(t => t.done).length)
const totalCount = computed(() => tasks.value.length)
const remainingCount = computed(() => tasks.value.filter(t => !t.done).length)
</script>

<style>
/* Better touch targets for mobile */
@media (max-width: 640px) {
  button, [role="button"] {
    min-height: 44px;
  }
  input, textarea, select {
    min-height: 44px;
  }
}

/* Smooth scrolling */
html {
  scroll-behavior: smooth;
}

/* Prevent zoom on input focus on mobile */
@media (max-width: 640px) {
  input, textarea, select {
    font-size: 16px;
  }
}

/* Improved mobile dropdown animations */
@media (max-width: 640px) {
  .mobile-dropdown-enter-active,
  .mobile-dropdown-leave-active {
    transition: all 0.3s ease;
  }
  .mobile-dropdown-enter-from {
    transform: translateY(100%);
    opacity: 0;
  }
  .mobile-dropdown-leave-to {
    transform: translateY(100%);
    opacity: 0;
  }
}
</style>