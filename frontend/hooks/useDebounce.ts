import { DependencyList, useCallback, useEffect, useRef } from 'react'

export const useDebounce = (callback: () => void, delay: number, dependencies: DependencyList): void => {
  const timer = useRef<NodeJS.Timeout>()

  const clearDebounce = useCallback(() => {
    if (timer.current) {
      clearTimeout(timer.current)
      timer.current = undefined
    }
  }, [])

  const debounce = useCallback(() => {
    clearDebounce()
    timer.current = setTimeout(() => {
      callback()
    }, delay)
  }, [callback, clearDebounce, delay])

  useEffect(debounce, dependencies)
}
