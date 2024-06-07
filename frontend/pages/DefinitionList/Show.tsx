import React, { useCallback, useState } from 'react'
import styled from 'styled-components'

import { Loading } from '@/components/Loading'
import { Aside, Section, Sidebar, Stack } from '@/components/ui'
import { color } from '@/constants/theme'
import { useBitIdHash } from '@/hooks/useBitIdHash'
import { useLocalStorage } from '@/hooks/useLocalStorage'
import { useCombinedDefinition } from '@/repositories/combinedDefinitionRepository'

import { GraphOptions } from './components/ConfigureGraphOptionsDialog'
import { DefinitionGraph } from './components/DefinitionGraph'
import { DefinitionList } from './components/DefinitionList'
import { DefinitionSources } from './components/DefinitionSources'

import { RecentModulesContext } from '@/context/RecentModulesContext'
import { Module } from '@/models/module'
import { HoverDotMetadataContext } from '@/context/HoverMetadataContext'
import { useGraphOptions } from '@/hooks/useGraphOptions'

export const Show: React.FC = () => {
  const [selectedDefinitionIds, setSelectedDefinitionIds] = useBitIdHash()
  const [graphOptions, setGraphOptions] = useGraphOptions()
  const {
    data: combinedDefinition,
    isLoading,
    mutate: mutateCombinedDefinition,
  } = useCombinedDefinition(selectedDefinitionIds, graphOptions.compound, graphOptions.concentrate, graphOptions.onlyModule)
  const [recentModules, setRecentModules] = useState<Module[]>([])

  return (
    <Wrapper>
      <RecentModulesContext.Provider value={{ recentModules, setRecentModules }}>
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
                  mutateCombinedDefinition={mutateCombinedDefinition}
                  graphOptions={graphOptions}
                  setGraphOptions={setGraphOptions}
                />
                <StyledDefinitionSources
                  combinedDefinition={combinedDefinition}
                  mutateCombinedDefinition={mutateCombinedDefinition}
                />
              </StyledStack>
            )}
          </StyledSection>
        </StyledSidebar>
      </RecentModulesContext.Provider>
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
