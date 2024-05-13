import { MethodId } from './methodId'
import { Module } from './module'

export type Source = {
  sourceName: string
  modules: Module[]
}

type RelatedDefinition = {
  id: number
  title: string
}

type ReverseDependency = {
  sourceName: string
  methodIds: MethodId[]
}

export type SpecificSource = {
  sourceName: string
  modules: Module[]
  relatedDefinitions: RelatedDefinition[]
  reverseDependencies: ReverseDependency[]
}

export type Sources = {
  sources: Source[]
  classifiedSourcesCount: number
}

export const sortSources = (sources: Source[], key: 'sourceName' | 'modules', sort: 'none' | 'asc' | 'desc'): Source[] => {
  if (sort === 'none') {
    return sources
  }

  let sorted = [...sources]

  const ascString = (a: string, b: string) => {
    if (a > b) return 1
    if (a < b) return -1
    return 0
  }

  switch (key) {
    case 'sourceName': {
      sorted = sorted.sort((a, b) => ascString(a.sourceName, b.sourceName))
      break
    }
    case 'modules': {
      sorted = sorted.sort((a, b) =>
        ascString(
          a.modules.map((module) => module.moduleName).join('-'),
          b.modules.map((module) => module.moduleName).join('-'),
        ),
      )
    }
  }

  if (sort === 'desc') {
    sorted = sorted.reverse()
  }

  return sorted
}
