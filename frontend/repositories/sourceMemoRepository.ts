import useSWRMutation from 'swr/mutation'

import { path } from '@/constants/path'

import { post } from './httpRequest'

const updateMemo = async (url: string, { arg }: { arg: { memo: string } }) => {
  const { memo } = arg

  await post(url, {
    memo,
  })
}

export const useSourceMemo = (sourceName: string) => {
  const requestPath = path.api.sources.memo.update(sourceName)

  const { trigger, isMutating } = useSWRMutation(requestPath, updateMemo)

  return { trigger, isMutating }
}
