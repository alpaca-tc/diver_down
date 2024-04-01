import useSWR from 'swr'

import { path } from '@/constants/path'
import { CombinedDefinition } from '@/models/combinedDefinition'
import { bitIdToIds } from '@/utils/bitId'

import { get } from './httpRequest'

type CombinedDefinitionReponse = {
  bit_id: string
  titles: string[]
  dot: string
  sources: Array<{
    source_name: string
  }>
}

const fetchDefinitionShow = async (requestPath: string): Promise<CombinedDefinition> => {
  const response = await get<CombinedDefinitionReponse>(requestPath)

  return {
    ids: bitIdToIds(BigInt(response.bit_id)),
    titles: response.titles,
    dot: response.dot,
    sources: response.sources.map((source) => ({
      sourceName: source.source_name,
    })),
  }
}

export const useCombinedDefinition = (ids: number[]) => {
  const requestPath = path.api.definitions.show(ids)
  const shouldFetch = ids.length > 0
  const { data, isLoading } = useSWR(shouldFetch ? requestPath : null, fetchDefinitionShow)

  return { data, isLoading }
}
