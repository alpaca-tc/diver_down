import React, { ComponentProps, forwardRef, useEffect, useMemo } from 'react'
import styled from 'styled-components'

import { InfiniteSideNav } from '@/components/InfiniteSideNav'
import { CheckBox } from '@/components/ui'
import { color } from '@/constants/theme'
import { Definition } from '@/models/definition'
import { groupBy } from '@/utils/groupBy'

const NULL_DEFINITION_GROUP = '_____null_____'

type Props = {
  folding: boolean
  loadNextPage: () => void
  inView: boolean
  definitions: Definition[]
  selectedDefinitionIds: number[]
  setSelectedDefinitionIds: React.Dispatch<React.SetStateAction<number[]>>
  isReachingEnd: boolean
}

export const List = forwardRef<HTMLLIElement, Props>((props, ref) => {
  const { definitions, inView, loadNextPage, selectedDefinitionIds, setSelectedDefinitionIds, folding, isReachingEnd } = props

  useEffect(() => {
    if (inView) {
      loadNextPage()
    }
  }, [inView, loadNextPage])

  const sideNavItems: ComponentProps<typeof InfiniteSideNav>['items'] = useMemo(() => {
    const groupedDefinitions = groupBy<Definition>(
      definitions,
      (definition) => definition.definitionGroup ?? NULL_DEFINITION_GROUP,
    )
    const items: ComponentProps<typeof InfiniteSideNav>['items'] = []

    Object.keys(groupedDefinitions).forEach((definitionGroup) => {
      const filteredDefinitions = groupedDefinitions[definitionGroup]

      if (definitionGroup !== NULL_DEFINITION_GROUP) {
        const definitionIds = filteredDefinitions.map(({ id }) => id)
        const allSelected = definitionIds.every((id) => selectedDefinitionIds.includes(id))

        const onClickDefinitionGroup = (
          event: React.MouseEvent<HTMLButtonElement, MouseEvent> | React.MouseEvent<HTMLInputElement, MouseEvent>,
        ) => {
          event.preventDefault()

          if (allSelected) {
            // disable all definitions in definition_group
            setSelectedDefinitionIds((prev) => prev.filter((prevId) => !definitionIds.includes(prevId)))
          } else {
            // enable all definitions in definition_group
            setSelectedDefinitionIds((prev) => [...new Set<number>([...prev, ...definitionIds])])
          }
        }

        items.push({
          key: `definition-group-${definitionGroup}`,
          title: definitionGroup,
          isSelected: allSelected,
          onClick: onClickDefinitionGroup,
          prefix: <CheckBox checked={allSelected} onClick={onClickDefinitionGroup} />,
        })
      }

      if (!folding || definitionGroup === NULL_DEFINITION_GROUP) {
        filteredDefinitions.forEach((definition) => {
          const onClickDefinition = (
            event: React.MouseEvent<HTMLButtonElement, MouseEvent> | React.MouseEvent<HTMLInputElement>,
          ) => {
            event.stopPropagation()

            setSelectedDefinitionIds((prev) => {
              if (prev.includes(definition.id)) {
                return prev.filter((prevId) => prevId !== definition.id)
              } else {
                return [...prev, definition.id]
              }
            })
          }

          const isSelected = selectedDefinitionIds.includes(definition.id)

          items.push({
            key: `definition-${definition.id}`,
            title: definition.title,
            isSelected,
            onClick: onClickDefinition,
            prefix: (
              <>
                {definitionGroup === NULL_DEFINITION_GROUP ? null : <InfiniteSideNavIndent className="side-nav-indent" />}
                <CheckBox checked={isSelected} onClick={onClickDefinition} />
              </>
            ),
          })
        })
      }
    })

    if (items.length > 0) {
      items[items.length - 1].ref = ref
    }

    if (isReachingEnd) {
      items.push({
        key: `definition-reaching-end`,
        title: '--- Reached the end ---',
        isSelected: false,
        onClick: () => {},
      })
    }

    return items
  }, [definitions, selectedDefinitionIds, ref, setSelectedDefinitionIds, folding, isReachingEnd])

  return <StyledInfiniteSideNav size="s" items={sideNavItems} />
})

const StyledInfiniteSideNav = styled(InfiniteSideNav)`
  background-color: ${color.WHITE};
  text-wrap: nowrap;

  li:not(.selected) {
    background-color: ${color.WHITE};
  }

  button {
    display: flex;
    align-items: center;
  }
`

const InfiniteSideNavIndent = styled.span`
  margin-left: 2em;
`
