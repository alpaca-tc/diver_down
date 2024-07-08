import { ascString } from '@/utils/sort'
import { MethodId } from './methodId'
import { Module } from './module'

export type Source = {
  sourceName: string
  resolvedAlias: string | null
  memo: string
  module: Module | null
}

type RelatedDefinition = {
  id: number
  title: string
}

type ReverseDependency = {
  sourceName: string
  module: Module | null
  methodIds: MethodId[]
}

export type SpecificSource = {
  sourceName: string
  resolvedAlias: string | null
  memo: string
  module: Module | null
  relatedDefinitions: RelatedDefinition[]
  reverseDependencies: ReverseDependency[]
}

export type Sources = {
  sources: Source[]
  classifiedSourcesCount: number
}

export const sortSources = <T extends Source>(sources: T[], key: 'sourceName' | 'module', sort: 'none' | 'asc' | 'desc'): T[] => {
  if (sort === 'none') {
    return sources
  }

  let sorted = [...sources]

  switch (key) {
    case 'sourceName': {
      sorted = sorted.toSorted((a, b) => ascString(a.sourceName, b.sourceName))
      break
    }
    case 'module': {
      sorted = sorted.toSorted((a, b) => ascString(a.module ?? '', b.module ?? ''))
    }
  }

  if (sort === 'desc') {
    sorted = sorted.reverse()
  }

  return sorted
}
