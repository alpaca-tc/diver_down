import React, { FC, useCallback, useState } from 'react'
import { InView } from 'react-intersection-observer'
import styled from 'styled-components'

import { Loading } from '@/components/Loading'
import { Button, CheckBox, Cluster, FormControl, Heading, Input, Section,  FaCogIcon  } from '@/components/ui'
import { useDefinitionList } from '@/repositories/definitionRepository'

import { List } from './List'
import { ConfigureSearchOptionsDialog, SearchDefinitionsOptions } from './ConfigureSearchOptionsDialog'

type Props = {
  selectedDefinitionIds: number[]
  setSelectedDefinitionIds: React.Dispatch<React.SetStateAction<number[]>>
}

type DialogType = 'configureSearchOptionsDiaglog'

export const DefinitionList: FC<Props> = ({ selectedDefinitionIds, setSelectedDefinitionIds }) => {
  const [visibleDialog, setVisibleDialog] = useState<DialogType | null>(null)
  const [filteringInputText, setFilteringInputText] = useState<string>('')
  const [filteringQuery, setFilteringQuery] = useState<string>('')

  const {
    isLoading,
    definitions,
    isValidating,
    setSize,
    isReachingEnd,
  } = useDefinitionList(filteringQuery)

  const [searchDefinitionsOptions, setSearchDefinitionsOptions] = useState<SearchDefinitionsOptions>({ query: '', folding: false })

  const loadNextPage = useCallback(() => {
    if (!isLoading && !isValidating && !isReachingEnd) {
      setSize((size) => size + 1)
    }
  }, [isLoading, setSize, isValidating, isReachingEnd])

  const onClickCloseDialog = useCallback(() => {
    setVisibleDialog(null)
  }, [setVisibleDialog])

  return (
    isLoading ?
      (<Loading text="Loading..." alt="Loading" />) :
      (
        <StyledSection>
          <ConfigureSearchOptionsDialog isOpen={visibleDialog === 'configureSearchOptionsDiaglog'} onClickClose={onClickCloseDialog} searchDefinitionsOptions={searchDefinitionsOptions} setSearchDefinitionsOptions={setSearchDefinitionsOptions} />
          <Cluster align="center">
            <Cluster gap={0.5}>
              <Button size="s" square onClick={() => setVisibleDialog('configureSearchOptionsDiaglog')} prefix={<FaCogIcon alt="Open Options" />}>
                Open Options
              </Button>
            </Cluster>
          </Cluster>
          <InView>
            {({ inView, ref }) => (
              <List ref={ref} definitions={definitions} setSelectedDefinitionIds={setSelectedDefinitionIds} selectedDefinitionIds={selectedDefinitionIds} loadNextPage={loadNextPage} inView={inView} />
            )}
          </InView>
        </StyledSection>
      )
  )
}

const StyledSection = styled(Section)`
  height: inherit;
`
