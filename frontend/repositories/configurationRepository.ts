import useSWR from 'swr'

import { path } from '@/constants/path'
import { get } from './httpRequest'
import { Configuration } from '@/models/configuration'

type ConfigurationReponse = {
  blob_prefix: string | null
}

export const useConfiguration = () => {
  const { data, isLoading } = useSWR<Configuration>(path.api.configuration(), async () => {
    const response = await get<ConfigurationReponse>(path.api.configuration())
    return {
      blobPrefix: response.blob_prefix,
    }
  })

  return { data, isLoading }
}
