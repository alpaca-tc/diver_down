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
import { SourceModulesComboBox } from '@/components/SourceModulesComboBox'
import { UpdateSourceModulesButton } from '@/components/UpdateSourceModulesButton'
import { SourceMemoInput } from '@/components/SourceMemoInput'
import { createSearchParams, useNavigate } from 'react-router-dom'

const sortTypes = ['asc', 'desc', 'none'] as const

type SortTypes = (typeof sortTypes)[number]

type SortState = {
  key: 'sourceName' | 'modules'
  sort: SortTypes
}

type RowProps = {
  source: Source
  recentModules: Module[]
  onUpdated: () => void
  setRecentModules: React.Dispatch<React.SetStateAction<Module[]>>
}

const Row: FC<RowProps> = ({ source, recentModules, onUpdated, setRecentModules }) => {
  const [editingMemo, setEditingMemo] = useState<boolean>(false)
  const [editingModules, setEditingModules] = useState<boolean>(false)

  return (
    <tr>
      <Td>
        <Link to={path.sources.show(source.sourceName)}>{source.sourceName}</Link>
      </Td>
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
          <SourceModulesComboBox
            sourceName={source.sourceName}
            initialModules={source.modules}
            onUpdate={(modules) => {
              setRecentModules(modules)
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
              {source.modules.map((module, index) => (
                <Text key={index} as="div" whiteSpace="nowrap">
                  <Link to={path.modules.show(source.modules.slice(0, index + 1).map((mod) => mod.moduleName))}>
                    {module.moduleName}
                  </Link>
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
                <UpdateSourceModulesButton sourceName={source.sourceName} newModules={recentModules} onSaved={onUpdated} />
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
  const [recentModules, setRecentModules] = useState<Module[]>([])
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
          recentModules={recentModules}
          onUpdated={onUpdated}
          setRecentModules={setRecentModules}
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
      search: createSearchParams(params).toString()
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
                <Th>Memo</Th>
                <Th sort={sortState.key === 'modules' ? sortState.sort : 'none'} onSort={() => setNextSortType('modules')}>
                  Modules
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
