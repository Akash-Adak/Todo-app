<template>
  <div 
    :class="[
      'min-h-screen transition-all duration-500',
      themeClass
    ]"
  >
    <div class="container mx-auto px-4 py-12 max-w-2xl">
      <!-- Header with theme toggle and auth status -->
      <div class="flex justify-between items-start mb-8 gap-4 flex-wrap">
        <div class="flex-1 min-w-[250px]">
          <h1 :class="['text-5xl font-bold mb-2', textPrimary]">
            My Tasks
          </h1>
          <p :class="['text-lg', accentText]">
            {{ completedCount }} of {{ totalCount }} completed
          </p>
          
          <!-- Auth status message -->
          <div v-if="!currentUser" :class="['text-sm mt-2 p-2 rounded-lg border-2', warningStyle]">
            ⚠️ Tasks deleted on refresh! 
            <button 
              @click="showAuthModal = true"
              class="underline font-bold hover:opacity-80"
            >
              Login/Signup
            </button>
            to save!
          </div>
          <div v-else :class="['text-sm mt-2 p-2 rounded-lg border-2', successStyle]">
            ✅ Welcome, <strong>{{ currentUser.username }}</strong>! Tasks saved permanently.
          </div>
        </div>
        
        <div class="flex items-center gap-3 flex-wrap">
          <!-- Theme Dropdown -->
          <div class="relative">
            <button
              @click="showThemeMenu = !showThemeMenu"
              :class="[
                'px-4 py-3 rounded-xl transition-all duration-300 font-semibold flex items-center gap-2 border-2',
                buttonSecondary
              ]"
            >
              <component :is="themeIcon" :size="20" />
              {{ currentThemeName }}
            </button>
            
            <div 
              v-if="showThemeMenu"
              :class="[
                'absolute right-0 mt-2 w-56 rounded-xl shadow-2xl border-2 p-2 z-50',
                cardStyle
              ]"
            >
              <button
                v-for="theme in themes"
                :key="theme.value"
                @click="changeTheme(theme.value)"
                :class="[
                  'w-full px-4 py-3 rounded-lg transition-all duration-200 flex items-center gap-3 text-left font-semibold',
                  currentTheme === theme.value ? activeThemeOption : inactiveThemeOption
                ]"
              >
                <component :is="theme.icon" :size="18" />
                {{ theme.name }}
              </button>
            </div>
          </div>
          
          <!-- Auth buttons -->
          <button
            v-if="!currentUser"
            @click="showAuthModal = true"
            :class="['px-4 py-3 rounded-xl transition-all duration-300 font-semibold border-2', successButton]"
          >
            💾 Save Tasks
          </button>
          
          <button
            v-else
            @click="logout"
            :class="['px-4 py-3 rounded-xl transition-all duration-300 font-semibold border-2', dangerButton]"
          >
            🚪 Logout
          </button>
        </div>
      </div>

      <!-- Input area -->
      <div :class="['rounded-2xl p-6 mb-6 shadow-2xl border-2 transition-all duration-300', cardStyle]">
        <div class="flex gap-3">
          <input
            type="text"
            v-model="newTask"
            @keypress="handleKeyPress"
            placeholder="What needs to be done?"
            :class="['flex-1 px-4 py-3 rounded-xl border-2 outline-none transition-all duration-300', inputStyle]"
          />
          <button
            @click="addTask"
            :class="['px-6 py-3 rounded-xl font-bold shadow-lg hover:shadow-xl transition-all duration-300 flex items-center gap-2 border-2', primaryButton]"
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
          :class="['text-center py-16', textTertiary]"
        >
          <p class="text-2xl mb-2 font-bold">✨ No tasks yet</p>
          <p class="text-base opacity-70">Add your first task to get started!</p>
        </div>
        
        <div
          v-for="task in tasks"
          :key="task.id"
          :class="[
            'rounded-xl p-4 shadow-lg border-2 transition-all duration-300 hover:scale-[1.02] cursor-pointer',
            cardStyle,
            task.done ? 'opacity-50' : ''
          ]"
        >
          <div class="flex items-center gap-3">
            <button
              @click="toggleTask(task.id)"
              :class="[
                'flex-shrink-0 w-7 h-7 rounded-full border-3 flex items-center justify-center transition-all duration-300 font-bold',
                task.done ? completedCheckbox : checkboxStyle
              ]"
            >
              <Check v-if="task.done" :size="16" class="text-white font-bold" />
            </button>
            
            <span
              @click="toggleTask(task.id)"
              :class="[
                'flex-1 cursor-pointer transition-all duration-300 font-medium',
                task.done ? 'line-through' : '',
                textPrimary
              ]"
            >
              {{ task.text }}
            </span>
            
            <button
              @click="deleteTask(task.id)"
              :class="['flex-shrink-0 p-2 rounded-lg transition-all duration-300 font-bold', deleteButton]"
            >
              <X :size="20" />
            </button>
          </div>
        </div>
      </div>

      <!-- Footer stats -->
      <div 
        v-if="tasks.length > 0"
        :class="['mt-8 text-center text-base font-semibold', textSecondary]"
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
          :class="['rounded-2xl p-8 shadow-2xl border-2 transition-all duration-300 w-full max-w-md', cardStyle]"
          @click.stop
        >
          <div class="flex justify-between items-center mb-6">
            <h2 :class="['text-3xl font-bold', textPrimary]">
              {{ isLogin ? '🔐 Login' : '📝 Sign Up' }}
            </h2>
            <button
              @click="showAuthModal = false"
              :class="['p-2 rounded-lg transition-all duration-300', closeButton]"
            >
              <X :size="24" />
            </button>
          </div>
          
          <form @submit.prevent="handleAuth" class="space-y-4">
            <div>
              <input
                type="text"
                v-model="authForm.username"
                placeholder="Username"
                :class="['w-full px-4 py-3 rounded-xl border-2 outline-none transition-all duration-300 font-medium', inputStyle]"
                required
              />
            </div>
            
            <div v-if="!isLogin">
              <input
                type="email"
                v-model="authForm.email"
                placeholder="Email"
                :class="['w-full px-4 py-3 rounded-xl border-2 outline-none transition-all duration-300 font-medium', inputStyle]"
                required
              />
            </div>
            
            <div>
              <input
                type="password"
                v-model="authForm.password"
                placeholder="Password"
                :class="['w-full px-4 py-3 rounded-xl border-2 outline-none transition-all duration-300 font-medium', inputStyle]"
                required
              />
            </div>
            
            <button
              type="submit"
              :class="['w-full px-6 py-3 rounded-xl font-bold shadow-lg hover:shadow-xl transition-all duration-300 border-2', primaryButton]"
            >
              {{ isLogin ? '✅ Login' : '🚀 Sign Up' }}
            </button>
          </form>
          
          <p :class="['text-center mt-6 font-medium', textSecondary]">
            {{ isLogin ? "Don't have an account?" : "Already have an account?" }}
            <button
              @click="isLogin = !isLogin"
              :class="['font-bold ml-1 hover:opacity-80', accentText]"
            >
              {{ isLogin ? 'Sign Up' : 'Login' }}
            </button>
          </p>
        </div>
      </div>

      <!-- Toast Container -->
      <div class="fixed top-4 right-4 z-50 space-y-2">
        <div 
          v-for="toast in toasts" 
          :key="toast.id"
          :class="[
            'p-4 rounded-xl shadow-2xl border-2 transform transition-all duration-300 max-w-sm font-semibold',
            toastStyle(toast.type)
          ]"
        >
          <div class="flex items-center justify-between gap-3">
            <span>{{ toast.message }}</span>
            <button @click="removeToast(toast.id)" class="hover:opacity-70">
              <X :size="18" />
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { Check, X, Plus, Moon, Sun, Contrast } from 'lucide-vue-next'

// Theme configuration
const themes = [
  { value: 'light', name: 'Light Mode', icon: Sun },
  { value: 'highContrast', name: 'Dark Mode', icon: Moon },
//   { value: 'highContrast', name: 'High Contrast', icon: Contrast }
]

const currentTheme = ref('dark')
const showThemeMenu = ref(false)

// Toast system
const toasts = ref([])
let toastId = 0

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

// Auth state
const currentUser = ref(null)
const showAuthModal = ref(false)
const isLogin = ref(true)
const authForm = ref({
  username: '',
  email: '',
  password: ''
})

// Todo state
const tasks = ref([])
const newTask = ref('')

// User management
const users = ref(JSON.parse(localStorage.getItem('todoUsers') || '[]'))

// Session tracking for guest tasks
let sessionActive = true

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
  
  // Clear tasks for guest mode
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

const changeTheme = (theme) => {
  currentTheme.value = theme
  showThemeMenu.value = false
  localStorage.setItem('appTheme', theme)
}

// Save tasks based on user status
const saveTasks = () => {
  if (currentUser.value) {
    saveUserTasks()
  } else {
    // Use sessionStorage for guests - will be cleared on page refresh
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
    // Clear guest tasks on page unload
    sessionStorage.removeItem('guestTasks')
  }
}

// Load tasks on app start
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
    showToast(`Welcome back, ${currentUser.value.username}!`, 'success')
  } else {
    // For guests, only load from sessionStorage (not localStorage)
    // This ensures tasks are deleted on refresh
    const guestTasks = sessionStorage.getItem('guestTasks')
    if (guestTasks) {
      tasks.value = JSON.parse(guestTasks)
    }
  }
  
  // Add event listener for page unload
  window.addEventListener('beforeunload', handleBeforeUnload)
})

onBeforeUnmount(() => {
  window.removeEventListener('beforeunload', handleBeforeUnload)
})

// Computed theme styles
const themeClass = computed(() => {
  const themes = {
    light: 'bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50',
    // dark: 'bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900',
    highContrast: 'bg-black'
  }
  return themes[currentTheme.value]
})

const textPrimary = computed(() => {
  const styles = {
    light: 'text-slate-900',
    // dark: 'text-white',
    highContrast: 'text-white'
  }
  return styles[currentTheme.value]
})

const textSecondary = computed(() => {
  const styles = {
    light: 'text-slate-600',
    // dark: 'text-purple-200',
    highContrast: 'text-green-400'
  }
  return styles[currentTheme.value]
})

const textTertiary = computed(() => {
  const styles = {
    light: 'text-purple-400',
    // dark: 'text-purple-300',
    highContrast: 'text-yellow-400'
  }
  return styles[currentTheme.value]
})

const accentText = computed(() => {
  const styles = {
    light: 'text-purple-600',
    // dark: 'text-purple-300',
    highContrast: 'text-cyan-400'
  }
  return styles[currentTheme.value]
})

const cardStyle = computed(() => {
  const styles = {
    light: 'bg-white/90 border-purple-200 backdrop-blur-lg',
    // dark: 'bg-white/10 border-white/20 backdrop-blur-lg',
    highContrast: 'bg-black border-white'
  }
  return styles[currentTheme.value]
})

const inputStyle = computed(() => {
  const styles = {
    light: 'bg-white border-purple-200 text-slate-900 placeholder-gray-500 focus:border-purple-500',
    // dark: 'bg-slate-800/50 border-purple-500/30 text-white placeholder-gray-400 focus:border-purple-400',
    highContrast: 'bg-black border-white text-white placeholder-gray-400 focus:border-cyan-400'
  }
  return styles[currentTheme.value]
})

const primaryButton = computed(() => {
  const styles = {
    light: 'bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600 text-white border-purple-500',
    // dark: 'bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600 text-white border-purple-400',
    highContrast: 'bg-white hover:bg-green-400 text-black border-white hover:border-green-400'
  }
  return styles[currentTheme.value]
})

const buttonSecondary = computed(() => {
  const styles = {
    light: 'bg-purple-100 hover:bg-purple-200 text-purple-900 border-purple-300',
    // dark: 'bg-purple-500/20 hover:bg-purple-500/30 text-purple-300 border-purple-400/50',
    highContrast: 'bg-black hover:bg-cyan-500 text-cyan-400 border-cyan-400 hover:text-black'
  }
  return styles[currentTheme.value]
})

const successButton = computed(() => {
  const styles = {
    light: 'bg-green-100 hover:bg-green-200 text-green-700 border-green-400',
    // dark: 'bg-green-500/20 hover:bg-green-500/30 text-green-400 border-green-500/50',
    highContrast: 'bg-black hover:bg-green-400 text-green-400 border-green-400 hover:text-black'
  }
  return styles[currentTheme.value]
})

const dangerButton = computed(() => {
  const styles = {
    light: 'bg-red-100 hover:bg-red-200 text-red-700 border-red-400',
    // dark: 'bg-red-500/20 hover:bg-red-500/30 text-red-400 border-red-500/50',
    highContrast: 'bg-black hover:bg-red-500 text-red-500 border-red-500 hover:text-black'
  }
  return styles[currentTheme.value]
})

const deleteButton = computed(() => {
  const styles = {
    light: 'hover:bg-red-100 text-red-600 hover:text-red-700',
    // dark: 'hover:bg-red-500/20 text-red-400 hover:text-red-300',
    highContrast: 'hover:bg-red-500 text-red-500 hover:text-black border-2 border-transparent hover:border-red-500'
  }
  return styles[currentTheme.value]
})

const checkboxStyle = computed(() => {
  const styles = {
    light: 'border-purple-400 hover:border-purple-600',
    // dark: 'border-purple-400 hover:border-purple-300',
    highContrast: 'border-white hover:border-green-400'
  }
  return styles[currentTheme.value]
})

const completedCheckbox = computed(() => {
  return 'bg-gradient-to-r from-green-400 to-emerald-500 border-green-400'
})

const closeButton = computed(() => {
  const styles = {
    light: 'hover:bg-purple-100 text-slate-600',
    // dark: 'hover:bg-white/10 text-white',
    highContrast: 'hover:bg-red-500 text-white border-2 border-white hover:border-red-500'
  }
  return styles[currentTheme.value]
})

const warningStyle = computed(() => {
  const styles = {
    light: 'text-yellow-700 border-yellow-400 bg-yellow-50',
    // dark: 'text-yellow-300 border-yellow-500/50 bg-yellow-500/10',
    highContrast: 'text-yellow-400 border-yellow-400 bg-black'
  }
  return styles[currentTheme.value]
})

const successStyle = computed(() => {
  const styles = {
    light: 'text-green-700 border-green-400 bg-green-50',
    // dark: 'text-green-300 border-green-500/50 bg-green-500/10',
    highContrast: 'text-green-400 border-green-400 bg-black'
  }
  return styles[currentTheme.value]
})

const activeThemeOption = computed(() => {
  const styles = {
    light: 'bg-purple-500 text-white',
    // dark: 'bg-purple-500 text-white',
    highContrast: 'bg-white text-black'
  }
  return styles[currentTheme.value]
})

const inactiveThemeOption = computed(() => {
  const styles = {
    light: 'hover:bg-purple-50 text-slate-700',
    // dark: 'hover:bg-white/10 text-white',
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
    // dark: {
    //   success: 'bg-green-500 text-white border-green-600',
    //   error: 'bg-red-500 text-white border-red-600',
    //   info: 'bg-blue-500 text-white border-blue-600'
    // },
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

// Computed properties
const completedCount = computed(() => tasks.value.filter(t => t.done).length)
const totalCount = computed(() => tasks.value.length)
const remainingCount = computed(() => tasks.value.filter(t => !t.done).length)
</script>