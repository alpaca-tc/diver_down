import { Link } from '@/components/Link'
import { EmptyTableBody, Heading, Section, Stack, Text, Table, Th, Td } from '@/components/ui'
import { path } from '@/constants/path'
import { SpecificModule } from '@/models/module'
import { FC } from 'react'

export const ReverseDependenciesContent: FC<{
  modules: SpecificModule['moduleReverseDependencies']
  sources: SpecificModule['sourceReverseDependencies']
}> = ({ modules, sources }) => {
  return (
    <Stack>
      <Section>
        <Stack gap={0.5}>
          <Heading type="sectionTitle">Modules ({modules.length})</Heading>
          <div style={{ overflow: 'clip' }}>
            <Table fixedHead>
              <thead>
                <tr>
                  <Th>Module</Th>
                </tr>
              </thead>
              {modules.length === 0 ? (
                <EmptyTableBody>
                  <Text>No module reverse dependencies</Text>
                </EmptyTableBody>
              ) : (
                <tbody>
                  {modules.map((module) => (
                    <tr key={module}>
                      <Td>
                        <Text as="div" whiteSpace="nowrap">
                          <Link to={path.modules.show(module)}>{module}</Link>
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

      <Section>
        <Stack gap={0.5}>
          <Heading type="sectionTitle">Sources ({sources.length})</Heading>
          <div style={{ overflow: 'clip' }}>
            <Table fixedHead>
              <thead>
                <tr>
                  <Th>Source</Th>
                  <Th>Dependency Module</Th>
                  <Th>Dependency</Th>
                  <Th>Method Id</Th>
                  <Th>Path</Th>
                </tr>
              </thead>
              {sources.length === 0 ? (
                <EmptyTableBody>
                  <Text>No sources</Text>
                </EmptyTableBody>
              ) : (
                <tbody>
                  {sources.map((source) =>
                    source.dependencies.map((dependency) =>
                      dependency.methodIds.map((methodId) => (
                        <tr key={`${source.sourceName}-${dependency.sourceName}-${methodId.context}-${methodId.name}`}>
                          <Td>
                            <Text as="div" whiteSpace="nowrap">
                              <Link to={path.sources.show(source.sourceName)}>{source.sourceName}</Link>
                            </Text>
                          </Td>
                          <Td>
                            {dependency.module && (
                              <Text as="div" whiteSpace="nowrap">
                                <Link to={path.modules.show(dependency.module)}>{dependency.module}</Link>
                              </Text>
                            )}
                          </Td>
                          <Td>
                            <Text as="div" whiteSpace="nowrap">
                              <Link to={path.sources.show(dependency.sourceName)}>{dependency.sourceName}</Link>
                            </Text>
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
                    ),
                  )}
                </tbody>
              )}
            </Table>
          </div>
        </Stack>
      </Section>
    </Stack>
  )
}
