import { DefinitionGraph } from '@/components/DefinitionGraph'
import { GlobalDefinitionModulesTable } from '@/components/GlobalDefinitionModulesTable'
import { Section, Sidebar, Stack } from '@/components/ui'
import { RecentModuleContext } from '@/context/RecentModuleContext'
import { useSearchParamsGraphOptions } from '@/hooks/useGraphOptions'
import { Module } from '@/models/module'
import { useGlobalDefinition } from '@/repositories/globalDefinitionRepository'
import { useState } from 'react'
import styled from 'styled-components'

export const Show: React.FC = () => {
  const [graphOptions, setGraphOptions] = useSearchParamsGraphOptions()

  const { data: combinedDefinition, mutate: mutateCombinedDefinition } = useGlobalDefinition(graphOptions)

  const [recentModule, setRecentModule] = useState<Module | null>(null)

  return (
    <Wrapper>
      <RecentModuleContext.Provider value={{ recentModule, setRecentModule }}>
        <StyledSidebar contentsMinWidth="0px" gap={0}>
          <StyledSection>
            <StyledStack>
              <DefinitionGraph
                combinedDefinition={combinedDefinition ?? null}
                mutateCombinedDefinition={mutateCombinedDefinition}
                graphOptions={graphOptions}
                setGraphOptions={setGraphOptions}
              />
              <StyledGlobalDefinitionModulesTable combinedDefinition={combinedDefinition ?? null} graphOptions={graphOptions} />
            </StyledStack>
          </StyledSection>
        </StyledSidebar>
      </RecentModuleContext.Provider>
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

const StyledSection = styled(Section)`
  box-sizing: border-box;
  height: inherit;
`

const StyledStack = styled(Stack)`
  display: flex;
  flex-direction: row;
  height: inherit;
`

const StyledGlobalDefinitionModulesTable = styled(GlobalDefinitionModulesTable)`
  flex: 1;
`
