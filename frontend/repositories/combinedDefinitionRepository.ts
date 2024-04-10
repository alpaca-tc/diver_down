import useSWR from 'swr'

import { path } from '@/constants/path'
import { CombinedDefinition, DotMetadata } from '@/models/combinedDefinition'
import { bitIdToIds } from '@/utils/bitId'
import { stringify } from '@/utils/queryString'

import { get } from './httpRequest'

type DotSourceMetadataResponse = {
  id: string
  type: 'source'
  source_name: string
  modules: Array<{
    module_name: string
  }>
}

type DotDependencyMetadataResponse = {
  id: string
  type: 'dependency'
  source_name: string
  method_ids: Array<{
    name: string
    context: 'class' | 'instance'
  }>
}

type DotModuleMetadataResponse = {
  id: string
  type: 'module'
  modules: Array<{
    module_name: string
  }>
}

type DotMetadataResponse = DotSourceMetadataResponse | DotDependencyMetadataResponse | DotModuleMetadataResponse

type CombinedDefinitionReponse = {
  bit_id: string
  titles: string[]
  dot: string
  dot_metadata: DotMetadataResponse[]
  sources: Array<{
    source_name: string
    modules: Array<{
      module_name: string
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
        modules: metadata.modules.map((module) => ({
          moduleName: module.module_name,
        })),
      }
    }
    case 'dependency': {
      return {
        id: metadata.id,
        type: metadata.type,
        sourceName: metadata.source_name,
        methodIds: metadata.method_ids.map((methodId) => ({
          name: methodId.name,
          context: methodId.context,
          human: `${methodId.context === 'class' ? '.' : '#'}${methodId.name}`,
        })),
      }
    }
    case 'module': {
      return {
        id: metadata.id,
        type: metadata.type,
        modules: metadata.modules.map((module) => ({
          moduleName: module.module_name,
        })),
      }
    }
  }
}

const fetchDefinitionShow = async (requestPath: string): Promise<CombinedDefinition> => {
  const response = await get<CombinedDefinitionReponse>(requestPath)

  return {
    ids: bitIdToIds(BigInt(response.bit_id)),
    titles: response.titles,
    dot: response.dot,
    dotMetadata: response.dot_metadata.map((res) => parseDotMetadata(res)),
    sources: response.sources.map((source) => ({
      sourceName: source.source_name,
      modules: source.modules.map((module) => ({
        moduleName: module.module_name,
      })),
    })),
  }
}

const toBooleanFlag = (value: boolean) => (value ? '1' : null)

export const useCombinedDefinition = (ids: number[], compound: boolean, concentrate: boolean) => {
  const params = {
    compound: toBooleanFlag(compound),
    concentrate: toBooleanFlag(concentrate),
  }
  const requestPath = `${path.api.definitions.show(ids)}?${stringify(params)}`
  const shouldFetch = ids.length > 0
  const { data, isLoading, mutate } = useSWR(shouldFetch ? requestPath : null, fetchDefinitionShow)

  return { data, isLoading, mutate }
}
