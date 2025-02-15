import { Select } from '@/components/ui'
import { DependencyType } from '@/models/module'
import { useModuleDependencyType } from '@/repositories/moduleDependencyTypeRepository'
import { FC } from 'react'

type Props = {
  fromModule: string
  toModule: string
  dependencyTypes: Set<DependencyType> | undefined
  onUpdated: () => void
}

export const ModuleDependencyTypeSelect: FC<Props> = ({ fromModule, toModule, dependencyTypes, onUpdated: mutate }) => {
  const { trigger } = useModuleDependencyType(fromModule, toModule)

  const dependencyTypeOptions = [
    { value: 'valid', label: 'Valid' },
    { value: 'invalid', label: 'Invalid' },
    { value: 'todo', label: 'Todo' },
    { value: 'ignore', label: 'Ignore' },
  ]

  const dependencyType = dependencyTypes && dependencyTypes.size > 0 ? [...dependencyTypes].join(', ') : undefined

  if (dependencyTypes && dependencyTypes.size > 1) {
    dependencyTypeOptions.unshift({ value: dependencyType ?? '', label: dependencyType ?? '' })
  }

  const handleChange = async (value: string) => {
    await trigger({ dependencyType: value as DependencyType })
    mutate()
  }

  return <Select options={dependencyTypeOptions} value={dependencyType} onChangeValue={handleChange} hasBlank={true} />
}
