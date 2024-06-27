import { GraphOptions, defaultGraphOptions } from '@/models/combinedDefinition'
import { useLocalStorage } from './useLocalStorage'
import { useSearchParamsState } from './useSearchParamsState'

export const useLocalStorageGraphOptions = () => {
  return useLocalStorage<GraphOptions>('useGraphOptions', defaultGraphOptions)
}

const toBoolean = (val: any) => val === '1'

export const useSearchParamsGraphOptions = () => {
  return useSearchParamsState<GraphOptions>({
    compound: toBoolean,
    concentrate: toBoolean,
    onlyModule: toBoolean,
    modules: (modules: any) => {
      if (Array.isArray(modules) && modules.every((module) => typeof module === 'string')) {
        return modules as string[]
      } else {
        return []
      }
    },
    removeInternalSources: toBoolean,
  })
}
