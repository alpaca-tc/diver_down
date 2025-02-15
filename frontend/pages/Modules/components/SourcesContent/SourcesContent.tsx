import { Link } from '@/components/Link'
import { EmptyTableBody, Table, Th, Text, Td, Button, Cluster, FaPencilIcon, FaCircleInfoIcon, Tooltip } from '@/components/ui'
import { path } from '@/constants/path'
import { DependencyType, Module, SpecificModule, SpecificModuleSource } from '@/models/module'
import { FC, useCallback, useMemo, useState } from 'react'
import { StickyThead } from '../StickyThead'
import { SortTypes, ascNumber, ascString, sortTypes } from '@/utils/sort'
import styled from 'styled-components'
import { SourceMemoInput } from '@/components/SourceMemoInput'
import { SourceDependencyTypeSelect } from '../SourceDependencyTypeSelect'

const SourceTr: FC<{ mutate: () => void; source: SpecificModuleSource; filteredModule: Module | null }> = ({
  mutate,
  source,
  filteredModule,
}) => {
  const [expanded, setExpanded] = useState<boolean>(false)
  const [editingMemo, setEditingMemo] = useState<boolean>(false)

  const modules = useMemo(() => {
    const modules = new Set<Module>()

    source.dependencies.forEach((dependency) => {
      if (dependency.module && (!filteredModule || dependency.module === filteredModule)) {
        modules.add(dependency.module)
      }
    })

    return [...modules].sort()
  }, [source])

  const dependencies = useMemo(() => {
    return source.dependencies
      .filter((dependency) => !filteredModule || dependency.module === filteredModule)
      .toSorted((a, b) => ascString(String(a.module), String(b.module)) || ascString(String(a.sourceName), String(b.sourceName)))
  }, [source, filteredModule])

  const dependencyTypes = useMemo(() => {
    const set = new Set<DependencyType>()

    dependencies.forEach((dependency) => {
      if (dependency.dependencyType) {
        set.add(dependency.dependencyType)
      }
    })

    return [...set].sort()
  }, [dependencies])

  return (
    <>
      <tr>
        <Td>
          {dependencies.length > 0 && (
            <Button size="s" onClick={() => setExpanded((prev) => !prev)}>
              {expanded ? 'Close' : 'Open'}
            </Button>
          )}
        </Td>
        <Td>
          <Text as="div" whiteSpace="nowrap">
            <Link to={path.sources.show(source.sourceName)}>{source.sourceName}</Link>
          </Text>
        </Td>
        <Td>
          {editingMemo ? (
            <SourceMemoInput
              sourceName={source.sourceName}
              initialMemo={source.memo}
              onUpdate={() => {
                setEditingMemo(false)
                mutate()
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
        <Td>
          {modules.map((module) => (
            <Text key={module} as="div" whiteSpace="nowrap">
              <Link to={path.modules.show(module)}>{module}</Link>
            </Text>
          ))}
        </Td>
        <Td>{dependencies.length}</Td>
        <Td>{dependencyTypes.join(', ')}</Td>
        <Td></Td>
        <Td></Td>
      </tr>

      {expanded &&
        dependencies.map((dependency) =>
          dependency.methodIds.map((methodId, index) => (
            <tr key={`${dependency.sourceName}-${methodId.context}-${methodId.name}`}>
              <Td></Td>
              <Td></Td>
              <Td></Td>
              <Td>
                {index === 0 && dependency.module && (
                  <Text as="div" whiteSpace="nowrap">
                    <Link to={path.modules.show(dependency.module)}>{dependency.module}</Link>
                  </Text>
                )}
              </Td>
              <Td>
                {index === 0 && (
                  <Text as="div" whiteSpace="nowrap">
                    <Link to={path.sources.show(dependency.sourceName)}>{dependency.sourceName}</Link>
                  </Text>
                )}
              </Td>
              <Td>
                {index === 0 && (
                  <SourceDependencyTypeSelect
                    onUpdated={mutate}
                    fromSource={source.sourceName}
                    toSource={dependency.sourceName}
                    dependencyType={dependency.dependencyType}
                  />
                )}
              </Td>
              <Td>{`${methodId.context === 'class' ? '.' : '#'}${methodId.name}`}</Td>
              <Td>
                {methodId.paths.map((methodIdPath) => (
                  <div key={methodIdPath}>
                    <Text>{methodIdPath}</Text>
                  </div>
                ))}
              </Td>
            </tr>
          )),
        )}
    </>
  )
}

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
    <Table fixedHead>
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
        <tbody>
          {sortedSources.map((source) => (
            <SourceTr key={source.sourceName} mutate={mutate} filteredModule={filteredModule} source={source} />
          ))}
        </tbody>
      )}
    </Table>
  )
}

const Transparent = styled.span`
  opacity: 0;
`

const FixedWidthMemo = styled(Cluster)`
  width: 4em;
`
