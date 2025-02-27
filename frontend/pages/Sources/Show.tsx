import React, { useMemo } from 'react'
import { useParams } from 'react-router-dom'
import styled from 'styled-components'

import { Link } from '@/components/Link'
import { Loading } from '@/components/Loading'
import { Cluster, EmptyTableBody, Heading, Section, Stack, Table, Td, Text, Th } from '@/components/ui'
import { path } from '@/constants/path'
import { spacing } from '@/constants/theme'
import { KEY } from '@/hooks/useBitIdHash'
import { useSource } from '@/repositories/sourceRepository'
import { encode, idsToBitId } from '@/utils/bitId'
import { stringify } from '@/utils/queryString'
import { Module } from '@/models/module'
import { toBlobSuffix } from '@/utils/toBlobSuffix'
import { useConfiguration } from '@/repositories/configurationRepository'

export const Show: React.FC = () => {
  const sourceName = useParams().sourceName ?? ''
  const { specificSource, isLoading } = useSource(sourceName)
  const { data: configuration } = useConfiguration()

  const blobPrefix = configuration?.blobPrefix ?? null

  const relatedDefinitionIds = useMemo(() => {
    if (specificSource) {
      return specificSource.relatedDefinitions.map(({ id }) => id)
    } else {
      return []
    }
  }, [specificSource])

  const reverseDependencyModules: Module[] = useMemo(() => {
    if (specificSource) {
      return specificSource.reverseDependencies
        .map(({ module }) => module)
        .filter((module) => module !== null && module !== specificSource.module) as Module[]
    } else {
      return []
    }
  }, [specificSource])

  return (
    <StyledSection>
      <Stack>
        <Heading type="screenTitle">{sourceName}</Heading>

        <Section>
          {specificSource && !isLoading ? (
            <Stack gap={1.5}>
              <Section>
                <Stack gap={0.5}>
                  <Heading type="sectionTitle">Memo</Heading>
                  <div style={{ overflow: 'clip' }}>
                    <Text>{specificSource.memo}</Text>
                  </div>
                </Stack>
              </Section>

              <Section>
                <Stack gap={0.5}>
                  <Heading type="sectionTitle">Source Alias</Heading>
                  <div style={{ overflow: 'clip' }}>
                    {specificSource.resolvedAlias ? (
                      <Link to={path.sources.show(specificSource.resolvedAlias)}>{specificSource.resolvedAlias}</Link>
                    ) : null}
                  </div>
                </Stack>
              </Section>

              <Section>
                <Stack gap={0.5}>
                  <Heading type="sectionTitle">Modules</Heading>
                  <div style={{ overflow: 'clip' }}>
                    <Table fixedHead>
                      <thead>
                        <tr>
                          <Th>Module</Th>
                        </tr>
                      </thead>
                      {specificSource.module === null ? (
                        <EmptyTableBody>
                          <Text>No module</Text>
                        </EmptyTableBody>
                      ) : (
                        <tbody>
                          {specificSource.module && (
                            <tr>
                              <Td>
                                <Link to={path.modules.show(specificSource.module)}>{specificSource.module}</Link>
                              </Td>
                            </tr>
                          )}
                        </tbody>
                      )}
                    </Table>
                  </div>
                </Stack>
              </Section>

              <Section>
                <Stack gap={0.5}>
                  <Heading type="sectionTitle">Reverse dependency Modules</Heading>
                  <div style={{ overflow: 'clip' }}>
                    <Table fixedHead>
                      <thead>
                        <tr>
                          <Th>Module</Th>
                        </tr>
                      </thead>
                      {specificSource.module === null ? (
                        <EmptyTableBody>
                          <Text>No module</Text>
                        </EmptyTableBody>
                      ) : (
                        <tbody>
                          {reverseDependencyModules.map((module, index) => (
                            <tr key={module}>
                              <Td>
                                <Text key={index} as="div" whiteSpace="nowrap">
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
                  <Cluster>
                    <Heading type="sectionTitle">Related Definitions</Heading>
                    <Link to={`${path.home()}?${stringify({ [KEY]: encode(idsToBitId(relatedDefinitionIds)) })}`}>
                      Select All
                    </Link>
                  </Cluster>
                  <div style={{ overflow: 'clip' }}>
                    <Table fixedHead>
                      <thead>
                        <tr>
                          <Th>Title</Th>
                        </tr>
                      </thead>
                      {specificSource.relatedDefinitions.length === 0 ? (
                        <EmptyTableBody>
                          <Text>no related definitions</Text>
                        </EmptyTableBody>
                      ) : (
                        <tbody>
                          {specificSource.relatedDefinitions.map((relatedDefinition) => (
                            <tr key={relatedDefinition.id}>
                              <Td>
                                <Link to={`${path.home()}?${stringify({ [KEY]: encode(idsToBitId([relatedDefinition.id])) })}`}>
                                  {relatedDefinition.title}
                                </Link>
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
                  <Heading type="sectionTitle">Reverse Dependencies</Heading>
                  <div style={{ overflow: 'clip' }}>
                    <Table fixedHead>
                      <thead>
                        <tr>
                          <Th>Module</Th>
                          <Th>Source Name</Th>
                          <Th>Method Id</Th>
                          <Th>Path</Th>
                        </tr>
                      </thead>
                      {specificSource.reverseDependencies.length === 0 ? (
                        <EmptyTableBody>
                          <Text>no related definitions</Text>
                        </EmptyTableBody>
                      ) : (
                        <tbody>
                          {specificSource.reverseDependencies.map((reverseDependency) =>
                            reverseDependency.methodIds.map((methodId, index) => (
                              <tr key={`${reverseDependency.sourceName}-${methodId.context}-${methodId.name}`}>
                                <Td>
                                  {index === 0 && reverseDependency.module ? (
                                    <Text as="div" whiteSpace="nowrap">
                                      <Link to={path.modules.show(reverseDependency.module)}>{reverseDependency.module}</Link>
                                    </Text>
                                  ) : null}
                                </Td>
                                <Td>
                                  {index === 0 ? (
                                    <Link to={`${path.sources.show(reverseDependency.sourceName)}`}>
                                      {reverseDependency.sourceName}
                                    </Link>
                                  ) : null}
                                </Td>
                                <Td>{`${methodId.context === 'class' ? '.' : '#'}${methodId.name}`}</Td>
                                <Td>
                                  {methodId.paths.map((methodIdPath) => (
                                    <div
                                      key={`${reverseDependency.sourceName}-${methodId.context}-${methodId.name}-${methodIdPath}`}
                                    >
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
                        </tbody>
                      )}
                    </Table>
                  </div>
                </Stack>
              </Section>
            </Stack>
          ) : (
            <Loading />
          )}
        </Section>
      </Stack>
    </StyledSection>
  )
}

const StyledSection = styled(Section)`
  padding: ${spacing.XS};
`
