import { ComponentProps, FC, useMemo, useState } from 'react'
import styled from 'styled-components'

import { Link } from '@/components/Link'
import {
  Button,
  Cluster,
  DefinitionList,
  FaPencilIcon,
  Heading,
  ModelessDialog,
  Stack,
  Table,
  Text,
  Td,
  Th,
} from '@/components/ui'
import { path } from '@/constants/path'
import { spacing } from '@/constants/theme'
import { DotDependencyMetadata, DotMetadata, DotModuleMetadata, DotSourceMetadata } from '@/models/combinedDefinition'

import { SourceModulesComboBox } from '../SourceModulesComboBox'
import { DialogProps } from '../dialog'
import { SourceMemoInput } from '../SourceMemoInput'

type Props = {
  dotMetadata: DotMetadata | null
  isOpen: boolean
  onClose: () => void
  setVisibleDialog: React.Dispatch<React.SetStateAction<DialogProps | null>>
  mutateCombinedDefinition: () => void
  top: number
  left: number
}

const SourceDotMetadataContent: FC<{ metadata: DotSourceMetadata } & Pick<Props, 'mutateCombinedDefinition'>> = ({
  metadata,
  mutateCombinedDefinition,
}) => {
  const [editingModules, setEditingModules] = useState<boolean>(false)
  const [editingMemo, setEditingMemo] = useState<boolean>(false)
  const items: ComponentProps<typeof DefinitionList>['items'] = [
    {
      term: 'Source Name',
      description: <Link to={path.sources.show(metadata.sourceName)}>{metadata.sourceName}</Link>,
    },
    {
      term: 'Memo',
      description: (
        <Cluster>
          {editingMemo ? (
            <SourceMemoInput
              sourceName={metadata.sourceName}
              initialMemo={metadata.memo}
              onUpdate={() => {
                setEditingMemo(false)
                mutateCombinedDefinition()
              }}
              onClose={() => {
                setEditingMemo(false)
              }}
            />
          ) : (
            <>
              <Text>{metadata.memo}</Text>
              <Button
                square={true}
                onClick={() => {
                  setEditingMemo(true)
                }}
                size="s"
              >
                <FaPencilIcon alt="編集" />
              </Button>
            </>
          )}
        </Cluster>
      ),
    },
    {
      term: 'Modules',
      description: (
        <Cluster>
          {editingModules ? (
            <SourceModulesComboBox
              sourceName={metadata.sourceName}
              initialModules={metadata.modules}
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
                {metadata.modules.map((module) => (
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
    },
  ]

  return <DefinitionList maxColumns={1} items={items} />
}

const DependencyDotMetadataContent: FC<{ metadata: DotDependencyMetadata }> = ({ metadata }) => (
  <Stack gap={0.5}>
    <div style={{ overflow: 'clip' }}>
      <Table fixedHead>
        <thead>
          <tr>
            <Th>Source Name</Th>
            <Th>Method Id</Th>
          </tr>
        </thead>
        <tbody>
          {metadata.dependencies.map((dependency) =>
            dependency.methodIds.map((methodId, index) => (
              <tr key={`${dependency.sourceName}-${methodId.context}-${methodId.name}`}>
                <Td>
                  {index === 0 ? <Link to={`${path.sources.show(dependency.sourceName)}`}>{dependency.sourceName}</Link> : null}
                </Td>
                <Td>{`${methodId.context === 'class' ? '.' : '#'}${methodId.name}`}</Td>
              </tr>
            )),
          )}
        </tbody>
      </Table>
    </div>
  </Stack>
)

const ModuleDotMetadataContent: FC<{ metadata: DotModuleMetadata }> = ({ metadata }) => {
  const items: ComponentProps<typeof DefinitionList>['items'] = [
    {
      term: 'Module Name',
      description: (
        <Link to={path.modules.show(metadata.modules.map((module) => module.moduleName))}>
          {metadata.modules.map((module) => module.moduleName).join(' / ')}
        </Link>
      ),
    },
  ]

  return <DefinitionList items={items} />
}

export const MetadataDialog: FC<Props> = ({ dotMetadata, isOpen, onClose, top, left, mutateCombinedDefinition }) => {
  const content = useMemo(() => {
    switch (dotMetadata?.type) {
      case 'source': {
        return <SourceDotMetadataContent metadata={dotMetadata} mutateCombinedDefinition={mutateCombinedDefinition} />
      }
      case 'dependency': {
        return <DependencyDotMetadataContent metadata={dotMetadata} />
      }
      case 'module': {
        return <ModuleDotMetadataContent metadata={dotMetadata} />
      }
    }
  }, [dotMetadata, mutateCombinedDefinition])

  return (
    <ModelessDialog
      isOpen={!!(isOpen && dotMetadata)}
      header={<ModelessHeading>Memo</ModelessHeading>}
      onClickClose={onClose}
      onPressEscape={onClose}
      top={top}
      left={left}
    >
      <Wrapper>
        <ScrollableStack gap={0.5} as="section">
          {content}
        </ScrollableStack>
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
  overflow: hidden;
`

const ScrollableStack = styled(Stack)`
  overflow-y: auto;
  max-height: 350px;
`
