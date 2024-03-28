import React from 'react'
import styled from 'styled-components'

import { Loading } from '@/components/Loading'
import {
  Aside,
  PageHeading,
  Section,
  Sidebar,
  Stack,
} from '@/components/ui'
import { color, spacing } from '@/constants/theme'
import { useBitIdHash } from '@/hooks/useBitIdHash'
import { useCombinedDefinition } from "@/repositories/combinedDefinitionRepository"

import { DefinitionGraph } from './components/DefinitionGraph'
import { DefinitionList } from './components/DefinitionList'
import { DefinitionSources } from './components/DefinitionSources'

export const Show: React.FC = () => {
  const [selectedDefinitionIds, setSelectedDefinitionIds] = useBitIdHash()
  const { data: combinedDefinition, isLoading } = useCombinedDefinition(selectedDefinitionIds)

  return (
    <>
      <StyledPageHeading>Definition List</StyledPageHeading>
      <Wrapper>
        <StyledSidebar contentsMinWidth="0px" gap={0}>
          <StyledAside>
            <DefinitionList selectedDefinitionIds={selectedDefinitionIds} setSelectedDefinitionIds={setSelectedDefinitionIds} />
          </StyledAside>
          <StyledSection>
            <StyledStack>
              {isLoading ? (
                <Loading text="Loading..." alt="Loading" />
              ) : !combinedDefinition ? (
                <p>No data</p>
              ) : (
                <>
                  <StyledDefinitionGraph combinedDefinition={combinedDefinition} />
                  <StyledDefinitionSources combinedDefinition={combinedDefinition} />
                </>
              )}
            </StyledStack>
          </StyledSection>
        </StyledSidebar>
      </Wrapper>
    </>
  )
}

const Wrapper = styled.div`
  display: flex;
  flex-direction: column;
  height: calc(100% - ${spacing.XS} - ${spacing.XS} - ${spacing.XS}); // 100% - padding-top of layout - height of StyledPageHeading
  width: 100vw;
`

const StyledSidebar = styled(Sidebar)`
  display: flex;
  height: 100%;
`

const StyledPageHeading = styled(PageHeading)`
  padding-left: ${spacing.XS};
  margin-bottom: ${spacing.XS};
`

const StyledAside = styled(Aside)`
  box-sizing: border-box;
  border-top: 1px solid ${color.BORDER};
  border-right: 1px solid ${color.BORDER};
  background-color: ${color.WHITE};
  height: inherit;
`

const StyledSection = styled(Section)`
  box-sizing: border-box;
  height: inherit;
`

const StyledStack = styled(Stack)`
  display: flex;
  flex-direction: row;
  height: inherit;
`

const StyledDefinitionGraph = styled(DefinitionGraph)`
  height: inherit;
`

const StyledDefinitionSources = styled(DefinitionSources)`
  flex: 1;
`
