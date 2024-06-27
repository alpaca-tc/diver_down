import React, { useMemo } from 'react'
import { useParams } from 'react-router-dom'
import styled from 'styled-components'

import { Link } from '@/components/Link'
import { Loading } from '@/components/Loading'
import { Cluster, EmptyTableBody, Heading, Section, Stack, Table, Td, Text, Th } from '@/components/ui'
import { path } from '@/constants/path'
import { spacing } from '@/constants/theme'
import { KEY } from '@/hooks/useBitIdHash'
import { useModule } from '@/repositories/moduleRepository'
import { encode, idsToBitId } from '@/utils/bitId'
import { stringify } from '@/utils/queryString'

export const Show: React.FC = () => {
  const pathModule = useParams()['*'] ?? ''
  const { data: specificModule, isLoading } = useModule(pathModule)

  const relatedDefinitionIds = useMemo(() => {
    if (specificModule) {
      return specificModule.relatedDefinitions.map(({ id }) => id)
    } else {
      return []
    }
  }, [specificModule])

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

            {specificModule && !isLoading ? (
              <>
                <Section>
                  <Stack gap={0.5}>
                    <Heading type="sectionTitle">Sources</Heading>
                    <div style={{ overflow: 'clip' }}>
                      <Table fixedHead>
                        <thead>
                          <tr>
                            <Th>Source Name</Th>
                            <Th>Memo</Th>
                          </tr>
                        </thead>
                        {specificModule.sources.length === 0 ? (
                          <EmptyTableBody>
                            <Text>no sources</Text>
                          </EmptyTableBody>
                        ) : (
                          <tbody>
                            {specificModule.sources.map((source) => (
                              <tr key={source.sourceName}>
                                <Td>
                                  <Link to={path.sources.show(source.sourceName)}>{source.sourceName}</Link>
                                </Td>
                                <Td>
                                  <Text>{source.memo}</Text>
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
                        {specificModule.relatedDefinitions.length === 0 ? (
                          <EmptyTableBody>
                            <Text>no related definitions</Text>
                          </EmptyTableBody>
                        ) : (
                          <tbody>
                            {specificModule.relatedDefinitions.map((relatedDefinition) => (
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
