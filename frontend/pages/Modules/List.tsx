import { FC } from 'react'
import styled from 'styled-components'

import { Link } from '@/components/Link'
import { Loading } from '@/components/Loading'
import { EmptyTableBody, Heading, Section, Stack, Table, Td, Text, Th } from '@/components/ui'
import { path } from '@/constants/path'
import { spacing } from '@/constants/theme'
import { useModules } from '@/repositories/moduleRepository'

export const List: FC = () => {
  const { data, isLoading } = useModules()

  return (
    <StyledSection>
      <Stack>
        <Heading type="screenTitle">Modules</Heading>

        <div style={{ overflow: 'clip' }}>
          <Table fixedHead>
            <thead>
              <tr>
                <Th>Source name</Th>
              </tr>
            </thead>
            {data && data.length > 0 ? (
              <tbody>
                {data.map((module, index) => (
                  <tr key={index}>
                    <Td>
                      <Text>
                        <Link to={path.modules.show(module)}>{module}</Link>
                      </Text>
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
