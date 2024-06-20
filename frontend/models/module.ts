export type Module = string

export type SpecificModule = {
  modules: Module[]
  sources: Array<{
    sourceName: string
    memo: string
  }>
  relatedDefinitions: Array<{
    id: number
    title: string
  }>
}
