import { FC } from "react"
import styled from "styled-components"

import { Link } from "@/components/Link"
import { Aside, EmptyTableBody, Table, Td, Text, Th } from "@/components/ui"
import { CombinedDefinition } from "@/models/combinedDefinition"

type Props = {
  combinedDefinition: CombinedDefinition
}

export const DefinitionSources: FC<Props> = ({ combinedDefinition }) => (
  <WrapperAside>
    <div style={{ overflow: 'clip' }}>
      <Table fixedHead>
        <thead>
          <tr>
            <Th>
              Source name
            </Th>
          </tr>
        </thead>
        {combinedDefinition.sources.length === 0 ? (
          <EmptyTableBody>
            <Text>お探しの条件に該当する項目はありません。</Text>
            <Text>別の条件をお試しください。</Text>
          </EmptyTableBody>
        ) : (
          <tbody>
            {combinedDefinition.sources.map((source) => (
              <tr key={source.sourceName}>
                <Td>
                  <Link to={`/sources/${source.sourceName}`}>
                  {source.sourceName}
                  </Link>
                </Td>
              </tr>
            ))}
          </tbody>
        )}
      </Table>
    </div>
  </WrapperAside>
)

const WrapperAside = styled(Aside)`
  list-style: none;
  padding: 0;
  height: inherit;
  overflow-y: scroll;

  &&& {
    margin-top: 0;
  }

  > li {
    margin-top: 2rem;
    padding: 0 2rem;
  }
`
