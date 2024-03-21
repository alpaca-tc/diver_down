type Definition = {
  bitId: bigint
  type: 'definition'
  definitionGroup: string
  label: string
}

type DefinitionGroup = {
  bitId: null
  type: 'definitionGroup'
  definitionGroup: string
  label: string
}

export type DefinitionList = Array<Definition | DefinitionGroup>
