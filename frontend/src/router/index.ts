import { createRouter, createWebHistory, RouteRecordRaw } from "vue-router"

import HomeView from "@/views/HomeView.vue"
import AboutView from "@/views/AboutView.vue"

const routes: Array<RouteRecordRaw> = [
  {
    path: "/",
    name: "home",
    component: HomeView,
  },
  {
    path: "/about/:version",
    name: "about",
    component: AboutView,
  },
]

export const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router
