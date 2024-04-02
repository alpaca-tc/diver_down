import { Module } from "./module"

export type CombinedDefinition = {
  ids: number[]
  titles: string[]
  dot: string
  sources: Array<{ sourceName: string, modules: Module[] }>
}
