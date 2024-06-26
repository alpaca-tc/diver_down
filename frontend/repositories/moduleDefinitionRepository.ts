import { path } from '@/constants/path'
import { CombinedDefinitionOptions } from '@/models/combinedDefinition'
import { fetchCombinedDefinition, stringifyCombinedDefinitionOptions } from './combinedDefinitionRepository'
import useSWR from 'swr'

export const useModuleDefinition = (moduleNames: string[], graphOptions: CombinedDefinitionOptions) => {
  const requestPath = `${path.api.moduleDefinitions.show(moduleNames)}?${stringifyCombinedDefinitionOptions(graphOptions)}`
  const shouldFetch = moduleNames.length > 0
  const { data, isLoading, mutate } = useSWR(shouldFetch ? requestPath : null, fetchCombinedDefinition)

  return { data, isLoading, mutate }
}
