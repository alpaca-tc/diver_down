import { Link } from '@/components/Link'
import { EmptyTableBody, Section, Stack, Text, Table, Th, Td, Select } from '@/components/ui'
import { path } from '@/constants/path'
import { DependencyType, Module, SpecificModule } from '@/models/module'
import { FC, useMemo } from 'react'
import { StickyThead } from '../StickyThead'
import { stringify } from '@/utils/queryString'
import { Params } from '../../hooks/useModuleParams'
import { ModuleDependencyTypeSelect } from '../ModuleDependencyTypeSelect'

type Props = {
  mutate: () => void
  pathModule: Module
  sources: SpecificModule['sources']
  moduleDependencies: SpecificModule['moduleDependencies']
}

export const ModuleDependenciesContent: FC<Props> = ({ pathModule, sources, moduleDependencies, mutate }) => {
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
  }, [sources])

  const dependencyTypeMap = useMemo(() => {
    const map = new Map<string, Set<DependencyType>>()

    sources.forEach((source) => {
      source.dependencies.forEach((dependency) => {
        const module = dependency.module

        if (module) {
          if (!map.has(module)) {
            map.set(module, new Set<DependencyType>())
          }

          const set = map.get(module)!

          if (dependency.dependencyType) {
            set.add(dependency.dependencyType)
          }
        }
      })
    })

    return map
  }, [sources])

  const selectedDependentTypeCount = useMemo(() => {
    let count = 0

    moduleDependencies.forEach((moduleDependency) => {
      if (dependencyTypeMap.has(moduleDependency) && dependencyTypeMap.get(moduleDependency)!.size > 0) {
        count++
      }
    })

    return count
  }, [dependencyTypeMap, moduleDependencies])

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
                <Th>
                  Dependency Type(
                  {selectedDependentTypeCount === moduleDependencies.length
                    ? moduleDependencies.length
                    : `${selectedDependentTypeCount}/${moduleDependencies.length}`}
                  )
                </Th>
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
                        <Link reloadDocument to={pathToModule({ tab: 'sources', filteredModule: module })}>
                          {dependenciesMap.get(module)?.size ?? 0}
                        </Link>
                      </Text>
                    </Td>
                    <Td>
                      <ModuleDependencyTypeSelect
                        onUpdated={mutate}
                        fromModule={pathModule}
                        toModule={module}
                        dependencyTypes={dependencyTypeMap.get(module)}
                      />
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
