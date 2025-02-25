import { EmptyTableBody, Table, Th, Text } from '@/components/ui'
import { Module, SpecificModule, SpecificModuleSource } from '@/models/module'
import { FC, useCallback, useMemo, useState } from 'react'
import { StickyThead } from '../StickyThead'
import { SortTypes, ascNumber, ascString, sortTypes } from '@/utils/sort'
import { SourceRow } from '../SourceRow'

const sortSources = (
  sources: SpecificModuleSource[],
  key: 'sourceName' | 'dependency',
  sort: 'none' | 'asc' | 'desc',
): SpecificModuleSource[] => {
  if (sort === 'none') {
    return sources
  }

  let sorted: SpecificModuleSource[]

  switch (key) {
    case 'sourceName': {
      sorted = sources.toSorted((a, b) => ascString(a.sourceName, b.sourceName))
      break
    }
    case 'dependency': {
      sorted = sources.toSorted((a, b) => ascNumber(a.dependencies.length, b.dependencies.length))
    }
  }

  if (sort === 'desc') {
    sorted = sorted.reverse()
  }

  return sorted
}

type SortType = {
  key: 'sourceName' | 'dependency'
  sort: SortTypes
}

type Props = {
  mutate: () => void
  sources: SpecificModule['sources']
  filteredModule: Module | null
}

export const SourcesContent: FC<Props> = ({ mutate, filteredModule, sources }) => {
  const [sort, setSort] = useState<SortType>({ key: 'sourceName', sort: 'none' })

  const sortedSources = useMemo(() => {
    let sorted = sortSources(sources, sort.key, sort.sort)

    if (filteredModule) {
      sorted = sorted.filter((source) => source.dependencies.some((dependency) => dependency.module === filteredModule))
    }

    return sorted
  }, [sort, filteredModule, sources])

  const setNextSort = useCallback(
    (key: SortType['key']) => {
      setSort((prev) => {
        if (prev.key === key) {
          return {
            key,
            sort: sortTypes[(sortTypes.indexOf(prev.sort) + 1) % sortTypes.length],
          }
        } else {
          return { key, sort: 'asc' }
        }
      })
    },
    [setSort],
  )

  const [totalDependenciesCount, notSelectedDependenciesCount] = useMemo(() => {
    let totalDependenciesCount = 0
    let notSelectedDependenciesCount = 0

    sortedSources.forEach((source) => {
      source.dependencies.forEach((dependency) => {
        if (!filteredModule || dependency.module === filteredModule) {
          totalDependenciesCount++

          if (dependency.dependencyType) {
            notSelectedDependenciesCount++
          }
        }
      })
    })

    return [totalDependenciesCount, notSelectedDependenciesCount] as const
  }, [sortedSources, filteredModule])

  return (
    <Table fixedHead layout="fixed" style={{ width: '120%' }}>
      <colgroup>
        <col style={{ width: '70px' }} />
        <col style={{ width: '390px' }} />
        <col style={{ width: '80px' }} />
        <col style={{ width: '150px' }} />
        <col style={{ width: '200px' }} />
        <col style={{ width: '150px' }} />
        <col style={{ width: '250px' }} />
        <col style={{ width: '200px' }} />
      </colgroup>
      <StickyThead>
        <tr>
          <Th></Th>
          <Th sort={sort.key === 'sourceName' ? sort.sort : 'none'} onSort={() => setNextSort('sourceName')}>
            Source
          </Th>
          <Th>Memo</Th>
          <Th>Dependency Module</Th>
          <Th sort={sort.key === 'dependency' ? sort.sort : 'none'} onSort={() => setNextSort('dependency')}>
            Dependency
          </Th>
          <Th>
            Dependency Type(
            {notSelectedDependenciesCount === totalDependenciesCount
              ? totalDependenciesCount
              : `${notSelectedDependenciesCount}/${totalDependenciesCount}`}
            )
          </Th>
          <Th>Method Id</Th>
          <Th>Path</Th>
        </tr>
      </StickyThead>
      {sortedSources.length === 0 ? (
        <EmptyTableBody>
          <Text>No sources</Text>
        </EmptyTableBody>
      ) : (
        <tbody style={{ overflowY: 'scroll' }}>
          {sortedSources.map((source) => (
            <SourceRow key={source.sourceName} mutate={mutate} filteredModule={filteredModule} source={source} />
          ))}
        </tbody>
      )}
    </Table>
  )
}
