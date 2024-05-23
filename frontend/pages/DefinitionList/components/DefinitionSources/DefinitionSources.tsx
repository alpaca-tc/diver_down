import { FC, useCallback, useMemo, useState } from 'react'
import styled from 'styled-components'

import { Link } from '@/components/Link'
import {
  Aside,
  Cluster,
  EmptyTableBody,
  FaCircleInfoIcon,
  FaPencilIcon,
  Table,
  TableReel,
  Td,
  Text,
  Th,
  Tooltip,
} from '@/components/ui'
import { path } from '@/constants/path'
import { color } from '@/constants/theme'
import { CombinedDefinition } from '@/models/combinedDefinition'

import { SourceModulesComboBox } from '../SourceModulesComboBox'
import { sortSources } from '@/models/source'
import { SourceMemoInput } from '../SourceMemoInput'

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
  const [editingModulesSourceNames, setEditingModulesSourceNames] = useState<string[]>([])
  const [editingMemoSourceNames, setEditingMemoSourceNames] = useState<string[]>([])

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
    return sortSources(combinedDefinition.sources, sortState.key, sortState.sort)
  }, [combinedDefinition.sources, sortState])

  return (
    <WrapperAside>
      <TableWrapper>
        <TableReel>
          <Table fixedHead>
            <thead>
              <tr>
                <Th sort={sortState.key === 'sourceName' ? sortState.sort : 'none'} onSort={() => setNextSortType('sourceName')}>
                  Source name
                </Th>
                <Th>Memo</Th>
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
                    <Td>
                      {editingMemoSourceNames.includes(source.sourceName) ? (
                        <SourceMemoInput
                          sourceName={source.sourceName}
                          initialMemo={source.memo}
                          onUpdate={() => {
                            setEditingMemoSourceNames((prev) => prev.filter((name) => name !== source.sourceName))
                            mutateCombinedDefinition()
                          }}
                          onClose={() => {
                            setEditingMemoSourceNames((prev) => prev.filter((name) => name !== source.sourceName))
                          }}
                        />
                      ) : (
                        <FixedWidthMemo align="center">
                          {source.memo !== '' ? (
                            <Tooltip message={source.memo} horizontal="center" vertical="bottom">
                              <FaCircleInfoIcon />
                            </Tooltip>
                          ) : (
                            <Transparent>
                              <FaCircleInfoIcon />
                            </Transparent>
                          )}
                          <div>
                            <Button
                              square={true}
                              onClick={() => setEditingMemoSourceNames((prev) => [...prev, source.sourceName])}
                              size="s"
                            >
                              <FaPencilIcon alt="Edit" />
                            </Button>
                          </div>
                        </FixedWidthMemo>
                      )}
                    </Td>
                    {!editingMemoSourceNames.includes(source.sourceName) &&
                    editingModulesSourceNames.includes(source.sourceName) ? (
                      <Td fixed colSpan={2}>
                        <SourceModulesComboBox
                          sourceName={source.sourceName}
                          initialModules={source.modules}
                          onUpdate={() => {
                            setEditingModulesSourceNames((prev) => prev.filter((name) => name !== source.sourceName))
                            mutateCombinedDefinition()
                          }}
                          onClose={() => {
                            setEditingModulesSourceNames((prev) => prev.filter((name) => name !== source.sourceName))
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
                              onClick={() => setEditingModulesSourceNames((prev) => [...prev, source.sourceName])}
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
          </Table>
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
  max-width: 600px;
  border-left: 1px ${color.BORDER} solid;

  &&& {
    margin-top: 0;
  }
`

const TableWrapper = styled.div`
  overflow: clip;
  overflow-x: scroll;
`

const Transparent = styled.span`
  opacity: 0;
`

const FixedWidthMemo = styled(Cluster)`
  width: 4em;
`
