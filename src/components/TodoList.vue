<template>
  <div class="todo-container">
    <h1>📝 Vue To-Do List</h1>
    <div class="input-area">
      <input v-model="newTask" placeholder="Enter a task" @keyup.enter="addTask" />
      <button @click="addTask">Add</button>
    </div>

    <ul>
      <li v-for="(task, index) in tasks" :key="index">
        <span :class="{ done: task.done }" @click="toggleTask(index)">
          {{ task.text }}
        </span>
        <button @click="deleteTask(index)">❌</button>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'

const newTask = ref('')
const tasks = ref([])

onMounted(() => {
  const saved = localStorage.getItem('tasks')
  if (saved) tasks.value = JSON.parse(saved)
})

watch(tasks, (val) => {
  localStorage.setItem('tasks', JSON.stringify(val))
}, { deep: true })

function addTask() {
  if (!newTask.value.trim()) return
  tasks.value.push({ text: newTask.value, done: false })
  newTask.value = ''
}

function toggleTask(index) {
  tasks.value[index].done = !tasks.value[index].done
}

function deleteTask(index) {
  tasks.value.splice(index, 1)
}
</script>

<style scoped>
.todo-container {
  max-width: 400px;
  margin: 60px auto;
  background: #fff;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0,0,0,0.1);
  font-family: sans-serif;
}
.input-area {
  display: flex;
  gap: 8px;
  margin-bottom: 15px;
}
input {
  flex: 1;
  padding: 8px;
}
.done {
  text-decoration: line-through;
  color: gray;
}
button {
  cursor: pointer;
}
</style>
