import React, { FC, useCallback, useState } from 'react'
import { InView } from 'react-intersection-observer'
import styled from 'styled-components'

import { Loading } from '@/components/Loading'
import { Button, Cluster, FaGearIcon, Section } from '@/components/ui'
import { useLocalStorage } from '@/hooks/useLocalStorage'
import { useDefinitionList } from '@/repositories/definitionListRepository'

import { ConfigureSearchOptionsDialog, SearchDefinitionsOptions } from './ConfigureSearchOptionsDialog'
import { List } from './List'

type Props = {
  selectedDefinitionIds: number[]
  setSelectedDefinitionIds: React.Dispatch<React.SetStateAction<number[]>>
}

type DialogType = 'configureSearchOptionsDiaglog'

export const DefinitionList: FC<Props> = ({ selectedDefinitionIds, setSelectedDefinitionIds }) => {
  const [visibleDialog, setVisibleDialog] = useState<DialogType | null>(null)
  const [searchDefinitionsOptions, setSearchDefinitionsOptions] = useLocalStorage<SearchDefinitionsOptions>('Home-DefinitionList-SearchDefinitionOptions', { title: '', source: '', folding: false })

  const {
    isLoading,
    definitions,
    isValidating,
    setSize,
    isReachingEnd,
  } = useDefinitionList({ title: searchDefinitionsOptions.title, source: searchDefinitionsOptions.source })

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
              <Button size="s" square onClick={() => setVisibleDialog('configureSearchOptionsDiaglog')} prefix={<FaGearIcon alt="Open Options" />}>
                Open Options
              </Button>
            </Cluster>
          </Cluster>
          <InView>
            {({ inView, ref }) => (
              <List ref={ref} definitions={definitions} setSelectedDefinitionIds={setSelectedDefinitionIds} selectedDefinitionIds={selectedDefinitionIds} loadNextPage={loadNextPage} inView={inView} folding={searchDefinitionsOptions.folding} />
            )}
          </InView>
        </StyledSection>
      )
  )
}

const StyledSection = styled(Section)`
  height: inherit;
`
