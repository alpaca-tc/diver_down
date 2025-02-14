import useSWRMutation from 'swr/mutation'

import { path } from '@/constants/path'

import { post } from './httpRequest'
import { DependencyType } from '@/models/module'

const updateDependencyType = async (url: string, { arg }: { arg: { dependencyType: DependencyType } }) => {
  const { dependencyType } = arg

  await post(url, {
    dependency_type: dependencyType,
  })
}

export const useSourceDependencyType = (sourceName: string, toSourceName: string) => {
  const requestPath = path.api.sources.dependencyTypes.update(sourceName, toSourceName)

  const { trigger, isMutating } = useSWRMutation(requestPath, updateDependencyType)

  return { trigger, isMutating }
}
