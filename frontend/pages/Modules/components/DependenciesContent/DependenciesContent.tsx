import { Link } from '@/components/Link'
import { EmptyTableBody, Section, Stack, Text, Table, Th, Td } from '@/components/ui'
import { path } from '@/constants/path'
import { SpecificModule } from '@/models/module'
import { FC } from 'react'
import { StickyThead } from '../StickyThead'

export const DependenciesContent: FC<{ moduleDependencies: SpecificModule['moduleDependencies'] }> = ({ moduleDependencies }) => {
  return (
    <Section>
      <Stack gap={0.5}>
        <div style={{ overflow: 'clip' }}>
          <Table fixedHead>
            <StickyThead>
              <tr>
                <Th>Module</Th>
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
