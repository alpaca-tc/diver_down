import { DependencyType } from '@/models/module'
import { FC } from 'react'
import { useSourceDependencyType } from '@/repositories/sourceDependencyTypeRepository'
import { Select } from '@/components/ui'

const defaultDependencyTypeOptions = [
  { value: '', label: '' },
  { value: 'valid', label: 'Valid' },
  { value: 'invalid', label: 'Invalid' },
  { value: 'todo', label: 'Todo' },
  { value: 'ignore', label: 'Ignore' },
]

type Props = {
  fromSource: string
  toSource: string
  dependencyType: DependencyType
  onUpdated: () => void
}

export const SourceDependencyTypeSelect: FC<Props> = ({ fromSource, toSource, dependencyType, onUpdated }) => {
  const { trigger } = useSourceDependencyType(fromSource, toSource)

  const handleChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    const value = e.target.value

    trigger({ dependencyType: value as DependencyType }).then(onUpdated)
  }

  return <Select options={defaultDependencyTypeOptions} value={dependencyType ?? ''} onChange={handleChange} />
}
