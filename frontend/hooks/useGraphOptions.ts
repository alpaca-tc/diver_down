import { useLocalStorage } from "./useLocalStorage"

export type GraphOptions = {
  compound: boolean
  concentrate: boolean
  onlyModule: boolean
}

export const useGraphOptions = () => {
  return useLocalStorage<GraphOptions>('useGraphOptions', {
    compound: false,
    concentrate: false,
    onlyModule: false,
  })
}
