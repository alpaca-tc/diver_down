import { FC } from 'react'
import styled from 'styled-components'

import { Link } from '@/components/Link'
import { Loading } from '@/components/Loading'
import { Cluster, EmptyTableBody, Heading, Section, Stack, Table, Td, Text, Th } from '@/components/ui'
import { path } from '@/constants/path'
import { spacing } from '@/constants/theme'
import { Module } from '@/models/module'
import { useModules } from '@/repositories/moduleRepository'

const ModuleRow: FC<{ modules: Module[] }> = ({ modules }) => (
  <Cluster>
    {modules.map((module, index) => {
      const current = modules.slice(0, index + 1)
      const moduleNames: string[] = current.map((mod) => mod.moduleName)

      return (
        <Text key={index}>
          {index > 0 && ' / '}
          <Link to={path.modules.show(moduleNames)}>{module.moduleName}</Link>
        </Text>
      )
    })}
  </Cluster>
)

export const List: FC = () => {
  const { data, isLoading } = useModules()

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
            {data && data.length > 0 ? (
              <tbody>
                {data.map((modules, index) => (
                  <tr key={index}>
                    <Td>
                      <ModuleRow modules={modules} />
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
