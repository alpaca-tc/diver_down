import { FC } from "react"
import styled from "styled-components"

import { Loading } from "@/components/Loading"
import { Section } from "@/components/ui"
import { spacing } from "@/constants/theme"
import { useCombinedDefinition } from "@/repositories/combinedDefinitionRepository"

import { Content } from "./Content"

type Props = {
  definitionIds: number[]
}

export const DefinitionView: FC<Props> = ({ definitionIds }) => {
  const { data: combinedDefinition, isLoading } = useCombinedDefinition(definitionIds)

  return (
    <StyledSection>
      <Padding>
        {isLoading ? (
          <Loading text="Loading..." alt="Loading" />
        ) : !combinedDefinition ? (
          <p>No data</p>
        ) : (
          <Content combinedDefinition={combinedDefinition} />
        )}
      </Padding>
    </StyledSection>
  )
}

const StyledSection = styled(Section)`
  height: inherit;
`

const Padding = styled.div`
  padding: 0 ${spacing.S};
  height: inherit;
`
