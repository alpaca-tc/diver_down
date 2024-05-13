import { Module } from './module'
import { Source } from './source'

type BaseDotMetadata = {
  id: string
}

export type DotSourceMetadata = {
  type: 'source'
  sourceName: string
  memo: string
  modules: Module[]
} & BaseDotMetadata

export type DotDependencyMetadata = {
  type: 'dependency'
  dependencies: Array<{
    sourceName: string
    methodIds: Array<{
      name: string
      context: 'class' | 'instance'
      human: string
    }>
  }>
} & BaseDotMetadata

export type DotModuleMetadata = {
  type: 'module'
  modules: Module[]
} & BaseDotMetadata

export type DotMetadata = DotSourceMetadata | DotDependencyMetadata | DotModuleMetadata

export type CombinedDefinition = {
  ids: number[]
  titles: string[]
  dot: string
  dotMetadata: DotMetadata[]
  sources: Source[]
}
