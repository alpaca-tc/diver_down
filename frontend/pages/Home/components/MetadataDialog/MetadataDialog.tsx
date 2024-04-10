import { ComponentProps, FC, useState } from 'react'
import styled from 'styled-components'

import { Link } from '@/components/Link'
import { Button, Cluster, DefinitionList, FaPencilIcon, Heading, ModelessDialog, Stack } from '@/components/ui'
import { path } from '@/constants/path'
import { spacing } from '@/constants/theme'
import { DotMetadata } from '@/models/combinedDefinition'

import { SourceModulesComboBox } from '../SourceModulesComboBox'
import { DialogProps } from '../dialog'

type Props = {
  dotMetadata: DotMetadata | null
  isOpen: boolean
  onClose: () => void
  setVisibleDialog: React.Dispatch<React.SetStateAction<DialogProps | null>>
  mutateCombinedDefinition: () => void
  top: number
  left: number
}

export const MetadataDialog: FC<Props> = ({ dotMetadata, isOpen, onClose, top, left, mutateCombinedDefinition }) => {
  const [editingModules, setEditingModules] = useState<boolean>(false)
  const items: ComponentProps<typeof DefinitionList>['items'] = []

  switch (dotMetadata?.type) {
    case 'source': {
      items.push({
        term: 'Source Name',
        description: <Link to={path.sources.show(dotMetadata.sourceName)}>{dotMetadata.sourceName}</Link>,
      })

      items.push({
        term: 'Modules',
        description: (
          <Cluster>
            {editingModules ? (
              <SourceModulesComboBox
                sourceName={dotMetadata.sourceName}
                initialModules={dotMetadata.modules}
                onUpdate={() => {
                  setEditingModules(false)
                  mutateCombinedDefinition()
                }}
                onClose={() => {
                  setEditingModules(false)
                }}
              />
            ) : (
              <>
                <div>
                  {dotMetadata.modules.map((module) => (
                    <p key={module.moduleName}>{module.moduleName}</p>
                  ))}
                </div>
                <Button
                  square={true}
                  onClick={() => {
                    setEditingModules(true)
                  }}
                  size="s"
                >
                  <FaPencilIcon alt="編集" />
                </Button>
              </>
            )}
          </Cluster>
        ),
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
        description: (
          <Link to={path.modules.show(dotMetadata.modules.map((module) => module.moduleName))}>
            {dotMetadata.modules.map((module) => module.moduleName).join(' / ')}
          </Link>
        ),
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
