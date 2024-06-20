import { FC, useCallback } from 'react'
import { Button, FaCopyIcon, Tooltip } from '@/components/ui'
import { Module } from '@/models/module'
import { useSourceModules } from '@/repositories/sourceModulesRepository'

type Props = {
  sourceName: string
  newModules: Module[]
  onSaved: () => void
}

export const UpdateSourceModulesButton: FC<Props> = ({ sourceName, newModules, onSaved }) => {
  const { trigger } = useSourceModules(sourceName)

  const updateSourceModules = useCallback(async () => {
    await trigger({ modules: newModules })
    onSaved()
  }, [newModules, onSaved, trigger])

  if (newModules.length === 0) {
    return (
      <Button square={true} variant="primary" disabled onClick={() => {}} size="s">
        <Tooltip
          message={`Once you update source's modules, you can save it with the same modules.`}
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
        <Tooltip message={`Save "${newModules.join('/')}"`} horizontal="center" vertical="bottom">
          <FaCopyIcon />
        </Tooltip>
      </Button>
    )
  }
}
