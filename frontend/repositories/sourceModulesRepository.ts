import useSWRMutation from 'swr/mutation'

import { path } from '@/constants/path'
import { Module } from '@/models/module'

import { post } from './httpRequest'

const updateModules = async (url: string, { arg }: { arg: { modules: Module[] } }) => {
  const { modules } = arg

  await post(url, {
    modules,
  })
}

export const useSourceModules = (sourceName: string) => {
  const requestPath = path.api.sources.modules.update(sourceName)

  const { trigger, isMutating } = useSWRMutation(requestPath, updateModules)

  return { trigger, isMutating }
}
