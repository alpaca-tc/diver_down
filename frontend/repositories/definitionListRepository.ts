import { useCallback } from 'react'
import useSWRInfinite from 'swr/infinite'

import { path } from '@/constants/path'
import { Definition } from '@/models/definition'
import { stringify } from '@/utils/queryString'

import { get } from './httpRequest'
import { PaginationResponse } from './pagination'

type DefinitionReponse = {
  id: number
  definition_group: string | null
  title: string
  sources_count: number
  unclassified_sources_count: number
}

type DefinitionsResponse = {
  definitions: DefinitionReponse[]
  pagination: PaginationResponse
}

export const PER = 100

export const useDefinitionList = (
  query: { definitionGroup: string; title: string; source: string },
  keepPreviousData: boolean = false,
) => {
  const getKey = (pageIndex: number, previousPageData: DefinitionReponse[] | null) => {
    if (previousPageData && previousPageData.length === 0) {
      return null
    }
    const params = {
      per: PER,
      page: pageIndex + 1,
      definition_group: query.definitionGroup,
      title: query.title,
      source: query.source,
    }

    return `${path.api.definitions.index()}?${stringify(params)}`
  }

  const fetcher = useCallback(async (url: string): Promise<Definition[]> => {
    const response = await get<DefinitionsResponse>(url)

    return response.definitions.map((definition) => ({
      id: definition.id,
      definitionGroup: definition.definition_group,
      title: definition.title,
      sourcesCount: definition.sources_count,
      unclassifiedSourcesCount: definition.unclassified_sources_count,
    }))
  }, [])

  const { data, isLoading, size, setSize, isValidating } = useSWRInfinite(getKey, fetcher, { keepPreviousData })
  const isReachingEnd = !!(data?.[0]?.length === 0 || (data && data?.[data?.length - 1]?.length < PER))

  const definitions = (data ?? []).flat()

  return { definitions, isLoading, size, setSize, isValidating, isReachingEnd }
}
