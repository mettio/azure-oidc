import { fileURLToPath, URL } from "node:url"
import { loadEnv, defineConfig } from "vite"
import vue from "@vitejs/plugin-vue"

// import { defineConfig } from 'vite'
// import vue from '@vitejs/plugin-vue'
// import { resolve } from 'path'
import { gitDescribe, gitDescribeSync } from "git-describe"
// process.env.VUE_APP_GIT_HASH = gitDescribeSync().hash

/**
 * Vite Configure
 *
 * @see {@link https://vitejs.dev/config/}
 */
export default ({ mode }) => {
  // needed for endpoint proxy
  const env = loadEnv(mode, process.cwd())
  return defineConfig({
    server: {
      proxy: {
        "/contact": env.VITE_APP_CONTACT_ENDPOINT,
      },
    },
    plugins: [vue()],
    resolve: {
      alias: {
        "@": fileURLToPath(new URL("./src", import.meta.url)),
      },
    },
  })
}
