import { GraphOptions, defaultGraphOptions } from '@/models/combinedDefinition'
import { useLocalStorage } from './useLocalStorage'
import { useSearchParamsState } from './useSearchParamsState'
import { Module } from '@/models/module'

const toModules = (modules: any): Module[] => {
  if (Array.isArray(modules) && modules.every((module) => typeof module === 'string')) {
    return modules as Module[]
  } else {
    return []
  }
}

export const useLocalStorageGraphOptions = () => {
  const toBoolean = (val: any) => (typeof val === 'boolean' ? val : false)

  return useLocalStorage<GraphOptions>('useGraphOptions', {
    compound: toBoolean,
    concentrate: toBoolean,
    onlyModule: toBoolean,
    focusModules: toModules,
    modules: toModules,
    removeInternalSources: toBoolean,
  })
}

export const useSearchParamsGraphOptions = () => {
  const toBoolean = (val: any) => val === '1'

  return useSearchParamsState<GraphOptions>({
    compound: toBoolean,
    concentrate: toBoolean,
    onlyModule: toBoolean,
    focusModules: toModules,
    modules: toModules,
    removeInternalSources: toBoolean,
  })
}
