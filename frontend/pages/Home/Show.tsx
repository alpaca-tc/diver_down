import React from 'react'
import styled from 'styled-components'

import {
  Aside,
  PageHeading,
  Section,
  Sidebar,
} from '@/components/ui'
import { color, spacing } from '@/constants/theme'
import { useBitIdHash } from '@/hooks/useBitIdHash'

import { DefinitionList } from './components/DefinitionList'
import { DefinitionView } from './components/DefinitionView'

export const Show: React.FC = () => {
  const [selectedDefinitionIds, setSelectedDefinitionIds] = useBitIdHash()

  return (
    <>
      <StyledPageHeading>Definition List</StyledPageHeading>
      <Wrapper>
        <StyledSidebar contentsMinWidth="0px" gap={0}>
          <StyledAside>
            <DefinitionList selectedDefinitionIds={selectedDefinitionIds} setSelectedDefinitionIds={setSelectedDefinitionIds} />
          </StyledAside>
          <StyledSection>
            <DefinitionView definitionIds={selectedDefinitionIds} />
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

const StyledSection = styled(Section)`
  box-sizing: border-box;
  height: inherit;
`

const StyledAside = styled(Aside)`
  box-sizing: border-box;
  border-top: 1px solid ${color.BORDER};
  border-right: 1px solid ${color.BORDER};
  background-color: ${color.WHITE};
  height: inherit;
`
