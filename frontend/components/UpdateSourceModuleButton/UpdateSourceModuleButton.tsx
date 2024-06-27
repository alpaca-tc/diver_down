import { FC, useCallback } from 'react'
import { Button, FaCopyIcon, Tooltip } from '@/components/ui'
import { Module } from '@/models/module'
import { useSourceModule } from '@/repositories/sourceModuleRepository'

type Props = {
  sourceName: string
  newModule: Module | null
  onSaved: () => void
}

export const UpdateSourceModuleButton: FC<Props> = ({ sourceName, newModule, onSaved }) => {
  const { trigger } = useSourceModule(sourceName)

  const updateSourceModules = useCallback(async () => {
    await trigger({ module: newModule })
    onSaved()
  }, [newModule, onSaved, trigger])

  if (newModule === null) {
    return (
      <Button square={true} variant="primary" disabled onClick={() => {}} size="s">
        <Tooltip
          message={`Once you update source's module, you can save it with the same module.`}
          horizontal="center"
          vertical="bottom"
        >
          <FaCopyIcon />
        </Tooltip>
      </Button>
    )
  } else {
    return (
      <Button square={true} variant="primary" onClick={updateSourceModules} size="s">
        <Tooltip message={`Save "${newModule}"`} horizontal="center" vertical="bottom">
          <FaCopyIcon />
        </Tooltip>
      </Button>
    )
  }
}
