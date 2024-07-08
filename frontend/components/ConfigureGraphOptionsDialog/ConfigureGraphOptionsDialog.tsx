import React, { useCallback, useState } from 'react'
import styled from 'styled-components'

import { ActionDialog, CheckBox, FormControl, Section, Stack } from '@/components/ui'
import { spacing } from '@/constants/theme'
import { useModules } from '@/repositories/moduleRepository'
import { ModuleMultiComboBox } from '../ModuleMultiComboBox'
import { Module } from '@/models/module'
import { GraphOptions } from '@/models/combinedDefinition'

type ConfigureGraphOptionsDialogProps = {
  type: 'configureGraphOptionsDialog'
}

export type DialogProps = ConfigureGraphOptionsDialogProps

type Props = {
  isOpen: boolean
  onClickClose: () => void
  graphOptions: GraphOptions
  setGraphOptions: React.Dispatch<React.SetStateAction<GraphOptions>>
}

export const ConfigureGraphOptionsDialog: React.FC<Props> = ({ isOpen, onClickClose, graphOptions, setGraphOptions }) => {
  const [temporaryViewOptions, setTemporaryViewOptions] = useState<GraphOptions>(graphOptions)
  const { data: modules, isLoading } = useModules()

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

  const onChangeOnlyModule = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => {
      setTemporaryViewOptions((prev) => ({ ...prev, onlyModule: event.target.checked }))
    },
    [setTemporaryViewOptions],
  )

  const onChangeRemoveInternalDependencies = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => {
      setTemporaryViewOptions((prev) => ({ ...prev, removeInternalSources: event.target.checked }))
    },
    [setTemporaryViewOptions],
  )

  const setModules = useCallback(
    (modules: Module[]) => {
      setTemporaryViewOptions((prev) => {
        return { ...prev, modules }
      })
    },
    [setTemporaryViewOptions],
  )

  const setFocusModules = useCallback(
    (modules: Module[]) => {
      setTemporaryViewOptions((prev) => {
        return { ...prev, focusModules: modules }
      })
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
      width={'800px'}
    >
      <WrapperSection>
        <Stack gap={1.5}>
          <FormControl title="Clip the boundary" helpMessage="Clip the boundary of the module.">
            <CheckBox name="compound" onChange={onChangeCompound} checked={temporaryViewOptions.compound} />
          </FormControl>

          <FormControl
            title="Use edge concentrators"
            helpMessage="This merges multiedges into a single edge and causes partially parallel edges to share part of their paths."
          >
            <CheckBox name="compound" onChange={onChangeConcentrate} checked={temporaryViewOptions.concentrate} />
          </FormControl>

          <FormControl title="List of modules displaying sources">
            <ModuleMultiComboBox
              isLoading={isLoading}
              data={modules ?? []}
              modules={temporaryViewOptions.modules}
              setModules={setModules}
            />
          </FormControl>

          <FormControl title="List of modules displaying dependencies">
            <ModuleMultiComboBox
              isLoading={isLoading}
              data={modules ?? []}
              modules={temporaryViewOptions.focusModules}
              setModules={setFocusModules}
            />
          </FormControl>

          <FormControl
            title="Render only modules"
            helpMessage="Displays only the dependencies between modules, not individual sources."
          >
            <CheckBox name="only_module" onChange={onChangeOnlyModule} checked={temporaryViewOptions.onlyModule} />
          </FormControl>

          <FormControl
            title="Remove internal modules"
            helpMessage="Exclude private sources whose dependencies are only internal to the module"
          >
            <CheckBox
              name="only_module"
              onChange={onChangeRemoveInternalDependencies}
              checked={temporaryViewOptions.removeInternalSources}
            />
          </FormControl>
        </Stack>
      </WrapperSection>
    </ActionDialog>
  )
}

const WrapperSection = styled(Section)`
  padding: ${spacing.XS};
`
