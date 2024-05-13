import { FC, useCallback, useMemo, useState } from 'react'
import styled from 'styled-components'

import { Link } from '@/components/Link'
import { Loading } from '@/components/Loading'
import { EmptyTableBody, Heading, Section, Stack, Table, Td, Text, Th } from '@/components/ui'
import { path } from '@/constants/path'
import { spacing } from '@/constants/theme'
import { useSources } from '@/repositories/sourceRepository'
import { Sources } from '@/models/source'

const sortTypes = ['asc', 'desc', 'none'] as const

type SortTypes = (typeof sortTypes)[number]

type SortState = {
  key: 'sourceName' | 'modules'
  sort: SortTypes
}

export const List: FC = () => {
  const { data, isLoading } = useSources()
  const [sortState, setSortState] = useState<SortState>({ key: 'sourceName', sort: 'asc' })

  const setNextSortType = useCallback(
    (key: SortState['key']) => {
      setSortState((prev) => {
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
    [setSortState],
  )

  const sources: Sources['sources'] = useMemo(() => {
    if (!data) {
      return null
    }

    let sorted = [...data.sources]

    if (sortState.sort === 'none') {
      return sorted
    }

    const ascString = (a: string, b: string) => {
      if (a > b) return 1
      if (a < b) return -1
      return 0
    }

    switch (sortState.key) {
      case 'sourceName': {
        sorted = sorted.sort((a, b) => ascString(a.sourceName, b.sourceName))
        break
      }
      case 'modules': {
        sorted = sorted.sort((a, b) =>
          ascString(
            a.modules.map((module) => module.moduleName).join('-'),
            b.modules.map((module) => module.moduleName).join('-'),
          ),
        )
      }
    }

    if (sortState.sort === 'desc') {
      sorted = sorted.reverse()
    }

    return sorted
  }, [data?.sources, sortState])

  return (
    <StyledSection>
      <Stack>
        <Heading type="screenTitle">Sources {data ? `(classified: ${Math.round(data.classifiedSourcesCount / data.sources.length * 100)}% ${data.classifiedSourcesCount} / ${data.sources.length})` : null}</Heading>

        <div style={{ overflow: 'clip' }}>
          <Table fixedHead>
            <thead>
              <tr>
                <Th sort={sortState.key === 'sourceName' ? sortState.sort : 'none'} onSort={() => setNextSortType('sourceName')}>
                  Source name
                </Th>
                <Th fixed sort={sortState.key === 'modules' ? sortState.sort : 'none'} onSort={() => setNextSortType('modules')}>
                  Modules
                </Th>
              </tr>
            </thead>
            {sources && sources.length > 0 ? (
              <tbody>
                {sources.map((source) => (
                  <tr key={source.sourceName}>
                    <Td>
                      <Link to={path.sources.show(source.sourceName)}>{source.sourceName}</Link>
                    </Td>
                    <Td>
                      {source.modules.map((module, index) => (
                        <Text key={index} as="div" whiteSpace="nowrap">
                          <Link to={path.modules.show(source.modules.slice(0, index + 1).map((mod) => mod.moduleName))}>
                            {module.moduleName}
                          </Link>
                        </Text>
                      ))}
                    </Td>
                  </tr>
                ))}
              </tbody>
            ) : (
              <EmptyTableBody>{isLoading ? <Loading /> : <Text>Not Found</Text>}</EmptyTableBody>
            )}
          </Table>
        </div>
      </Stack>
    </StyledSection>
  )
}

const StyledSection = styled(Section)`
  padding: ${spacing.XS};
`
