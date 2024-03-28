import { idsToBitId } from "@/utils/bitId";

export const path = {
  home: () => '/',
  definitions: {
    show: (bitId: string) => `/definitions/${bitId}`
  },
  sources: {
    index: () => '/sources',
    show: (sourceName: string) => `/sources/${sourceName}`
  },
  api: {
    definitions: {
      index: () => '/api/definitions.json',
      show: (ids: number[]) => `/api/definitions/${idsToBitId(ids)}.json`
    },
    sources: {
      index: () => '/api/sources.json',
      show: (sourceName: string) => `/api/sources/${sourceName}.json`
    }
  },
}
