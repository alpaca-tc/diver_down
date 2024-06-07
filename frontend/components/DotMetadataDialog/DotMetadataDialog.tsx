import { ComponentProps, FC, useContext, useMemo, useState } from 'react'
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

import { SourceModulesComboBox } from '@/components/SourceModulesComboBox'
import { RecentModulesContext } from '@/context/RecentModulesContext'
import { SourceMemoInput } from '@/components/SourceMemoInput'

export type DotMetadataDialogProps = {
  dotMetadata: DotMetadata
  top: number
  left: number
}

type Props = {
  dotMetadata: DotMetadata | null
  onClose: () => void
  mutateCombinedDefinition: () => void
  top: number
  left: number
}

const SourceDotMetadataContent: FC<{ dotMetadata: DotSourceMetadata } & Pick<Props, 'mutateCombinedDefinition'>> = ({
  dotMetadata,
  mutateCombinedDefinition,
}) => {
  const { setRecentModules } = useContext(RecentModulesContext)
  const [editingModules, setEditingModules] = useState<boolean>(false)
  const [editingMemo, setEditingMemo] = useState<boolean>(false)
  const items: ComponentProps<typeof DefinitionList>['items'] = [
    {
      term: 'Source Name',
      description: <Link to={path.sources.show(dotMetadata.sourceName)}>{dotMetadata.sourceName}</Link>,
    },
    {
      term: 'Memo',
      description: (
        <Cluster>
          {editingMemo ? (
            <SourceMemoInput
              sourceName={dotMetadata.sourceName}
              initialMemo={dotMetadata.memo}
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
              <Text>{dotMetadata.memo}</Text>
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
              sourceName={dotMetadata.sourceName}
              initialModules={dotMetadata.modules}
              onUpdate={(modules) => {
                setRecentModules(modules)
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
    },
  ]

  return <DefinitionList maxColumns={1} items={items} />
}

const DependencyDotMetadataContent: FC<{ dotMetadata: DotDependencyMetadata }> = ({ dotMetadata }) => (
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
          {dotMetadata.dependencies.map((dependency) =>
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

const ModuleDotMetadataContent: FC<{ dotMetadata: DotModuleMetadata }> = ({ dotMetadata }) => {
  const items: ComponentProps<typeof DefinitionList>['items'] = [
    {
      term: 'Module Name',
      description: (
        <Link to={path.modules.show(dotMetadata.modules.map((module) => module.moduleName))}>
          {dotMetadata.modules.map((module) => module.moduleName).join(' / ')}
        </Link>
      ),
    },
  ]

  return <DefinitionList items={items} />
}

export const DotMetadataDialog: FC<Props> = ({ dotMetadata, onClose, top, left, mutateCombinedDefinition }) => {
  const content = useMemo(() => {
    switch (dotMetadata?.type) {
      case 'source': {
        return <SourceDotMetadataContent dotMetadata={dotMetadata} mutateCombinedDefinition={mutateCombinedDefinition} />
      }
      case 'dependency': {
        return <DependencyDotMetadataContent dotMetadata={dotMetadata} />
      }
      case 'module': {
        return <ModuleDotMetadataContent dotMetadata={dotMetadata} />
      }
    }
  }, [dotMetadata, mutateCombinedDefinition])

  return (
    <ModelessDialog
      isOpen={!!dotMetadata}
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
