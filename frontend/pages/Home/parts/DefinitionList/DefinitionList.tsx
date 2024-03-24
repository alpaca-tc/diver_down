import React, { FC, useCallback } from 'react'
import { InView } from 'react-intersection-observer'

import { Loading } from '@/components/Loading'
import { useDefinitionList } from '@/repositories/definitionRepository'

import { List } from './List'

type Props = {
  selectedDefinitionIds: number[]
  setSelectedDefinitionIds: React.Dispatch<React.SetStateAction<number[]>>
}

export const DefinitionList: FC<Props> = ({ selectedDefinitionIds, setSelectedDefinitionIds }) => {
  const {
    isLoading,
    definitions,
    isValidating,
    setSize,
    isReachingEnd,
  } = useDefinitionList()

  const loadNextPage = useCallback(() => {
    if (!isLoading && !isValidating && !isReachingEnd) {
      setSize((size) => size + 1)
    }
  }, [isLoading, setSize, isValidating, isReachingEnd])

  return (
    isLoading ?
      (<Loading text="Loading..." alt="Loading" />) :
      (
        <InView>
          {({ inView, ref }) => (
            <List ref={ref} definitions={definitions} setSelectedDefinitionIds={setSelectedDefinitionIds} selectedDefinitionIds={selectedDefinitionIds} loadNextPage={loadNextPage} inView={inView} />
          )}
        </InView>
      )
  )
}
