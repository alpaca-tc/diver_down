import React, { useCallback, useState } from 'react'
import styled from 'styled-components'

import { ActionDialog, CheckBox, FormControl, Input, Section, Stack } from '@/components/ui'
import { spacing } from '@/constants/theme'

export type SearchDefinitionsOptions = {
  title: string
  source: string
  folding: boolean
}

type Props = {
  isOpen: boolean
  onClickClose: () => void
  searchDefinitionsOptions: SearchDefinitionsOptions
  setSearchDefinitionsOptions: React.Dispatch<React.SetStateAction<SearchDefinitionsOptions>>
}

export const ConfigureSearchOptionsDialog: React.FC<Props> = ({
  isOpen,
  onClickClose,
  searchDefinitionsOptions,
  setSearchDefinitionsOptions,
}) => {
  const [temporarySearchDefinitionsOptions, setTemporarySearchDefinitionsOptions] =
    useState<SearchDefinitionsOptions>(searchDefinitionsOptions)

  const handleDialogClose = () => {
    onClickClose()

    // reset
    setTemporarySearchDefinitionsOptions(searchDefinitionsOptions)
  }

  const handleSubmit = () => {
    setSearchDefinitionsOptions(temporarySearchDefinitionsOptions)
    onClickClose()
  }

  const onChangeTitle = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => {
      setTemporarySearchDefinitionsOptions((prev) => ({ ...prev, title: event.target.value }))
    },
    [setTemporarySearchDefinitionsOptions],
  )

  const onChangeSource = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => {
      setTemporarySearchDefinitionsOptions((prev) => ({ ...prev, source: event.target.value }))
    },
    [setTemporarySearchDefinitionsOptions],
  )

  const onChangeFolding = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => {
      setTemporarySearchDefinitionsOptions((prev) => ({ ...prev, folding: event.target.checked }))
    },
    [setTemporarySearchDefinitionsOptions],
  )

  return (
    <ActionDialog
      title="Configure Search Options"
      decorators={{ closeButtonLabel: () => 'Close' }}
      actionText="Save"
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
            <p>Configure settings related to the display of definitions.</p>

            <Stack gap={1.5}>
              <FormControl title="Filtering title" helpMessage="Refine the definition with a title">
                <Input name="title" type="text" onChange={onChangeTitle} value={temporarySearchDefinitionsOptions.title} />
              </FormControl>

              <FormControl title="Filtering source" helpMessage="Refine the definition with a source">
                <Input name="source" type="text" onChange={onChangeSource} value={temporarySearchDefinitionsOptions.source} />
              </FormControl>

              <FormControl title="Fold Definitions" helpMessage="Folding the same definition_group">
                <CheckBox name="folding" onChange={onChangeFolding} checked={temporarySearchDefinitionsOptions.folding} />
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
