import useSWRMutation from 'swr/mutation'

import { path } from '@/constants/path'
import { Module } from '@/models/module'

import { post } from './httpRequest'

const updateModules = async (url: string, { arg }: { arg: { modules: Module[] } }) => {
  const { modules } = arg
  const moduleNames = modules.map((mod) => mod.moduleName)

  await post(url, {
    modules: moduleNames,
  })
}

export const useSourceModules = (sourceName: string) => {
  const requestPath = path.api.sources.modules.update(sourceName)

  const { trigger, isMutating } = useSWRMutation(requestPath, updateModules)

  return { trigger, isMutating }
}
