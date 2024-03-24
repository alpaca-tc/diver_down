import React, { useState } from 'react'
import styled from 'styled-components'

import {
  Aside,
  Heading,
  PageHeading,
  Section,
  Sidebar,
} from '@/components/ui'
import { color, spacing } from '@/constants/theme'

import { DefinitionList } from './parts/DefinitionList'

export const Show: React.FC = () => {
  const [selectedDefinitionIds, setSelectedDefinitionIds] = useState<number[]>([])

  return (
    <>
      <StyledPageHeading>Definition List</StyledPageHeading>
      <Wrapper>
        <StyledSidebar contentsMinWidth="0px" gap={0}>
          <StyledAside>
            <DefinitionList selectedDefinitionIds={selectedDefinitionIds} setSelectedDefinitionIds={setSelectedDefinitionIds} />
          </StyledAside>
          <StyledSection>
            <Heading>メインコンテンツ</Heading>
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
  padding: ${spacing.XXS} ${spacing.S};
`

const StyledAside = styled(Aside)`
  width: 300px;
  box-sizing: border-box;
  border-top: 1px solid ${color.BORDER};
  border-right: 1px solid ${color.BORDER};
  background-color: ${color.WHITE};
  height: inherit;

  &:hover {
    width: 100%;

    & + * {
      // Hide main content
      display: none;
    }
  }
`
