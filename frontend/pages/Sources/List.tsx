import { FC } from 'react'
import styled from 'styled-components'

import { Link } from '@/components/Link'
import { Loading } from '@/components/Loading'
import { EmptyTableBody, Heading, Section, Stack, Table, Td, Text, Th } from '@/components/ui'
import { spacing } from '@/constants/theme'
import { useSources } from '@/repositories/sourceRepository'

export const List: FC = () => {
  const { sources, isLoading } = useSources()

  return (
    <StyledSection>
      <Stack>
        <Heading type="screenTitle">Sources</Heading>

        <div style={{ overflow: 'clip' }}>
          <Table fixedHead>
            <thead>
              <tr>
                <Th>Source name</Th>
              </tr>
            </thead>
            {sources && sources.length > 0 ? (
              <tbody>
                {sources.map((source) => (
                  <tr key={source.sourceName}>
                    <Td>
                      <Link to={`/sources/${source.sourceName}`}>{source.sourceName}</Link>
                    </Td>
                  </tr>
                ))}
              </tbody>
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
