import useSWR from 'swr'

import { path } from '@/constants/path'
import { SourceAlias } from '@/models/sourceAlias'

import { get, post } from './httpRequest'
import useSWRMutation from 'swr/mutation'

type SourceAliasesReponse = {
  source_aliases: Array<{ alias_name: string; source_names: string[] }>
}

export const useSourceAliases = () => {
  const { data, isLoading, mutate } = useSWR<SourceAlias[]>(path.api.sourceAliases.index(), async () => {
    const response = await get<SourceAliasesReponse>(path.api.sourceAliases.index())
    return response.source_aliases.map((sourceAlias) => ({
      aliasName: sourceAlias.alias_name,
      sourceNames: sourceAlias.source_names,
    }))
  })

  return { data, isLoading, mutate }
}

const updateSourceAlias = async (
  url: string,
  { arg }: { arg: { aliasName: string; oldAliasName: string; sourceNames: string[] } },
) => {
  const { aliasName, oldAliasName, sourceNames } = arg

  await post(url, {
    alias_name: aliasName,
    old_alias_name: oldAliasName,
    source_names: sourceNames,
  })
}

export const useUpdateSourceAlias = () => {
  const requestPath = path.api.sourceAliases.update()

  const { trigger, isMutating } = useSWRMutation(requestPath, updateSourceAlias)

  return { trigger, isMutating }
}
