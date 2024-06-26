import { Module } from './module'
import { Source } from './source'

export type CombinedDefinitionOptions = {
  compound: boolean
  concentrate: boolean
  onlyModule: boolean
}

type BaseDotMetadata = {
  id: string
}

export type DotSourceMetadata = {
  type: 'source'
  sourceName: string
  memo: string
  module: Module | null
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
  module: Module
} & BaseDotMetadata

export type DotMetadata = DotSourceMetadata | DotDependencyMetadata | DotModuleMetadata

export type CombinedDefinition = {
  ids: number[]
  titles: string[]
  dot: string
  dotMetadata: DotMetadata[]
  sources: Source[]
}
