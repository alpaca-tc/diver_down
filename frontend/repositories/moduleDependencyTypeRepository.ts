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

export const useModuleDependencyType = (fromModule: string, toModule: string) => {
  const requestPath = path.api.modules.dependencyTypes.update(fromModule, toModule)

  const { trigger, isMutating } = useSWRMutation(requestPath, updateDependencyType)

  return { trigger, isMutating }
}
