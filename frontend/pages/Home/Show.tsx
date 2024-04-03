import React from 'react'
import styled from 'styled-components'

import { Loading } from '@/components/Loading'
import { Aside, Section, Sidebar, Stack } from '@/components/ui'
import { color } from '@/constants/theme'
import { useBitIdHash } from '@/hooks/useBitIdHash'
import { useLocalStorage } from '@/hooks/useLocalStorage'
import { useCombinedDefinition } from '@/repositories/combinedDefinitionRepository'

import { DefinitionGraph, GraphOptions } from './components/DefinitionGraph'
import { DefinitionList } from './components/DefinitionList'
import { DefinitionSources } from './components/DefinitionSources'

export const Show: React.FC = () => {
  const [selectedDefinitionIds, setSelectedDefinitionIds] = useBitIdHash()
  const [graphOptions, setGraphOptions] = useLocalStorage<GraphOptions>('HomeShow-GraphOptions', {
    compound: false,
    concentrate: false,
  })
  const { data: combinedDefinition, isLoading } = useCombinedDefinition(
    selectedDefinitionIds,
    graphOptions.compound,
    graphOptions.concentrate,
  )

  return (
    <Wrapper>
      <StyledSidebar contentsMinWidth="0px" gap={0}>
        <StyledAside>
          <DefinitionList selectedDefinitionIds={selectedDefinitionIds} setSelectedDefinitionIds={setSelectedDefinitionIds} />
        </StyledAside>
        <StyledSection>
          {isLoading ? (
            <CenterStack>
              <Loading text="Loading..." alt="Loading" />
            </CenterStack>
          ) : !combinedDefinition ? (
            <CenterStack>
              <p>No data</p>
            </CenterStack>
          ) : (
            <StyledStack>
              <DefinitionGraph
                combinedDefinition={combinedDefinition}
                graphOptions={graphOptions}
                setGraphOptions={setGraphOptions}
              />
              <StyledDefinitionSources combinedDefinition={combinedDefinition} />
            </StyledStack>
          )}
        </StyledSection>
      </StyledSidebar>
    </Wrapper>
  )
}

const Wrapper = styled.div`
  display: flex;
  flex-direction: column;
  height: calc(100% - 1px); /* 100% - padding-top of layout */
  width: 100vw;
`

const StyledSidebar = styled(Sidebar)`
  display: flex;
  height: 100%;
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

const CenterStack = styled(Stack)`
  display: flex;
  flex-direction: row;
  height: inherit;
  justify-content: center;
`

const StyledStack = styled(Stack)`
  display: flex;
  flex-direction: row;
  height: inherit;
`

const StyledDefinitionSources = styled(DefinitionSources)`
  flex: 1;
`
