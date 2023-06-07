<template>
  <div>
    <nav>
      <router-link :to="{ name: 'home' }">Home</router-link> |
      <router-link :to="{ name: 'about', params: { version } }"
        >About</router-link
      >
    </nav>
    <div style="padding: 30px 0 0 0">
      <router-view />
    </div>
  </div>
</template>

<script setup lang="ts">
  const version = "black"
</script>

<style>
  #app {
    font-family: Avenir, Helvetica, Arial, sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    text-align: center;
    color: #2c3e50;
    margin-top: 60px;
  }
</style>
