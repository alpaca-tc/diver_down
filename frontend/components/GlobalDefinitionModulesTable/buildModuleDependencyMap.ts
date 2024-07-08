import { CombinedDefinition } from '@/models/combinedDefinition'
import { Module } from '@/models/module'

export type ModuleDependency = {
  sourcesCount: number
  dependencyModules: Set<Module>
  reverseDependencyModules: Set<Module>
}

const buildDefaultModuleDependency = (): ModuleDependency => ({
  sourcesCount: 0,
  dependencyModules: new Set<Module>(),
  reverseDependencyModules: new Set<Module>(),
})

export const buildModuleDependencyMap = (sources: CombinedDefinition['sources']): Map<Module, ModuleDependency> => {
  const sourceModuleMap = new Map<string, Module | null>()
  const moduleMap = new Map<Module, ModuleDependency>()

  sources.forEach((source) => {
    sourceModuleMap.set(source.sourceName, source.module)
  })

  sources.forEach((source) => {
    const sourceModule = sourceModuleMap.get(source.sourceName)
    if (!sourceModule) return

    if (!moduleMap.has(sourceModule)) {
      moduleMap.set(sourceModule, buildDefaultModuleDependency())
    }

    const sourceTopModule = moduleMap.get(sourceModule)!
    sourceTopModule.sourcesCount += 1

    source.dependencies.forEach((dependency) => {
      const dependencyModule = sourceModuleMap.get(dependency.sourceName)

      if (!dependencyModule) return

      if (!moduleMap.has(dependencyModule)) {
        moduleMap.set(dependencyModule, buildDefaultModuleDependency())
      }

      const dependencyTopModule = moduleMap.get(dependencyModule)!
      dependencyTopModule.dependencyModules.add(sourceModule)

      sourceTopModule.reverseDependencyModules.add(dependencyModule)
    })
  })

  return moduleMap
}
