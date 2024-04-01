import { FC } from 'react'
import styled from 'styled-components'

import { Heading, LineClamp, Section, Stack, Table, Td, Th } from '@/components/ui'
import { spacing } from '@/constants/theme'
import { useLicenses } from '@/repositories/licenseRepository'

export const List: FC = () => {
  const licenses = useLicenses()

  return (
    <StyledSection>
      <Stack>
        <Heading type="screenTitle">License</Heading>

        <div style={{ overflow: 'clip' }}>
          <Table fixedHead>
            <thead>
              <tr>
                <Th>Name</Th>
                <Th>Lincenses</Th>
                <Th>Repository</Th>
                <Th>Copyright</Th>
                <Th>Lincense Text</Th>
              </tr>
            </thead>
            <tbody>
              {licenses.map((license) => (
                <tr key={license.name}>
                  <Td>{license.name}</Td>
                  <Td>{license.licenses}</Td>
                  <Td>{license.repository}</Td>
                  <Td>{license.copyright}</Td>
                  <Td>
                    <LineClamp maxLines={2}>{license.licenseText}</LineClamp>
                  </Td>
                </tr>
              ))}
            </tbody>
          </Table>
        </div>
      </Stack>
    </StyledSection>
  )
}

const StyledSection = styled(Section)`
  padding: ${spacing.XS};
`
