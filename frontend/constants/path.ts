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
    configuration: () => `/api/configuration.json`,
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
      dependencyTypes: {
        update(sourceName: string, toSourceName: string) {
          return `/api/sources/${sourceName}/dependency_types/${toSourceName}.json`
        },
      },
    },
    sourceAliases: {
      index: () => '/api/source_aliases.json',
      update: () => `/api/source_aliases.json`,
    },
    modules: {
      index: () => '/api/modules.json',
      show: (module: string) => `/api/modules/${module}.json`,
      dependencyTypes: {
        update(fromModule: string, toModule: string) {
          return `/api/modules/${fromModule}/dependency_types/${toModule}.json`
        },
      },
    },
  },
}
