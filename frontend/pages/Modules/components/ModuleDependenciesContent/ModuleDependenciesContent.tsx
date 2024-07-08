import { Link } from '@/components/Link'
import { EmptyTableBody, Section, Stack, Text, Table, Th, Td } from '@/components/ui'
import { path } from '@/constants/path'
import { Module, SpecificModule } from '@/models/module'
import { FC, useMemo } from 'react'
import { StickyThead } from '../StickyThead'
import { stringify } from '@/utils/queryString'
import { Params } from '../../hooks/useModuleParams'

type Props = {
  pathModule: Module
  tab: Params['tab']
  sources: SpecificModule['sources']
  moduleDependencies: SpecificModule['moduleDependencies']
}

export const ModuleDependenciesContent: FC<Props> = ({ pathModule, tab, sources, moduleDependencies }) => {
  const dependenciesMap = useMemo(() => {
    const map = new Map<string, Set<string>>()

    sources.forEach((source) => {
      source.dependencies.forEach((dependency) => {
        if (dependency.module) {
          if (!map.has(dependency.module)) {
            map.set(dependency.module, new Set<string>())
          }

          const set = map.get(dependency.module)!
          set.add(dependency.sourceName)
        }
      })
    })

    return map
  }, [sources, moduleDependencies])

  const pathToModule = (params: Params) => {
    return `${path.modules.show(pathModule)}?${stringify(params)}`
  }

  return (
    <Section>
      <Stack gap={0.5}>
        <div style={{ overflow: 'clip' }}>
          <Table fixedHead>
            <StickyThead>
              <tr>
                <Th>Module</Th>
                <Th>Sources Count</Th>
              </tr>
            </StickyThead>
            {moduleDependencies.length === 0 ? (
              <EmptyTableBody>
                <Text>No module dependencies</Text>
              </EmptyTableBody>
            ) : (
              <tbody>
                {moduleDependencies.map((module) => (
                  <tr key={module}>
                    <Td>
                      <Text as="div" whiteSpace="nowrap">
                        <Link to={path.modules.show(module)}>{module}</Link>
                      </Text>
                    </Td>
                    <Td>
                      <Text as="div" whiteSpace="nowrap">
                        <Link reloadDocument to={pathToModule({ tab, filteredModule: module })}>
                          {dependenciesMap.get(module)?.size ?? 0}
                        </Link>
                      </Text>
                    </Td>
                  </tr>
                ))}
              </tbody>
            )}
          </Table>
        </div>
      </Stack>
    </Section>
  )
}
