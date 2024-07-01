import { MethodId } from './methodId'

export type Module = string

export type SpecificModuleDependency = {
  sourceName: string
  module: Module | null
  methodIds: MethodId[]
}

export type SpecificModuleSource = {
  sourceName: string
  module: Module | null
  memo: string
  dependencies: SpecificModuleDependency[]
}

export type SpecificModule = {
  module: Module
  moduleDependencies: Module[]
  moduleReverseDependencies: Module[]
  sources: SpecificModuleSource[]
  sourceReverseDependencies: SpecificModuleSource[]
}
