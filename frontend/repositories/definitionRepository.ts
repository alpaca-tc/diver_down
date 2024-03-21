import useSWR from 'swr'

import { path } from '@/constants/path'
import { DefinitionList } from '@/models/definitionList'
import { stringify } from '@/utils/queryString'

import { get } from './httpRequest'
import { PaginationResponse } from './pagination'

type DefinitionsResponse = {
  definitions: Array<{
    bit_id: bigint
    type: 'definition' | 'definition_group'
    definition_group: string
    label: string
  }>
  pagination: PaginationResponse
}

const fetchDefinitions = async (requestPath: string): Promise<DefinitionList> => {
  const response = await get<DefinitionsResponse>(requestPath)

  return res.definitions.map(())
  .then((res) => res.definitions)
}

export const useDefinitionList = (
  per: number,
  page: number,
  keepPreviousData: boolean = false
) => {
  const params = { per, page }
  const requestPath = `${path.api.definitions.index()}?${stringify(params)}`

  const { data, isLoading } = useSWR(requestPath, fetchDefinitions, { keepPreviousData })

  return { data, isLoading }
}
