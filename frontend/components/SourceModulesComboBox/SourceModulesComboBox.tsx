import React, { FC, useCallback, useContext, useEffect, useMemo, useState } from 'react'

import { Button, Cluster, ComboBoxItem, FaXmarkIcon, FormControl, SingleComboBox } from '@/components/ui'
import { Module } from '@/models/module'
import { useModules } from '@/repositories/moduleRepository'
import { useSourceModules } from '@/repositories/sourceModulesRepository'

type Item = ComboBoxItem<Module[]>

type Props = {
  sourceName: string
  initialModules: Module[]
  onClose: () => void
  onUpdate: (modules: Module[]) => void
}

const equalModules = (a: Module[], b: Module[]) => a.every((module, index) => module.moduleName === (b[index]?.moduleName ?? ''))

const convertModulesToItem = (modules: Module[]): Item => ({
  label: modules.map((module) => module.moduleName).join(' / '),
  value: modules.map((module) => module.moduleName).join('/'),
  data: modules,
})

const DELIMITER_RE = /\s*\/\s*/

export const SourceModulesComboBox: FC<Props> = ({ sourceName, initialModules, onClose, onUpdate }) => {
  const { data, isLoading, mutate } = useModules()
  const { trigger } = useSourceModules(sourceName)

  const [temporaryItem, setTemporaryItem] = useState<Item | null>(null)
  const [selectedItem, setSelectedItem] = useState<Item | null>(null)

  const defaultItems: Item[] = useMemo(() => (data ?? []).map((modules) => convertModulesToItem(modules)), [data])

  useEffect(() => {
    if (selectedItem || !isLoading) return

    setSelectedItem(defaultItems.find((item) => equalModules(item.data!, initialModules)) ?? null)
  }, [isLoading, defaultItems, selectedItem, initialModules])

  const handleSelectItem = useCallback(
    (item: Item) => {
      setSelectedItem(item)

      if (item !== temporaryItem) {
        setTemporaryItem(null)
      }
    },
    [setSelectedItem, temporaryItem, setTemporaryItem],
  )

  const handleClear = useCallback(() => {
    setSelectedItem(null)
  }, [setSelectedItem])

  const handleAddItem = useCallback(
    (label: string) => {
      const temporaryModules: Module[] = label.split(DELIMITER_RE).map((moduleName) => ({ moduleName }))
      const newItem = convertModulesToItem(temporaryModules)

      setTemporaryItem(newItem)
      setSelectedItem(newItem)
    },
    [setTemporaryItem, setSelectedItem],
  )

  const handleUpdate = useCallback(async () => {
    const modules = selectedItem?.data ?? []
    await trigger({ modules })
    mutate()
    onUpdate(modules)
  }, [mutate, trigger, selectedItem, onUpdate])

  const items = useMemo(() => {
    const array = [...defaultItems]

    if (temporaryItem) {
      array.push(temporaryItem)
    }

    return array
  }, [defaultItems, temporaryItem])

  return (
    <Cluster>
      <div>
        <FormControl title="Modules" helpMessage="Submodules are separated by slash">
          <SingleComboBox
            items={items}
            selectedItem={selectedItem}
            dropdownHelpMessage="Select or input Module"
            creatable
            isLoading={isLoading}
            onSelect={handleSelectItem}
            onClear={handleClear}
            onAdd={handleAddItem}
            width="200px"
            decorators={{
              noResultText: () => `no result.`,
              destroyButtonIconAlt: (text) => `destroy.(${text})`,
            }}
          />
        </FormControl>
      </div>
      <Button square={true} variant="primary" onClick={handleUpdate} size="s">
        Update
      </Button>
      <Button square={true} onClick={onClose} size="s">
        <FaXmarkIcon alt="Cancel" />
      </Button>
    </Cluster>
  )
}
