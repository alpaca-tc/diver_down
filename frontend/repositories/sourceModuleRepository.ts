import useSWRMutation from 'swr/mutation'

import { path } from '@/constants/path'
import { Module } from '@/models/module'

import { post } from './httpRequest'

const updateModule = async (url: string, { arg }: { arg: { module: Module | null } }) => {
  const { module } = arg

  await post(url, { module })
}

export const useSourceModule = (sourceName: string) => {
  const requestPath = path.api.sources.module.update(sourceName)

  const { trigger, isMutating } = useSWRMutation(requestPath, updateModule)

  return { trigger, isMutating }
}
