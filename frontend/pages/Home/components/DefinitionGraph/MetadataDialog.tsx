import { ComponentProps, FC } from 'react'
import styled from 'styled-components'

import { Link } from '@/components/Link'
import { DefinitionList, Heading, ModelessDialog, Stack } from '@/components/ui'
import { path } from '@/constants/path'
import { spacing } from '@/constants/theme'
import { DotMetadata } from '@/models/combinedDefinition'

type Props = {
  dotMetadata: DotMetadata | null
  isOpen: boolean
  onClose: () => void
  top: number
  left: number
}

export const MetadataDialog: FC<Props> = ({ dotMetadata, isOpen, onClose, top, left }) => {
  const items: ComponentProps<typeof DefinitionList>['items'] = []

  switch (dotMetadata?.type) {
    case 'source': {
      items.push({
        term: 'Source Name',
        description: <Link to={path.sources.show(dotMetadata.sourceName)}>{dotMetadata.sourceName}</Link>,
      })
      break
    }
    case 'dependency': {
      items.push({
        term: 'Dependency Name',
        description: <Link to={path.sources.show(dotMetadata.sourceName)}>{dotMetadata.sourceName}</Link>,
      })
      items.push({
        term: 'Method ID',
        description: dotMetadata.methodIds.map((methodId) => (
          <p key={`${methodId.context}-${methodId.name}`}>{methodId.human}</p>
        )),
      })
      break
    }
    case 'module': {
      items.push({
        term: 'Module Name',
        description: <Link to={path.modules.show(dotMetadata.moduleName)}>{dotMetadata.moduleName}</Link>,
      })
      break
    }
  }

  return (
    <ModelessDialog
      isOpen={!!(isOpen && dotMetadata)}
      header={<ModelessHeading>Description</ModelessHeading>}
      onClickClose={onClose}
      onPressEscape={onClose}
      top={top}
      left={left}
    >
      <Wrapper>
        <Stack gap={0.5} as="section">
          <DefinitionList items={items} />
        </Stack>
      </Wrapper>
    </ModelessDialog>
  )
}

const ModelessHeading = styled(Heading)`
  font-size: 1em;
  margin: 0;
  font-weight: normal;
`

const Wrapper = styled.div`
  padding: ${spacing.XS};
`
