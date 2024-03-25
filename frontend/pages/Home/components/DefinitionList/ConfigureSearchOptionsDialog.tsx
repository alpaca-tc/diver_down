import React, { useState } from 'react'

import { ActionDialog, Stack } from '@/components/ui'

export type SearchDefinitionsOptions = {
  query: string
  folding: boolean
}

type Props = {
  isOpen: boolean
  onClickClose: () => void
  searchDefinitionsOptions: SearchDefinitionsOptions
  setSearchDefinitionsOptions: React.Dispatch<React.SetStateAction<SearchDefinitionsOptions>>
}

export const ConfigureSearchOptionsDialog: React.FC<Props> = ({ isOpen, onClickClose, searchDefinitionsOptions, setSearchDefinitionsOptions }) => {
  const [temporarySearchDefinitionsOptions, setTemporarySearchDefinitionsOptions] = useState<SearchDefinitionsOptions>(searchDefinitionsOptions)

  const handleDialogClose = () => {
    onClickClose()

    // reset
    setTemporarySearchDefinitionsOptions(searchDefinitionsOptions)
  }

  const handleSubmit = () => {
    setSearchDefinitionsOptions(temporarySearchDefinitionsOptions)
    onClickClose()
  }

  // const onInputFilteringText = useCallback((event: React.ChangeEvent<HTMLInputElement>) => {
  //   setFilteringInputText(event.target.value)
  // }, [setFilteringInputText])
  //
  // const onSubmitFiltering = useCallback(() => {
  //   setFilteringQuery(filteringInputText)
  // }, [filteringInputText, setFilteringQuery])

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
    >
      <Stack gap={1.5}>
        <h1>hello</h1>
      </Stack>
    </ActionDialog>
  )
}
