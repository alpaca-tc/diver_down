import React, { useCallback, useState } from 'react'
import styled from 'styled-components'

import { ActionDialog, CheckBox, FormControl, Section, Stack } from '@/components/ui'
import { spacing } from '@/constants/theme'

export type GraphOptions = {
  compound: boolean
  concentrate: boolean
}

type Props = {
  isOpen: boolean
  onClickClose: () => void
  graphOptions: GraphOptions
  setGraphOptions: React.Dispatch<React.SetStateAction<GraphOptions>>
}

export const ConfigureViewOptionsDialog: React.FC<Props> = ({
  isOpen,
  onClickClose,
  graphOptions,
  setGraphOptions,
}) => {
  const [temporaryViewOptions, setTemporaryViewOptions] =
    useState<GraphOptions>(graphOptions)

  const handleDialogClose = () => {
    onClickClose()

    // reset
    setTemporaryViewOptions(graphOptions)
  }

  const handleSubmit = () => {
    setGraphOptions(temporaryViewOptions)
    onClickClose()
  }

  const onChangeCompound = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => {
      setTemporaryViewOptions((prev) => ({ ...prev, compound: event.target.checked }))
    },
    [setTemporaryViewOptions],
  )

  const onChangeConcentrate = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => {
      setTemporaryViewOptions((prev) => ({ ...prev, concentrate: event.target.checked }))
    },
    [setTemporaryViewOptions],
  )

  return (
    <ActionDialog
      title="Configure Graph Options"
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
            <p>Configure graph settings.</p>

            <Stack gap={1.5}>
              <FormControl title="Clip the boundary" helpMessage="Clip the boundary of the module.">
                <CheckBox name="compound" onChange={onChangeCompound} checked={temporaryViewOptions.compound} />
              </FormControl>

              <FormControl title="Use edge concentrators" helpMessage="This merges multiedges into a single edge and causes partially parallel edges to share part of their paths.">
                <CheckBox name="compound" onChange={onChangeConcentrate} checked={temporaryViewOptions.concentrate} />
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
