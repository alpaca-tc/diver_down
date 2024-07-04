import { path } from '@/constants/path'
import { fetchCombinedDefinition, stringifyCombinedDefinitionOptions } from './combinedDefinitionRepository'
import useSWR from 'swr'
import { GraphOptions } from '@/models/combinedDefinition'

export const useGlobalDefinition = (graphOptions: GraphOptions) => {
  const requestPath = `${path.api.globalDefinition.show()}?${stringifyCombinedDefinitionOptions(graphOptions)}`
  const { data, isLoading, mutate } = useSWR(requestPath, fetchCombinedDefinition)

  return { data, isLoading, mutate }
}
