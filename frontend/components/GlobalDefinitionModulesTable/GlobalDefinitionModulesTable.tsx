import { FC, useCallback, useMemo, useState } from 'react'
import styled from 'styled-components'

import { Link } from '@/components/Link'
import { Aside, Cluster, EmptyTableBody, Stack, Table, TableReel, Td, Text, Th } from '@/components/ui'
import { path } from '@/constants/path'
import { color } from '@/constants/theme'
import { CombinedDefinition, GraphOptions } from '@/models/combinedDefinition'

import React from 'react'
import { Loading } from '@/components/Loading'
import { Module } from '@/models/module'
import { ModuleDependency, buildModuleDependencyMap } from './buildModuleDependencyMap'
import { stringify } from '@/utils/queryString'
import { ascString } from '@/utils/sort'

const sortTypes = ['asc', 'desc'] as const

type SortTypes = (typeof sortTypes)[number]

type TopModuleTrProps = {
  module: Module
  moduleDependency: ModuleDependency
  graphOptions: GraphOptions
}

const ModuleTr: FC<TopModuleTrProps> = ({ module, moduleDependency, graphOptions }) => {
  const linkGraphOptions: GraphOptions = Object.assign({}, graphOptions, {
    focusModules: [module],
    modules: [...new Set([...moduleDependency.dependencyModules, ...moduleDependency.reverseDependencyModules])],
    onlyModule: false,
    removeInternalSources: true,
  })

  return (
    <tr>
      <Td>
        <Link to={path.modules.show(module)}>{module}</Link>
      </Td>
      <Td>{moduleDependency.sourcesCount}</Td>
      <Td>
        <Link to={`${path.globalDefinition.show()}?${stringify(linkGraphOptions)}`}>
          {moduleDependency.dependencyModules.size} / {moduleDependency.reverseDependencyModules.size}
        </Link>
      </Td>
    </tr>
  )
}

type GlobalDefinitionModulesProps = {
  combinedDefinition: CombinedDefinition | null
  graphOptions: GraphOptions
}

export const GlobalDefinitionModulesTable: FC<GlobalDefinitionModulesProps> = ({ combinedDefinition, graphOptions }) => {
  const [sortState, setSortState] = useState<SortTypes>('asc')

  const setNextSortState = useCallback(() => {
    setSortState((prev) => (prev === 'asc' ? 'desc' : 'asc'))
  }, [setSortState])

  const moduleDependency = useMemo(() => buildModuleDependencyMap(combinedDefinition?.sources || []), [combinedDefinition])
  const sortedTopModuleKeys: Module[] = useMemo(() => {
    const asc = [...moduleDependency.keys()].sort(ascString)
    return sortState === 'asc' ? asc : asc.reverse()
  }, [moduleDependency, sortState])

  return (
    <WrapperAside>
      <TableWrapper>
        <TableReel>
          <Table fixedHead>
            <thead>
              <tr>
                <Th sort={sortState} onSort={() => setNextSortState()}>
                  Module Name
                </Th>
                <Th>Sources Count</Th>
                <Th>
                  <Stack>
                    <Text>Modules Count</Text>
                    <Text>Dependency / Reverse Dependency</Text>
                  </Stack>
                </Th>
              </tr>
            </thead>
            {!combinedDefinition ? (
              <CenterStack>
                <Loading text="Loading..." alt="Loading" />
              </CenterStack>
            ) : sortedTopModuleKeys.length === 0 ? (
              <EmptyTableBody>
                <Text>No modules</Text>
              </EmptyTableBody>
            ) : (
              <tbody>
                {sortedTopModuleKeys.map((key) => (
                  <ModuleTr key={key} module={key} moduleDependency={moduleDependency.get(key)!} graphOptions={graphOptions} />
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

const CenterStack = styled(Stack)`
  display: flex;
  flex-direction: row;
  height: inherit;
  justify-content: center;
`
