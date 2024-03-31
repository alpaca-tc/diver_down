import useSWR from 'swr'

import { path } from '@/constants/path'
import { InitializationStatus } from '@/models/initializationStatus'

import { get } from './httpRequest'

type InitializationStatusReponse = {
  total: number
  loaded: number
}

export const useInitializationStatus = (refreshInterval: number) => {
  const { data, isLoading } = useSWR(path.api.initializationStatus(), async (): Promise<InitializationStatus> => {
    const response = await get<InitializationStatusReponse>(path.api.initializationStatus())
    return response
  }, { refreshInterval })

  return { initializationStatus: data, isLoading }
}
