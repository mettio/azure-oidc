<template>
  <div class="home">
    <HelloWorld :msg="msg" :color="color" :version="frontcolorVersion" />
  </div>
</template>

<script setup lang="ts">
  import HelloWorld from "@/components/HelloWorld.vue"
  import { version as frontcolorVersion } from "../../package.json"

  const color = "black"
  const msg = `Welcome to ${color}`
</script>
