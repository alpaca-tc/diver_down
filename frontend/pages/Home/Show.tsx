import React, { ComponentProps, useCallback, useMemo, useState } from 'react'
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
import { groupBy } from '@/utils/groupBy'

export default {
  title: 'Layouts（レイアウト）/Sidebar',
  component: Sidebar,
  parameters: {
    withTheming: true,
  },
}

const DEFINITION_GROUP_PREFIX = 'definition-group-'
const NULL_DEFINITION_GROUP = '_____null_____'

export const Show: React.FC = () => {
  const {
    isLoading,
    data,
    // size,
    // setSize,
  } = useDefinitionList()

  const allDefinitions: Definition[] = (data ?? []).flat()
  const [selectedDefinitionIds, setSelectedDefinitionIds] = useState<number[]>([])

  const toggleDefinitionId = useCallback((id: number) => {
    setSelectedDefinitionIds((prev) => {
      if (prev.includes(id)) {
        return prev.filter((prevId) => prevId !== id)
      } else {
        return [...prev, id]
      }
    })
  }, [setSelectedDefinitionIds])

  const toggleDefinitionGroup = useCallback((definitionGroup: string) => {
    const definitionIds = allDefinitions.filter((definition) => definition.definitionGroup === definitionGroup).map(({ id }) => id)
    const allSelected = definitionIds.every((id) => selectedDefinitionIds.includes(id))

    if (allSelected) {
      // disable all definitions in definition_group
      setSelectedDefinitionIds((prev) => (
        prev.filter((prevId) => !definitionIds.includes(prevId))
      ))
    } else {
      // enable all definitions in definition_group
      setSelectedDefinitionIds((prev) => (
        [...(new Set<number>([...prev, ...definitionIds]))]
      ))
    }
  }, [allDefinitions, selectedDefinitionIds])

  const onClickItem = useCallback((event: React.MouseEvent<HTMLButtonElement, MouseEvent>, id: string): void => {
    event.stopPropagation()

    if (id.startsWith(DEFINITION_GROUP_PREFIX)) {
      // item is definition group
      toggleDefinitionGroup(id.slice(DEFINITION_GROUP_PREFIX.length))
    } else {
      // item is definition
      toggleDefinitionId(Number(id))
    }
  }, [toggleDefinitionId, toggleDefinitionGroup])

  const sideNavItems: ComponentProps<typeof SideNav>['items'] = useMemo(() => {
    const groupedDefinitions = groupBy<Definition>(allDefinitions, (definition) => definition.definitionGroup ?? NULL_DEFINITION_GROUP)
    const items: ComponentProps<typeof SideNav>['items'] = []

    Object.keys(groupedDefinitions).forEach((definitionGroup) => {
      const definitions = groupedDefinitions[definitionGroup]

      if (definitionGroup !== NULL_DEFINITION_GROUP) {
        const allSelected = definitions.every(({ id }) => selectedDefinitionIds.includes(id))

        items.push({
          id: `${DEFINITION_GROUP_PREFIX}${definitionGroup}`,
          title: definitionGroup,
          isSelected: allSelected,
          prefix: <CheckBox checked={allSelected} onClick={() => toggleDefinitionGroup(definitionGroup)} />
        })
      }

      definitions.forEach((definition) => {
        const onClickCheckbox = (event: React.MouseEvent<HTMLInputElement>) => {
          event.stopPropagation()
          toggleDefinitionId(definition.id)
        }

        const isSelected = selectedDefinitionIds.includes(definition.id)

        items.push({
          id: String(definition.id),
          title: definition.title,
          isSelected,
          prefix: (
            <>
              {definitionGroup === NULL_DEFINITION_GROUP ? null : <SideNavIndent className="side-nav-indent" />}
              <CheckBox checked={isSelected} onClick={onClickCheckbox} />
            </>
          )
        })
      })
    })

    return items
  }, [allDefinitions, selectedDefinitionIds, toggleDefinitionId, toggleDefinitionGroup])

  return (
    <>
      <StyledPageHeading>Definition List</StyledPageHeading>
      <Wrapper>
        <StyledSidebar contentsMinWidth="0px" gap={0}>
          <StyledAside>
            {isLoading ? (<Loading text="Loading..." alt="Loading" />) : (
              <SideNav className="definition-list" size="s" items={sideNavItems} onClick={onClickItem} />
            )}
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
  }

  & .definition-list {
    background-color: ${color.WHITE};
    text-wrap: nowrap;
    height: inherit;
    overflow: scroll;

    li:not(.selected) {
      background-color: ${color.WHITE};
    }

    // for definition group
    li:not(:has(.side-nav-indent)) {
      position: sticky;
      top: 0;
      z-index: 1;
    }

    button {
      display: flex;
      align-items: center;
    }
  }
`

const SideNavIndent = styled.span`
  margin-left: 2em;
`
