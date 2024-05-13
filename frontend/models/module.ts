export type Module = {
  moduleName: string
}

export type SpecificModule = {
  modules: Array<{
    moduleName: string
  }>
  sources: Array<{
    sourceName: string
    memo: string
  }>
  relatedDefinitions: Array<{
    id: number
    title: string
  }>
}
