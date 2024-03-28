import useSWR from 'swr'

import { path } from '@/constants/path'
import { SpecificSource } from '@/models/source'

import { get } from './httpRequest'

type SourcesReponse = {
  sources: Array<{ source_name: string }>
}

export const useSources = () => {
  const { data, isLoading } = useSWR(
    path.api.sources.index(),
    async () => {
      const response = await get<SourcesReponse>(path.api.sources.index())
      return response.sources.map((source) => ({ sourceName: source.source_name }))
    }
  )

  return { sources: data, isLoading }
}

type SpecificSourceResponse = {
  source_name: string,
  modules: Array<{
    module_name: string
  }>,
  related_definitions: Array<{
    id: number
    title: string
  }>,
  reverse_dependencies: Array<{
    source_name: string
    method_ids: Array<{
      name: string
      context: 'instance' | 'class'
      paths: string[]
    }>
  }>
}

export const useSource = (sourceName: string) => {
  const { data, isLoading } = useSWR(
    path.api.sources.show(sourceName),
    async (): Promise<SpecificSource> => {
      const response = await get<SpecificSourceResponse>(path.api.sources.index())

      return {
        sourceName: response.source_name,
        modules: response.modules.map((module) => ({ moduleName: module.module_name })),
        relatedDefinitions: response.related_definitions.map((definition) => ({ id: definition.id, title: definition.title })),
        reverseDependencies: response.reverse_dependencies.map((dependency) => ({
          sourceName: dependency.source_name,
          methodIds: dependency.method_ids.map((methodId) => ({
            name: methodId.name,
            context: methodId.context,
            paths: methodId.paths
          }))
        }))
      }
    }
  )

  return { data, isLoading }
}
