import { MethodId } from './methodId'

export type Module = string

export type DependencyType = 'valid' | 'invalid' | 'todo' | null

export type SpecificModuleDependency = {
  sourceName: string
  module: Module | null
  dependencyType: DependencyType
  methodIds: MethodId[]
}

export type SpecificModuleReverseDependency = {
  sourceName: string
  module: Module | null
  dependencyType: DependencyType
}

export type SpecificModuleSource = {
  sourceName: string
  module: Module | null
  memo: string
  dependencies: SpecificModuleDependency[]
}

export type SpecificModuleReverseSource = {
  sourceName: string
  module: Module | null
  memo: string
  dependencies: SpecificModuleReverseDependency[]
}

export type SpecificModule = {
  module: Module
  moduleDependencies: Module[]
  moduleReverseDependencies: Module[]
  sources: SpecificModuleSource[]
  sourceReverseDependencies: SpecificModuleReverseSource[]
}
