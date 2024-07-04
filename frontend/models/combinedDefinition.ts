import { Module } from './module'
import { Source } from './source'

type BaseDotMetadata = {
  id: string
}

export const defaultGraphOptions: GraphOptions = {
  compound: false,
  concentrate: false,
  onlyModule: false,
  focusModules: [],
  modules: [],
  removeInternalSources: false,
}

export type GraphOptions = {
  compound: boolean
  concentrate: boolean
  onlyModule: boolean
  focusModules: Module[]
  modules: Module[]
  removeInternalSources: boolean
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

export type Dependency = {
  sourceName: string
}

export type CombinedDefinitionSource = {
  dependencies: Dependency[]
} & Source

export type CombinedDefinition = {
  ids: number[]
  titles: string[]
  dot: string
  dotMetadata: DotMetadata[]
  sources: CombinedDefinitionSource[]
}
