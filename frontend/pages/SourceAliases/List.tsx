import { FC, useCallback, useEffect, useMemo, useState } from 'react'
import styled from 'styled-components'

import { Loading } from '@/components/Loading'
import {
  ActionDialog,
  Button,
  Cluster,
  ComboBoxItem,
  EmptyTableBody,
  FormControl,
  Heading,
  Input,
  Section,
  MultiComboBox,
  Stack,
  Table,
  Td,
  Text,
  Th,
  SingleComboBox,
} from '@/components/ui'
import { path } from '@/constants/path'
import { spacing } from '@/constants/theme'
import { useSourceAliases, useUpdateSourceAlias } from '@/repositories/sourceAliasRepository'
import { SourceAlias } from '@/models/sourceAlias'
import { useSources } from '@/repositories/sourceRepository'
import { Source } from '@/models/source'
import { Link } from '@/components/Link'

type SourceAliasDialogProps = {
  isOpen: boolean
  onClickClose: () => void
  initialAliasName: string
  initialSourceNames: string[]
}

type Item = ComboBoxItem<Source>

const convertSourceToItem = (source: Source): Item => ({
  label: source.sourceName,
  value: source.sourceName,
  data: source,
})

const SourceAliasDialog: React.FC<SourceAliasDialogProps> = ({ isOpen, onClickClose, initialAliasName, initialSourceNames }) => {
  const { data: sources, isLoading } = useSources()
  const { trigger } = useUpdateSourceAlias()
  const isNew = useMemo(() => initialAliasName === '', [initialAliasName])

  const [selectedAlias, setSelectedAlias] = useState<Item | null>(null)
  const [selectedSources, setSelectedSources] = useState<Item[]>([])
  const [errors, setErrors] = useState<string[]>([])

  const items: Item[] = useMemo(() => (sources?.sources ?? []).map((source) => convertSourceToItem(source)), [sources])

  useEffect(() => {
    setSelectedAlias(items.find((item) => item.value === initialAliasName) ?? null)
    setSelectedSources(items.filter((item) => initialSourceNames.includes(item.data?.sourceName ?? '')))
    setErrors([])
  }, [items, initialSourceNames, initialAliasName])

  const handleDialogClose = useCallback(() => {
    onClickClose()
  }, [onClickClose])

  const handleSubmit = useCallback(async () => {
    const errorMessages: string[] = []

    if (!selectedAlias) {
      errorMessages.push('Alias Name is required.')
    }

    if (selectedSources.length === 0) {
      errorMessages.push('Source Names are required.')
    }

    if (errorMessages.length > 0) {
      setErrors(errorMessages)
      return
    }

    const data = {
      aliasName: selectedAlias?.value ?? '',
      sourceNames: selectedSources.map((item) => item.value),
      oldAliasName: initialAliasName,
    }

    await trigger(data, {
      onSuccess() {
        handleDialogClose()
      },
      onError(error: any) {
        setErrors([error.data.message])
      },
    })
  }, [initialAliasName, trigger, setErrors, handleDialogClose, selectedAlias, selectedSources])

  // For Alias
  const handleSelectAlias = useCallback(
    (item: Item) => {
      setSelectedAlias(item)
    },
    [setSelectedAlias],
  )

  const handleClearAlias = useCallback(() => {
    setSelectedAlias(null)
  }, [setSelectedAlias])

  // for Source Names
  const handleSelectSource = useCallback(
    (item: Item) => {
      setSelectedSources((prev) => [...new Set([item, ...prev])])
    },
    [setSelectedSources],
  )

  const handleDeleteSource = useCallback(
    (item: Item) => {
      setSelectedSources((prev) => prev.filter((i) => i !== item))
    },
    [setSelectedSources],
  )

  return (
    <ActionDialog
      title={isNew ? 'New Source Alias' : `Edit Source Alias (${initialAliasName})`}
      decorators={{ closeButtonLabel: () => 'Close' }}
      actionText={isNew ? 'Save' : 'Update'}
      actionTheme="primary"
      isOpen={isOpen}
      onClickAction={handleSubmit}
      onClickClose={handleDialogClose}
      onClickOverlay={handleDialogClose}
      width={'500px'}
    >
      <WrapperSection>
        <Stack gap={1.5}>
          <Stack gap={1.5}>
            <p>
              Multiple sources can be combined as a single source. Use this when you have multiple sources with nearly identical
              behavior.
            </p>

            <Stack gap={1.5}>
              <FormControl title="Alias Name" helpMessage="Combine source names as this source name.">
                <SingleComboBox
                  required
                  items={items}
                  selectedItem={selectedAlias}
                  dropdownHelpMessage="Select or input Module"
                  isLoading={isLoading}
                  onSelect={handleSelectAlias}
                  onClear={handleClearAlias}
                  width="100%"
                  decorators={{
                    noResultText: () => `no result.`,
                    destroyButtonIconAlt: (text) => `destroy.(${text})`,
                  }}
                />
              </FormControl>

              <FormControl title="Source Names" helpMessage="List of source names to be combined." errorMessages={errors}>
                <MultiComboBox
                  required
                  items={items}
                  selectedItems={selectedSources}
                  dropdownHelpMessage="Select or input Module"
                  isLoading={isLoading}
                  onSelect={handleSelectSource}
                  onDelete={handleDeleteSource}
                  width="100%"
                  decorators={{
                    noResultText: () => `no result.`,
                    destroyButtonIconAlt: (text) => `destroy.(${text})`,
                  }}
                />
              </FormControl>
            </Stack>
          </Stack>
        </Stack>
      </WrapperSection>
    </ActionDialog>
  )
}

const WrapperSection = styled(Section)`
  padding: ${spacing.XS};
`

type SourceAliasRowProps = {
  sourceAlias: SourceAlias
  setOpenedDialog: React.Dispatch<React.SetStateAction<OpenedDialogProps | null>>
}

const SourceAliasRow: FC<SourceAliasRowProps> = ({ sourceAlias, setOpenedDialog }) => {
  const handleClickEdit = useCallback(() => {
    setOpenedDialog({
      aliasName: sourceAlias.aliasName,
      sourceNames: sourceAlias.sourceNames,
    })
  }, [sourceAlias, setOpenedDialog])

  return (
    <tr>
      <Td>
        <Stack>
          <Link to={path.sources.show(sourceAlias.aliasName)}>{sourceAlias.aliasName}</Link>
        </Stack>
      </Td>
      <Td>
        <Stack>
          {sourceAlias.sourceNames.map((sourceName) => (
            <Link to={path.sources.show(sourceName)} key={sourceName}>
              {sourceName}
            </Link>
          ))}
        </Stack>
      </Td>
      <Td>
        <Button onClick={handleClickEdit}>Edit</Button>
      </Td>
    </tr>
  )
}

type OpenedDialogProps = {
  aliasName: string | null
  sourceNames: string[]
}

export const List: FC = () => {
  const { data, isLoading } = useSourceAliases()
  const [openedDialog, setOpenedDialog] = useState<OpenedDialogProps | null>(null)

  return (
    <StyledSection>
      <Stack>
        <Cluster>
          <Heading type="screenTitle">Source Aliases</Heading>
          <Button onClick={() => setOpenedDialog({ aliasName: null, sourceNames: [] })}>New</Button>
        </Cluster>

        <SourceAliasDialog
          isOpen={!!openedDialog}
          onClickClose={() => setOpenedDialog(null)}
          initialAliasName={openedDialog?.aliasName ?? ''}
          initialSourceNames={openedDialog?.sourceNames ?? []}
        />

        <div style={{ overflow: 'clip' }}>
          <Table fixedHead>
            <thead>
              <tr>
                <Th>Alias Name</Th>
                <Th>Source Names</Th>
                <Th></Th>
              </tr>
            </thead>
            {data && data.length > 0 ? (
              <tbody>
                {data.map((sourceAlias) => (
                  <SourceAliasRow key={sourceAlias.aliasName} sourceAlias={sourceAlias} setOpenedDialog={setOpenedDialog} />
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
