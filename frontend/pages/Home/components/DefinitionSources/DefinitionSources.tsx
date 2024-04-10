import { FC, useCallback, useMemo, useState } from 'react'
import styled from 'styled-components'

import { Link } from '@/components/Link'
import {
  Aside,
  Button,
  Cluster,
  EmptyTableBody,
  FaPencilIcon,
  FaXmarkIcon,
  Table,
  TableReel,
  Td,
  Text,
  Th,
} from '@/components/ui'
import { path } from '@/constants/path'
import { color } from '@/constants/theme'
import { CombinedDefinition } from '@/models/combinedDefinition'

import { SourceModulesComboBox } from '../SourceModulesComboBox'

import type { DialogProps } from '../dialog'

type Props = {
  combinedDefinition: CombinedDefinition
  mutateCombinedDefinition: () => void
}

const sortTypes = ['asc', 'desc', 'none'] as const

type SortTypes = (typeof sortTypes)[number]

type SortState = {
  key: 'sourceName' | 'modules'
  sort: SortTypes
}

export const DefinitionSources: FC<Props> = ({ combinedDefinition, mutateCombinedDefinition }) => {
  const [sortState, setSortState] = useState<SortState>({ key: 'sourceName', sort: 'asc' })
  const [editingSourceNames, setEditingSourceNames] = useState<string[]>([])

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

  const sources: CombinedDefinition['sources'] = useMemo(() => {
    let sorted = [...combinedDefinition.sources]

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
  }, [combinedDefinition.sources, sortState])

  return (
    <WrapperAside>
      <TableWrapper>
        <TableReel>
          <StyledTable fixedHead>
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
            {sources.length === 0 ? (
              <EmptyTableBody>
                <Text>お探しの条件に該当する項目はありません。</Text>
                <Text>別の条件をお試しください。</Text>
              </EmptyTableBody>
            ) : (
              <tbody>
                {sources.map((source) => (
                  <tr key={source.sourceName}>
                    <Td>
                      <Link to={path.sources.show(source.sourceName)}>{source.sourceName}</Link>
                    </Td>
                    {editingSourceNames.includes(source.sourceName) ? (
                      <Td fixed colSpan={2}>
                        <SourceModulesComboBox
                          sourceName={source.sourceName}
                          initialModules={source.modules}
                          onUpdate={() => {
                            setEditingSourceNames((prev) => prev.filter((name) => name !== source.sourceName))
                            mutateCombinedDefinition()
                          }}
                          onClose={() => {
                            setEditingSourceNames((prev) => prev.filter((name) => name !== source.sourceName))
                          }}
                        />
                      </Td>
                    ) : (
                      <Td fixed>
                        <Cluster align="center">
                          <div>
                            {source.modules.map((module, index) => (
                              <Text key={index} as="div" whiteSpace="nowrap">
                                <Link to={path.modules.show(source.modules.slice(0, index + 1).map((mod) => mod.moduleName))}>
                                  {module.moduleName}
                                </Link>
                              </Text>
                            ))}
                          </div>
                          <div>
                            <Button
                              square={true}
                              onClick={() => setEditingSourceNames((prev) => [...prev, source.sourceName])}
                              size="s"
                            >
                              <FaPencilIcon alt="Edit" />
                            </Button>
                          </div>
                        </Cluster>
                      </Td>
                    )}
                  </tr>
                ))}
              </tbody>
            )}
          </StyledTable>
        </TableReel>
      </TableWrapper>
    </WrapperAside>
  )
}

const WrapperAside = styled(Aside)`
  list-style: none;
  padding: 0;
  height: inherit;
  overflow-y: scroll;

  &&& {
    margin-top: 0;
  }
`

const TableWrapper = styled.div`
  overflow: clip;
  overflow-x: scroll;
`

const StyledTable = styled(Table)`
  border-left: 1px ${color.BORDER} solid;
`
