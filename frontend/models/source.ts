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
