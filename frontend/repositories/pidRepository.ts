import useSWR from 'swr'

import { path } from '@/constants/path'

import { get } from './httpRequest'

type PidReponse = {
  pid: number
}

export const usePid = () => {
  const { data } = useSWR(path.api.pid(), async (): Promise<number> => {
    const response = await get<PidReponse>(path.api.pid())
    return response.pid
  })

  return { pid: data }
}
