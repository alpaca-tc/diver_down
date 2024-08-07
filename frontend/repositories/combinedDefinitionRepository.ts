import useSWR from 'swr'

import { path } from '@/constants/path'
import { CombinedDefinition, DotMetadata, GraphOptions } from '@/models/combinedDefinition'
import { bitIdToIds } from '@/utils/bitId'
import { stringify } from '@/utils/queryString'

import { get } from './httpRequest'

type DotSourceMetadataResponse = {
  id: string
  type: 'source'
  memo: string
  source_name: string
  module: string | null
}

type DotDependencyMetadataResponse = {
  id: string
  type: 'dependency'
  dependencies: Array<{
    source_name: string
    method_ids: Array<{
      name: string
      context: 'class' | 'instance'
    }>
  }>
}

type DotModuleMetadataResponse = {
  id: string
  type: 'module'
  module: string
}

type DotMetadataResponse = DotSourceMetadataResponse | DotDependencyMetadataResponse | DotModuleMetadataResponse

type CombinedDefinitionReponse = {
  bit_id: string
  titles: string[]
  dot: string
  dot_metadata: DotMetadataResponse[]
  sources: Array<{
    source_name: string
    resolved_alias: string | null
    memo: string
    module: string | null
    dependencies: Array<{
      source_name: string
    }>
  }>
}

const parseDotMetadata = (metadata: DotMetadataResponse): DotMetadata => {
  switch (metadata.type) {
    case 'source': {
      return {
        id: metadata.id,
        type: metadata.type,
        sourceName: metadata.source_name,
        memo: metadata.memo,
        module: metadata.module,
      }
    }
    case 'dependency': {
      return {
        id: metadata.id,
        type: metadata.type,
        dependencies: metadata.dependencies.map((dependency) => ({
          sourceName: dependency.source_name,
          methodIds: dependency.method_ids.map((methodId) => ({
            name: methodId.name,
            context: methodId.context,
            human: `${methodId.context === 'class' ? '.' : '#'}${methodId.name}`,
          })),
        })),
      }
    }
    case 'module': {
      return {
        id: metadata.id,
        type: metadata.type,
        module: metadata.module,
      }
    }
  }
}

export const fetchCombinedDefinition = async (requestPath: string): Promise<CombinedDefinition> => {
  const response = await get<CombinedDefinitionReponse>(requestPath)

  return {
    ids: bitIdToIds(BigInt(response.bit_id)),
    titles: response.titles,
    dot: response.dot,
    dotMetadata: response.dot_metadata.map((res) => parseDotMetadata(res)),
    sources: response.sources.map((source) => ({
      sourceName: source.source_name,
      resolvedAlias: source.resolved_alias,
      memo: source.memo,
      module: source.module,
      dependencies: source.dependencies.map((dependency) => ({
        sourceName: dependency.source_name,
      })),
    })),
  }
}

export const stringifyCombinedDefinitionOptions = (graphOptions: GraphOptions): string => {
  const params = {
    compound: graphOptions.compound,
    concentrate: graphOptions.concentrate,
    only_module: graphOptions.onlyModule,
    focusModules: graphOptions.focusModules,
    modules: graphOptions.modules,
    remove_internal_sources: graphOptions.removeInternalSources,
  }

  return stringify(params)
}

export const useCombinedDefinition = (ids: number[], graphOptions: GraphOptions) => {
  const requestPath = `${path.api.definitions.show(ids)}?${stringifyCombinedDefinitionOptions(graphOptions)}`
  const shouldFetch = ids.length > 0
  const { data, isLoading, mutate } = useSWR(shouldFetch ? requestPath : null, fetchCombinedDefinition)

  return { data, isLoading, mutate }
}
