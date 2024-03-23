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
}

type DefinitionsResponse = {
  definitions: DefinitionReponse[]
  pagination: PaginationResponse
}

const PER = 100

export const useDefinitionList = (
  keepPreviousData: boolean = false
) => {
  const getKey = (pageIndex: number, previousPageData: DefinitionsResponse | null) => {
    if (previousPageData && previousPageData.definitions.length === 0) {
      return null
    }
    const params = {
      per: PER,
      page: pageIndex + 1
    }

    return `${path.api.definitions.index()}?${stringify(params)}`
  }

  const fetcher = useCallback(async (url: string): Promise<Definition[]> => {
    const response = await get<DefinitionsResponse>(url)

    return response.definitions.map((definition) => ({
      id: definition.id,
      definitionGroup: definition.definition_group,
      title: definition.title,
    }))
  }, [])

  const { data, isLoading, size, setSize } = useSWRInfinite(getKey, fetcher, { keepPreviousData })

  return { data, isLoading, size, setSize }
}
