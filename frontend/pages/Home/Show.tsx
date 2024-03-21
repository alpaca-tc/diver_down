import React from 'react'
import styled from 'styled-components'

import {
  Aside,
  CheckBox,
  Heading,
  PageHeading,
  Section,
  SideNav,
  Sidebar,
} from '@/components/ui'
import { color, spacing } from '@/constants/theme'

export default {
  title: 'Layouts（レイアウト）/Sidebar',
  component: Sidebar,
  parameters: {
    withTheming: true,
  },
}

export const Show: React.FC = () => {
  const sideNavItems = [
    {
      id: 'id-1',
      title: ' one!',
      isSelected: false,
    },
    {
      id: 'id-2',
      title: 'two!',
      isSelected: false,
    },
    {
      id: 'id-3',
      title: 'three!',
      isSelected: false,
    },
    {
      id: 'id-4',
      title: 'four!',
      isSelected: false,
    },
    {
      id: 'id-5',
      title: 'five!',
      isSelected: false,
      prefix: (
        <CheckBox name="definition" />
      ),
    },
  ]

  return (
    <>
      <StyledPageHeading>Definition List</StyledPageHeading>
      <StyledSidebar contentsMinWidth="0px" gap={0}>
        <StyledAside>
          <SideNav className="definition-list" size="s" items={sideNavItems} onClick={() => { }} />
        </StyledAside>
        <StyledSection>
          <Heading>メインコンテンツ</Heading>
        </StyledSection>
      </StyledSidebar>
    </>
  )
}

const StyledSidebar = styled(Sidebar)`
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

  & .definition-list {
    background-color: ${color.WHITE};

    button {
      display: flex;
      align-items: center;
    }
  }
`
