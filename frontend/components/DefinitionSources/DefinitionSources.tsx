import { FC, useCallback, useContext, useEffect, useMemo, useState, createRef } from 'react'
import styled from 'styled-components'

import { Link } from '@/components/Link'
import {
  Aside,
  Button,
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

import { Source, sortSources } from '@/models/source'
import { RecentModulesContext } from '@/context/RecentModulesContext'
import { SourceModulesComboBox } from '@/components/SourceModulesComboBox'
import { UpdateSourceModulesButton } from '@/components/UpdateSourceModulesButton'
import { SourceMemoInput } from '@/components/SourceMemoInput'
import React from 'react'
import { HoverDotMetadataContext } from '@/context/HoverMetadataContext'

const sortTypes = ['asc', 'desc', 'none'] as const

type SortTypes = (typeof sortTypes)[number]

type SortState = {
  key: 'sourceName' | 'modules'
  sort: SortTypes
}

type DefinitionSourceTrProps = {
  source: Source
  combinedDefinition: CombinedDefinition
  mutateCombinedDefinition: () => void
}

// Return tr
const isTr = (event: MouseEvent, trRef: HTMLTableRowElement): boolean => {
  const tr = (event.target as HTMLElement).closest<Element>('tr')

  return tr === trRef
}

const DefinitionSourceTr: FC<DefinitionSourceTrProps> = ({ source, combinedDefinition, mutateCombinedDefinition }) => {
  const ref = createRef<HTMLTableRowElement>()
  const { recentModules, setRecentModules } = useContext(RecentModulesContext)
  const { setHoverDotMetadata } = useContext(HoverDotMetadataContext)
  const [editingMemo, setEditingMemo] = useState<boolean>(false)
  const [editingModules, setEditingModules] = useState<boolean>(false)

  // On hover .node, .edge, .cluster
  useEffect(() => {
    if (!combinedDefinition || !ref.current) return

    const currentRef = ref.current

    const onMouseMove = (event: MouseEvent) => {
      if (!isTr(event, currentRef)) return

      const dotMetadata = combinedDefinition.dotMetadata.find((d) => d.type === 'source' && d.sourceName === source.sourceName)

      console.log(`set ${dotMetadata?.id}`)
      setHoverDotMetadata(dotMetadata ?? null)
    }

    document.addEventListener('mousemove', onMouseMove)

    return () => {
      document.removeEventListener('mousemove', onMouseMove)
    }
  }, [combinedDefinition?.dotMetadata, setHoverDotMetadata])

  return (
    <tr ref={ref}>
      <Td>
        <Cluster>
          <Link to={path.sources.show(source.sourceName)}>{source.sourceName}</Link>
          {source.resolvedAlias ? (
            <Tooltip message={`Alias: ${source.resolvedAlias}`} horizontal="center" vertical="bottom">
              <FaCircleInfoIcon />
            </Tooltip>
          ) : null}
        </Cluster>
      </Td>
      <Td>
        {editingMemo ? (
          <SourceMemoInput
            sourceName={source.sourceName}
            initialMemo={source.memo}
            onUpdate={() => {
              setEditingMemo(false)
              mutateCombinedDefinition()
            }}
            onClose={() => {
              setEditingMemo(false)
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
              <Button square={true} onClick={() => setEditingMemo(true)} size="s">
                <FaPencilIcon alt="Edit" />
              </Button>
            </div>
          </FixedWidthMemo>
        )}
      </Td>
      {!editingMemo && editingModules ? (
        <Td fixed colSpan={2}>
          <SourceModulesComboBox
            sourceName={source.sourceName}
            initialModules={source.modules}
            onUpdate={(modules) => {
              setRecentModules(modules)
              setEditingModules(false)
              mutateCombinedDefinition()
            }}
            onClose={() => {
              setEditingModules(false)
            }}
          />
        </Td>
      ) : (
        <Td fixed>
          <Cluster align="bottom">
            <div>
              {source.modules.map((module, index) => (
                <Text key={index} as="div" whiteSpace="nowrap">
                  <Link to={path.modules.show(source.modules.slice(0, index + 1))}>{module}</Link>
                </Text>
              ))}
            </div>
            <div>
              <Button square={true} onClick={() => setEditingModules(true)} size="s">
                <FaPencilIcon alt="Edit" />
              </Button>
            </div>

            {source.modules.length === 0 && (
              <div>
                <UpdateSourceModulesButton
                  sourceName={source.sourceName}
                  newModules={recentModules}
                  onSaved={mutateCombinedDefinition}
                />
              </div>
            )}
          </Cluster>
        </Td>
      )}
    </tr>
  )
}

type DefinitionSourcesProps = {
  combinedDefinition: CombinedDefinition
  mutateCombinedDefinition: () => void
}

export const DefinitionSources: FC<DefinitionSourcesProps> = ({ combinedDefinition, mutateCombinedDefinition }) => {
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
                  <DefinitionSourceTr
                    key={source.sourceName}
                    source={source}
                    combinedDefinition={combinedDefinition}
                    mutateCombinedDefinition={mutateCombinedDefinition}
                  />
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
