import useSWR from 'swr'

import { path } from '@/constants/path'
import { Module, SpecificModule } from '@/models/module'

import { get } from './httpRequest'

type SourcesReponse = {
  modules: Array<{ module_name: string }>
}

export const useModules = () => {
  const { data, isLoading } = useSWR<Module[]>(path.api.modules.index(), async () => {
    const response = await get<SourcesReponse>(path.api.modules.index())
    return response.modules.map((source) => ({ moduleName: source.module_name }))
  })

  return { modules: data, isLoading }
}

type SpecificModuleResponse = {
  module_name: string
  related_definitions: Array<{
    id: number
    title: string
  }>
  sources: Array<{
    source_name: string
  }>
}

export const useModule = (moduleName: string) => {
  const { data, isLoading } = useSWR<SpecificModule>(path.api.modules.show(moduleName), async (): Promise<SpecificModule> => {
    const response = await get<SpecificModuleResponse>(path.api.modules.show(moduleName))

    return {
      moduleName: response.module_name,
      sources: response.sources.map((source) => ({ sourceName: source.source_name })),
      relatedDefinitions: response.related_definitions.map((definition) => ({ id: definition.id, title: definition.title })),
    }
  })

  return { specificModule: data, isLoading }
}
