import { idsToBitId } from '@/utils/bitId'

export const path = {
  home: () => '/',
  definitions: {
    show: (bitId: string) => `/definitions/${bitId}`,
  },
  sources: {
    index: () => '/sources',
    show: (sourceName: string) => `/sources/${sourceName}`,
  },
  sourceAliases: {
    index: () => '/source_aliases',
  },
  modules: {
    index: () => '/modules',
    show: (module: string) => `/modules/${module}`,
  },
  licenses: {
    index: () => '/licenses',
  },
  api: {
    pid: () => `/api/pid.json`,
    initializationStatus: () => `/api/initialization_status.json`,
    definitions: {
      index: () => '/api/definitions.json',
      show: (ids: number[]) => `/api/definitions/${idsToBitId(ids)}.json`,
    },
    sources: {
      index: () => '/api/sources.json',
      show: (sourceName: string) => `/api/sources/${sourceName}.json`,
      memo: {
        update: (sourceName: string) => `/api/sources/${sourceName}/memo.json`,
      },
      module: {
        update: (sourceName: string) => `/api/sources/${sourceName}/module.json`,
      },
    },
    sourceAliases: {
      index: () => '/api/source_aliases.json',
      update: () => `/api/source_aliases.json`,
    },
    modules: {
      index: () => '/api/modules.json',
      show: (module: string) => `/api/modules/${module}.json`,
    },
  },
}
