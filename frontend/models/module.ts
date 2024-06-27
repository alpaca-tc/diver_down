export type Module = string

export type SpecificModule = {
  module: Module
  sources: Array<{
    sourceName: string
    memo: string
  }>
  relatedDefinitions: Array<{
    id: number
    title: string
  }>
}
