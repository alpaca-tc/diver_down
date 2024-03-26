import { FC } from "react"
import styled from "styled-components"

import { Loading } from "@/components/Loading"
import { Section } from "@/components/ui"
import { useCombinedDefinition } from "@/repositories/combinedDefinitionRepository"

import { Content } from "./Content"

type Props = {
  definitionIds: number[]
}

export const DefinitionView: FC<Props> = ({ definitionIds }) => {
  const { data, isLoading } = useCombinedDefinition(definitionIds)

  return (
    <StyledSection>
      {isLoading ? (
        <Loading text="Loading..." alt="Loading" />
      ) : !data ? (
        <p>No data</p>
      ) : (
        <Content combinedDefinition={data} />

      )}
    </StyledSection>
  )
}

const StyledSection = styled(Section)`
  overflow: scroll;
  height: inherit;
`
