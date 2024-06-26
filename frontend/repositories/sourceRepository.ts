import useSWR from 'swr'

import { path } from '@/constants/path'
import { Sources, SpecificSource } from '@/models/source'

import { get } from './httpRequest'

type SourcesReponse = {
  sources: Array<{
    source_name: string
    resolved_alias: string | null
    memo: string
    modules: string[]
  }>
  classified_sources_count: number
}

export const useSources = () => {
  const { data, mutate, isLoading } = useSWR<Sources>(path.api.sources.index(), async () => {
    const response = await get<SourcesReponse>(path.api.sources.index())
    return {
      sources: response.sources.map((source) => ({
        sourceName: source.source_name,
        resolvedAlias: source.resolved_alias,
        memo: source.memo,
        modules: source.modules,
      })),
      classifiedSourcesCount: response.classified_sources_count,
    }
  })

  return { data, mutate, isLoading }
}

type SpecificSourceResponse = {
  source_name: string
  resolved_alias: string | null
  memo: string
  modules: string[]
  related_definitions: Array<{
    id: number
    title: string
  }>
  reverse_dependencies: Array<{
    source_name: string
    modules: string[]
    method_ids: Array<{
      name: string
      context: 'instance' | 'class'
      paths: string[]
    }>
  }>
}

export const useSource = (sourceName: string) => {
  const { data, isLoading } = useSWR(path.api.sources.show(sourceName), async (): Promise<SpecificSource> => {
    const response = await get<SpecificSourceResponse>(path.api.sources.show(sourceName))

    return {
      sourceName: response.source_name,
      resolvedAlias: response.resolved_alias,
      memo: response.memo,
      modules: response.modules,
      relatedDefinitions: response.related_definitions.map((definition) => ({ id: definition.id, title: definition.title })),
      reverseDependencies: response.reverse_dependencies.map((dependency) => ({
        sourceName: dependency.source_name,
        modules: dependency.modules,
        methodIds: dependency.method_ids.map((methodId) => ({
          name: methodId.name,
          context: methodId.context,
          paths: methodId.paths,
        })),
      })),
    }
  })

  return { specificSource: data, isLoading }
}
