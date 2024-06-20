import useSWR from 'swr'

import { path } from '@/constants/path'
import { Module, SpecificModule } from '@/models/module'

import { get } from './httpRequest'

type ModulesReponse = {
  modules: string[][]
}

export const useModules = () => {
  const { data, isLoading, mutate } = useSWR<Module[][]>(path.api.modules.index(), async () => {
    const response = await get<ModulesReponse>(path.api.modules.index())
    return response.modules
  })

  return { data, isLoading, mutate }
}

type SpecificModuleResponse = {
  modules: string[]
  related_definitions: Array<{
    id: number
    title: string
  }>
  sources: Array<{
    source_name: string
    memo: string
  }>
}

export const useModule = (moduleNames: string[]) => {
  const { data, isLoading } = useSWR<SpecificModule>(path.api.modules.show(moduleNames), async (): Promise<SpecificModule> => {
    const response = await get<SpecificModuleResponse>(path.api.modules.show(moduleNames))

    return {
      modules: response.modules,
      sources: response.sources.map((source) => ({
        sourceName: source.source_name,
        memo: source.memo,
      })),
      relatedDefinitions: response.related_definitions.map((definition) => ({
        id: definition.id,
        title: definition.title,
      })),
    }
  })

  return { data, isLoading }
}
