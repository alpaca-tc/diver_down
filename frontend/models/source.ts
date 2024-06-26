import { MethodId } from './methodId'
import { Module } from './module'

export type Source = {
  sourceName: string
  resolvedAlias: string | null
  memo: string
  modules: Module[]
}

type RelatedDefinition = {
  id: number
  title: string
}

type ReverseDependency = {
  sourceName: string
  modules: Module[]
  methodIds: MethodId[]
}

export type SpecificSource = {
  sourceName: string
  resolvedAlias: string | null
  memo: string
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
      sorted = sorted.sort((a, b) => ascString(a.modules.join('---'), b.modules.join('---')))
    }
  }

  if (sort === 'desc') {
    sorted = sorted.reverse()
  }

  return sorted
}
