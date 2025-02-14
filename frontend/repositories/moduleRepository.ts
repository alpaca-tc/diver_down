import useSWR from 'swr'

import { path } from '@/constants/path'
import { Module, SpecificModule } from '@/models/module'

import { get } from './httpRequest'

type ModulesReponse = {
  modules: string[]
}

export const useModules = () => {
  const { data, isLoading, mutate } = useSWR<Module[]>(path.api.modules.index(), async () => {
    const response = await get<ModulesReponse>(path.api.modules.index())
    return response.modules
  })

  return { data, isLoading, mutate }
}

type DependencyTypeResponse = 'valid' | 'invalid' | 'todo' | null

type SpecificModuleResponse = {
  module: string
  module_dependencies: string[]
  module_reverse_dependencies: string[]
  sources: Array<{
    source_name: string
    module: string
    memo: string
    dependencies: Array<{
      source_name: string
      module: string | null
      dependency_type: DependencyTypeResponse
      method_ids: Array<{
        context: 'instance' | 'class'
        name: string
        paths: string[]
      }>
    }>
  }>
  source_reverse_dependencies: Array<{
    source_name: string
    module: string | null
    memo: string
    dependencies: Array<{
      source_name: string
      module: string
      dependency_type: DependencyTypeResponse
    }>
  }>
}

export const useModule = (module: string) => {
  const { data, isLoading, mutate } = useSWR<SpecificModule>(path.api.modules.show(module), async (): Promise<SpecificModule> => {
    const response = await get<SpecificModuleResponse>(path.api.modules.show(module))

    return {
      module: response.module,
      moduleDependencies: response.module_dependencies,
      moduleReverseDependencies: response.module_reverse_dependencies,
      sources: response.sources.map((source) => ({
        sourceName: source.source_name,
        module: source.module,
        memo: source.memo,
        dependencies: source.dependencies.map((dependency) => ({
          sourceName: dependency.source_name,
          module: dependency.module,
          dependencyType: dependency.dependency_type,
          methodIds: dependency.method_ids.map((methodId) => ({
            context: methodId.context,
            name: methodId.name,
            paths: methodId.paths,
          })),
        })),
      })),
      sourceReverseDependencies: response.source_reverse_dependencies.map((source) => ({
        sourceName: source.source_name,
        module: source.module,
        memo: source.memo,
        dependencies: source.dependencies.map((dependency) => ({
          sourceName: dependency.source_name,
          module: dependency.module,
          dependencyType: dependency.dependency_type,
        })),
      })),
    }
  })

  return { data, isLoading, mutate }
}
