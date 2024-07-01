import React from 'react'
import { useParams } from 'react-router-dom'
import styled from 'styled-components'

import { Link } from '@/components/Link'
import { Loading } from '@/components/Loading'
import { Cluster, EmptyTableBody, Heading, Section, Stack, Table, Td, Text, Th } from '@/components/ui'
import { path } from '@/constants/path'
import { spacing } from '@/constants/theme'
import { useModule } from '@/repositories/moduleRepository'

export const Show: React.FC = () => {
  const pathModule = useParams()['*'] ?? ''
  const { data, isLoading } = useModule(pathModule)

  return (
    <StyledSection>
      <Stack>
        <Heading type="screenTitle">
          <Cluster>
            <Link to={path.modules.index()}>Module List</Link>
            &gt;
            <Link to={path.modules.show(pathModule)}>{pathModule}</Link>
          </Cluster>
        </Heading>

        <Section>
          <Stack gap={1.5}>
            <Section>
              <Stack gap={0.5}>
                <Heading type="sectionTitle">Links</Heading>
                <Link to={path.moduleDefinitions.show(pathModule)}>Graph</Link>
              </Stack>
            </Section>

            {data && !isLoading ? (
              <>
                <Section>
                  <Stack gap={0.5}>
                    <Heading type="sectionTitle">Module Dependencies ({data.moduleDependencies.length})</Heading>
                    <div style={{ overflow: 'clip' }}>
                      <Table fixedHead>
                        <thead>
                          <tr>
                            <Th>Module</Th>
                          </tr>
                        </thead>
                        {data.sources.length === 0 ? (
                          <EmptyTableBody>
                            <Text>No module dependencies</Text>
                          </EmptyTableBody>
                        ) : (
                          <tbody>
                            {data.moduleDependencies.map((module) => (
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
                    <Heading type="sectionTitle">Module Reverse Dependencies ({data.moduleReverseDependencies.length})</Heading>
                    <div style={{ overflow: 'clip' }}>
                      <Table fixedHead>
                        <thead>
                          <tr>
                            <Th>Module</Th>
                          </tr>
                        </thead>
                        {data.sources.length === 0 ? (
                          <EmptyTableBody>
                            <Text>No module reverse dependencies</Text>
                          </EmptyTableBody>
                        ) : (
                          <tbody>
                            {data.moduleReverseDependencies.map((module) => (
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
                    <Heading type="sectionTitle">Sources ({data.sources.length})</Heading>
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
                        {data.sources.length === 0 ? (
                          <EmptyTableBody>
                            <Text>No sources</Text>
                          </EmptyTableBody>
                        ) : (
                          <tbody>
                            {data.sources.map((source) =>
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

                <Section>
                  <Stack gap={0.5}>
                    <Heading type="sectionTitle">Source Reverse Dependencies ({data.sourceReverseDependencies.length})</Heading>
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
                        {data.sourceReverseDependencies.length === 0 ? (
                          <EmptyTableBody>
                            <Text>No sources</Text>
                          </EmptyTableBody>
                        ) : (
                          <tbody>
                            {data.sourceReverseDependencies.map((source) =>
                              source.dependencies.map((dependency) =>
                                dependency.methodIds.map((methodId) => (
                                  <tr key={`${source.sourceName}-${dependency.sourceName}`}>
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
              </>
            ) : (
              <Loading />
            )}
          </Stack>
        </Section>
      </Stack>
    </StyledSection>
  )
}

const StyledSection = styled(Section)`
  padding: ${spacing.XS};
`
