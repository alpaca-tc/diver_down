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

export const DefinitionList: FC<Props> = ({ selectedDefinitionIds, setSelectedDefinitionIds }) => {
  const [openedConfigureSearchOptionsDialog, setOpenedConfigureSearchOptionsDialog] = useState<boolean>(false)
  const [searchDefinitionsOptions, setSearchDefinitionsOptions] = useLocalStorage<SearchDefinitionsOptions>(
    'Home-DefinitionList-SearchDefinitionOptions-v1',
    { definitionGroup: String, title: String, source: String, folding: Boolean },
  )
  const [foldingSection, setFoldingSection] = useState<boolean>(false)

  const { isLoading, definitions, isValidating, setSize, isReachingEnd } = useDefinitionList({
    definitionGroup: searchDefinitionsOptions.definitionGroup,
    title: searchDefinitionsOptions.title,
    source: searchDefinitionsOptions.source,
  })

  const loadNextPage = useCallback(() => {
    if (!isLoading && !isValidating && !isReachingEnd) {
      setSize((size) => size + 1)
    }
  }, [isLoading, setSize, isValidating, isReachingEnd])

  const onClickCloseDialog = useCallback(() => {
    setOpenedConfigureSearchOptionsDialog(false)
  }, [setOpenedConfigureSearchOptionsDialog])

  const onClickReset = useCallback(() => {
    setSelectedDefinitionIds([])
  }, [setSelectedDefinitionIds])

  const toggleFoldingSection = useCallback(() => {
    setFoldingSection((prev) => !prev)
  }, [setFoldingSection])

  return isLoading ? (
    <Loading text="Loading..." alt="Loading" />
  ) : (
    <StyledSection $foldingSection={foldingSection}>
      <StickyCluster align="center">
        <Cluster gap={0.5}>
          <Button size="s" onClick={toggleFoldingSection}>
            {foldingSection ? 'fold' : 'unfold'}
          </Button>
          {foldingSection && (
            <>
              <Button
                size="s"
                square
                onClick={() => setOpenedConfigureSearchOptionsDialog(true)}
                prefix={<FaGearIcon alt="Open Options" />}
              >
                Open Options
              </Button>
              <Button size="s" onClick={onClickReset}>
                Clear
              </Button>
            </>
          )}
        </Cluster>
      </StickyCluster>
      <ConfigureSearchOptionsDialog
        isOpen={openedConfigureSearchOptionsDialog}
        onClickClose={onClickCloseDialog}
        searchDefinitionsOptions={searchDefinitionsOptions}
        setSearchDefinitionsOptions={setSearchDefinitionsOptions}
      />
      <InView>
        {({ inView, ref }) => (
          <List
            ref={ref}
            definitions={definitions}
            setSelectedDefinitionIds={setSelectedDefinitionIds}
            selectedDefinitionIds={selectedDefinitionIds}
            loadNextPage={loadNextPage}
            inView={inView}
            folding={searchDefinitionsOptions.folding}
            isReachingEnd={isReachingEnd}
          />
        )}
      </InView>
    </StyledSection>
  )
}

const StickyCluster = styled(Cluster)`
  position: sticky;
  top: 0;
  z-index: 1;
  background: white;
`

const StyledSection = styled(Section)<{ $foldingSection: boolean }>`
  height: inherit;
  overflow: scroll;
  width: ${({ $foldingSection }) => ($foldingSection ? `100%` : '200px')};
`
