import { path } from '@/constants/path'
import { fetchCombinedDefinition, stringifyCombinedDefinitionOptions } from './combinedDefinitionRepository'
import useSWR from 'swr'
import { GraphOptions } from '@/models/combinedDefinition'
import { Module } from '@/models/module'
import { get } from './httpRequest'

export const useGlobalDefinition = (graphOptions: GraphOptions) => {
  const requestPath = `${path.api.globalDefinition.show()}?${stringifyCombinedDefinitionOptions(graphOptions)}`
  const { data, isLoading, mutate } = useSWR(requestPath, fetchCombinedDefinition)

  return { data, isLoading, mutate }
}

type GlobalDefinitionModulesReponse = {
  modules_list: {
    module_name: string
  }[][]
}

export const useGlobalDefinitionDependedModules = (moduleNames: string[]) => {
  const requestPath = path.api.globalDefinition.dependedModules(moduleNames)
  const { data, mutate, isLoading } = useSWR<Module[][], any, string>(requestPath)

  return {
    data,
    isLoading,
    mutate: () => {
      mutate(
        get<GlobalDefinitionModulesReponse>(requestPath).then((response) => {
          return response.modules_list.map((modules) => modules.map((module) => ({ moduleName: module.module_name })))
        }),
      )
    },
  }
}
