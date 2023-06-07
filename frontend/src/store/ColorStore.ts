import { defineStore } from "pinia"
import axios from "axios"
import type { Color } from "@/interfaces"

export const useColorStore = defineStore("color", () => {
  async function getColor(): Promise<Color> {
    try {
      const response = await axios.get("/color", form)
      console.log(response)
      return response
    } catch (e: Error) {
      console.log("Color could not be fetched from backend")
    }
  }

  return { getColor }
})
