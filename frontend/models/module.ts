export type Module = {
  moduleName: string
}

export type SpecificModule = {
  moduleName: string
  sources: Array<{
    sourceName: string
  }>
  relatedDefinitions: Array<{
    id: number
    title: string
  }>
}
