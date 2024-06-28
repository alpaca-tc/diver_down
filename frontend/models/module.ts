import { MethodId } from './methodId'

export type Module = string

export type SpecificModule = {
  module: Module
  moduleDependencies: Module[]
  moduleReverseDependencies: Module[]
  sources: Array<{
    sourceName: string
    module: Module
    memo: string
    dependencies: Array<{
      sourceName: string
      module: Module | null
      methodIds: MethodId[]
    }>
  }>
  sourceReverseDependencies: Array<{
    sourceName: string
    module: Module | null
    memo: string
    dependencies: Array<{
      sourceName: string
      module: Module
      methodIds: MethodId[]
    }>
  }>
}
