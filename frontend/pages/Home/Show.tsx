import React from 'react'
import styled from 'styled-components'

import { Loading } from '@/components/Loading'
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
import { useDefinitionList } from '@/repositories/definitionRepository'
import { Definition } from '@/models/definition'

export default {
  title: 'Layouts（レイアウト）/Sidebar',
  component: Sidebar,
  parameters: {
    withTheming: true,
  },
}

export const Show: React.FC = () => {
  const {
    isLoading,
    data,
    // size,
    // setSize,
  } = useDefinitionList()

  const items = ((data ?? []).flat()).map((definition) => ({
    id: String(definition.id),
    title: definition.title,
    isSelected: false
  }))

  return (
    <Wrapper>
      <StyledPageHeading>Definition List</StyledPageHeading>
      <StyledSidebar contentsMinWidth="0px" gap={0}>
        <StyledAside>
          {isLoading ? (<Loading text="Loading..." alt="Loading" />) : (
            <SideNav className="definition-list" size="s" items={items} onClick={() => { }} />
          )}
        </StyledAside>
        <StyledSection>
          <Heading>メインコンテンツ</Heading>
        </StyledSection>
      </StyledSidebar>
    </Wrapper>
  )
}

const Wrapper = styled.div`
  display: flex;
  flex-direction: column;
  height: 100%;
`

const StyledSidebar = styled(Sidebar)`
  flex-grow: 1;
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

  // TODO: どうやってスクロールさせられるかわからない
  & .definition-list {
    max-height: 100%;
    overflow: scroll;
    background-color: ${color.WHITE};

    button {
      display: flex;
      align-items: center;
    }
  }
`
