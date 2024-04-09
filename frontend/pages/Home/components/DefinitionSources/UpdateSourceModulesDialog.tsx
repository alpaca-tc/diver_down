import { useCallback, useEffect, useState } from 'react'
import styled from 'styled-components'

import { ActionDialog, Button, Cluster, FaCirclePlusIcon, FaTrashIcon, FormControl, Input, Section, Stack, Text } from '@/components/ui'
import { spacing } from '@/constants/theme'
import { useSourceModules } from '@/repositories/sourceModulesRepository'

type Props = {
  sourceName: string
  initialModuleNames: string[]
  onClose: () => void
  isOpen: boolean
  onSave: () => void
}

export const UpdateSourceModulesDialog: React.FC<Props> = ({ sourceName, initialModuleNames, onClose, isOpen, onSave }) => {
  const [moduleNames, setModuleNames] = useState<string[]>([])
  const { trigger } = useSourceModules(sourceName)

  useEffect(() => {
    if (initialModuleNames.length === 0) {
      setModuleNames([''])
    } else {
      setModuleNames(initialModuleNames)
    }
  }, [sourceName, initialModuleNames])

  const handleSubmit = useCallback(() => {
    trigger({ modules: moduleNames })
    onSave()
  }, [trigger, moduleNames, onSave])

  const addBlankModuleName = useCallback(() => {
    setModuleNames((prev) => [...prev, ''])
  }, [setModuleNames])

  const removeModuleName = (index: number) => {
    setModuleNames((prev) => prev.filter((_, i) => i !== index))
  }

  return (
    <ActionDialog
      title="Update Source Modules"
      decorators={{ closeButtonLabel: () => 'Close' }}
      actionText="Save"
      actionTheme="primary"
      isOpen={isOpen}
      onClickAction={handleSubmit}
      onClickClose={onClose}
      onClickOverlay={onClose}
      width={'500px'}
    >
      <WrapperSection>
        <Stack gap={1.5}>
          <Stack gap={1.5}>
            <Stack gap={1.5}>
              <FormControl title="Module Names">
                <Stack gap={1.5}>
                  {moduleNames.map((moduleName, index) => (
                    <Cluster key={index} align="center">
                      <Text>
                        {index + 1}
                      </Text>
                      <Input
                        name={`module_name[${index}]`}
                        value={moduleName}
                        onChange={(e) => {
                          setModuleNames((prev) => prev.map((v, i) => (i === index ? e.target.value : v)))
                        }}
                      />

                      <Button variant="text" onClick={() => removeModuleName(index)}>
                        <FaTrashIcon alt="削除" />
                      </Button>
                    </Cluster>
                  ))}
                </Stack>
              </FormControl>

              <Button prefix={<FaCirclePlusIcon />} size="s" onClick={addBlankModuleName}>
                Add module name
              </Button>
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
