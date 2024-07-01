import { FC, useCallback, useDeferredValue, useEffect, useMemo, useState } from 'react'
import styled from 'styled-components'

import { Link } from '@/components/Link'
import { Loading } from '@/components/Loading'
import {
  Button,
  Cluster,
  EmptyTableBody,
  FaPencilIcon,
  FormControl,
  Heading,
  Input,
  Section,
  Stack,
  Table,
  Td,
  Text,
  Th,
} from '@/components/ui'
import { path } from '@/constants/path'
import { spacing } from '@/constants/theme'
import { useSources } from '@/repositories/sourceRepository'
import { Source, Sources, sortSources } from '@/models/source'
import { Module } from '@/models/module'
import { SourceModuleComboBox } from '@/components/SourceModuleComboBox'
import { UpdateSourceModuleButton } from '@/components/UpdateSourceModuleButton'
import { SourceMemoInput } from '@/components/SourceMemoInput'
import { createSearchParams, useNavigate } from 'react-router-dom'
import { SortTypes, sortTypes } from '@/utils/sort'

type SortState = {
  key: 'sourceName' | 'module'
  sort: SortTypes
}

type RowProps = {
  source: Source
  recentModule: Module | null
  onUpdated: () => void
  setRecentModule: React.Dispatch<React.SetStateAction<Module | null>>
}

const Row: FC<RowProps> = ({ source, recentModule, onUpdated, setRecentModule }) => {
  const [editingMemo, setEditingMemo] = useState<boolean>(false)
  const [editingModules, setEditingModules] = useState<boolean>(false)

  return (
    <tr>
      <Td>
        <Link to={path.sources.show(source.sourceName)}>{source.sourceName}</Link>
      </Td>
      <Td>{source.resolvedAlias ? <Link to={path.sources.show(source.resolvedAlias)}>{source.resolvedAlias}</Link> : null}</Td>
      <Td>
        {editingMemo ? (
          <SourceMemoInput
            sourceName={source.sourceName}
            initialMemo={source.memo}
            onUpdate={() => {
              setEditingMemo(false)
              onUpdated()
            }}
            onClose={() => {
              setEditingMemo(false)
            }}
          />
        ) : (
          <Cluster>
            <Text>{source.memo}</Text>
            <Button square={true} onClick={() => setEditingMemo(true)} size="s">
              <FaPencilIcon alt="Edit" />
            </Button>
          </Cluster>
        )}
      </Td>
      {!editingMemo && editingModules ? (
        <Td>
          <SourceModuleComboBox
            sourceName={source.sourceName}
            initialModule={source.module}
            onUpdate={(module) => {
              setRecentModule(module)
              setEditingModules(false)
              onUpdated()
            }}
            onClose={() => {
              setEditingModules(false)
            }}
          />
        </Td>
      ) : (
        <Td>
          <Cluster align="bottom">
            <div>
              {source.module && (
                <Text as="div" whiteSpace="nowrap">
                  <Link to={path.modules.show(source.module)}>{source.module}</Link>
                </Text>
              )}
            </div>
            <div>
              <Button square={true} onClick={() => setEditingModules(true)} size="s">
                <FaPencilIcon alt="Edit" />
              </Button>
            </div>

            {source.module === null && (
              <div>
                <UpdateSourceModuleButton sourceName={source.sourceName} newModule={recentModule} onSaved={onUpdated} />
              </div>
            )}
          </Cluster>
        </Td>
      )}
    </tr>
  )
}

type SourcesTableBodyProps = {
  allSources: Sources['sources']
  inputSourceName: string
  sortState: SortState
  onUpdated: () => void
}

const SourcesTableBody: React.FC<SourcesTableBodyProps> = ({ allSources, inputSourceName, sortState, onUpdated }) => {
  const [recentModule, setRecentModule] = useState<Module | null>(null)
  const sources: Sources['sources'] = useMemo(() => {
    let sources = allSources

    if (!/^\s*$/.test(inputSourceName)) {
      const words = inputSourceName
        .split(/\s+/)
        .map((s) => s.trim().toLowerCase())
        .filter((s) => s !== '')

      sources = sources.filter((source) => {
        const sourceName = source.sourceName.toLowerCase()
        return words.every((word) => sourceName.includes(word))
      })
    }

    return sortSources(sources, sortState.key, sortState.sort)
  }, [allSources, sortState, inputSourceName])

  return (
    <tbody>
      {sources.map((source) => (
        <Row
          key={source.sourceName}
          source={source}
          recentModule={recentModule}
          onUpdated={onUpdated}
          setRecentModule={setRecentModule}
        />
      ))}
    </tbody>
  )
}

export const List: FC = () => {
  const { data, mutate, isLoading } = useSources()
  const navigate = useNavigate()
  const [sortState, setSortState] = useState<SortState>({ key: 'sourceName', sort: 'asc' })
  const [inputSourceName, setInputSourceName] = useState<string>('')
  const deferredInputSourceName = useDeferredValue(inputSourceName)

  const handleInputSourceName = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => {
      setInputSourceName(event.target.value)
    },
    [setInputSourceName],
  )

  useEffect(() => {
    const params: { sourceName?: string } = {}

    if (deferredInputSourceName.length > 0) {
      params.sourceName = deferredInputSourceName
    }

    navigate({
      pathname: path.sources.index(),
      search: createSearchParams(params).toString(),
    })
  }, [navigate, deferredInputSourceName])

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

  return (
    <StyledSection>
      <Stack>
        <Heading type="screenTitle">
          Sources{' '}
          {data
            ? `(classified: ${Math.round((data.classifiedSourcesCount / data.sources.length) * 100)}% ${data.classifiedSourcesCount} / ${data.sources.length})`
            : null}
        </Heading>

        <FormControl title="Filtering Sources" helpMessage="Refine the source with a source name">
          <Input name="title" type="text" onChange={handleInputSourceName} value={inputSourceName} />
        </FormControl>

        <div style={{ overflow: 'clip' }}>
          <Table fixedHead>
            <thead>
              <tr>
                <Th sort={sortState.key === 'sourceName' ? sortState.sort : 'none'} onSort={() => setNextSortType('sourceName')}>
                  Source name
                </Th>
                <Th>Source Alias</Th>
                <Th>Memo</Th>
                <Th sort={sortState.key === 'module' ? sortState.sort : 'none'} onSort={() => setNextSortType('module')}>
                  Module
                </Th>
              </tr>
            </thead>
            {data?.sources && data.sources.length > 0 ? (
              <SourcesTableBody
                allSources={data.sources}
                inputSourceName={deferredInputSourceName}
                sortState={sortState}
                onUpdated={mutate}
              />
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
