export const path = {
  home: () => '/',
  definitions: {
    show: (bitId: string) => `/definitions/${bitId}`
  },
  sources: {
    show: (sourceName: string) => `/sources/${sourceName}`
  },
  api: {},
}
