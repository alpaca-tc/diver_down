import { Module } from './module'

type BaseDotMetadata = {
  id: string
}

type DotSourceMetadata = {
  type: 'source'
  sourceName: string
  modules: Module[]
} & BaseDotMetadata

type DotDependencyMetadata = {
  type: 'dependency'
  sourceName: string
  methodIds: Array<{
    name: string
    context: 'class' | 'instance'
    human: string
  }>
} & BaseDotMetadata

type DotModuleMetadata = {
  type: 'module'
  modules: Module[]
} & BaseDotMetadata

export type DotMetadata = DotSourceMetadata | DotDependencyMetadata | DotModuleMetadata

export type CombinedDefinition = {
  ids: number[]
  titles: string[]
  dot: string
  dotMetadata: DotMetadata[]
  sources: Array<{ sourceName: string; modules: Module[] }>
}

export type DotSource = {
  type: 'source'
  sourceName: string
}
