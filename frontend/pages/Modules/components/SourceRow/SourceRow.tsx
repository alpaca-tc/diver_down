import { Text, Td, Button, FaPencilIcon, FaCircleInfoIcon, Tooltip, Cluster } from '@/components/ui'
import { path } from '@/constants/path'
import { Link } from '@/components/Link'
import { DependencyType, Module, SpecificModuleSource } from '@/models/module'
import { FC, useCallback, useMemo, useState } from 'react'
import { ascString } from '@/utils/sort'
import { SourceMemoInput } from '@/components/SourceMemoInput'
import { SourceDependencyTypeSelect } from '../SourceDependencyTypeSelect'
import styled from 'styled-components'
import { useConfiguration } from '@/repositories/configurationRepository'

type Props = {
  mutate: () => void
  source: SpecificModuleSource
  filteredModule: Module | null
}

export const SourceRow: FC<Props> = ({ mutate, source, filteredModule }) => {
  const [expanded, setExpanded] = useState<boolean>(false)
  const [editingMemo, setEditingMemo] = useState<boolean>(false)
  const { data: configuration } = useConfiguration()

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

  const blobPrefix: null | string = useMemo(() => {
    if (configuration?.blobPrefix) {
      return configuration.blobPrefix.replace(/\/$/, '')
    } else {
      return null
    }
  }, [configuration])

  const onUpdated = useCallback(() => {
    mutate()
  }, [source, mutate])

  const toBlobSuffix = (fullPath: string) => {
    const chunks = fullPath.split(':')

    if (chunks.length > 1 && chunks[chunks.length - 1].match(/^\d+$/)) {
      const line = chunks.pop()
      return `${chunks.join(':')}#L${line}`
    } else {
      return chunks.join(':')
    }
  }

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
                onUpdated()
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
                    onUpdated={onUpdated}
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
                    {blobPrefix ? (
                      <Link target="_blank" to={`${blobPrefix}/${toBlobSuffix(methodIdPath)}`}>
                        {methodIdPath}
                      </Link>
                    ) : (
                      <Text>{methodIdPath}</Text>
                    )}
                  </div>
                ))}
              </Td>
            </tr>
          )),
        )}
    </>
  )
}

const Transparent = styled.span`
  opacity: 0;
`

const FixedWidthMemo = styled(Cluster)`
  width: 4em;
`
