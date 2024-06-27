import React, { FC, useCallback, useEffect, useMemo, useRef, useState } from 'react'

import { Button, Cluster, FaXmarkIcon, FormControl, SingleComboBox } from '@/components/ui'
import { Module } from '@/models/module'
import { useModules } from '@/repositories/moduleRepository'
import { useSourceModule } from '@/repositories/sourceModuleRepository'
import { Item, convertModuleToItem } from './utils'

type Props = {
  sourceName: string
  initialModule: Module | null
  onClose: () => void
  onUpdate: (module: Module | null) => void
}

export const SourceModuleComboBox: FC<Props> = ({ sourceName, initialModule, onClose, onUpdate }) => {
  const { data, isLoading, mutate } = useModules()
  const { trigger } = useSourceModule(sourceName)

  const [temporaryItem, setTemporaryItem] = useState<Item | null>(null)
  const [selectedItem, setSelectedItem] = useState<Item | null>(null)
  const initializedInitialModule = useRef<boolean>(false)

  const defaultItems: Item[] = useMemo(() => (data ?? []).map((module) => convertModuleToItem(module)), [data])

  useEffect(() => {
    if (selectedItem || isLoading || defaultItems.length === 0 || initializedInitialModule.current) return

    setSelectedItem(defaultItems.find((item) => item.data! === initialModule) ?? null)
    initializedInitialModule.current = true
  }, [isLoading, defaultItems, selectedItem, initialModule, initializedInitialModule])

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
      const temporaryModule: Module = label
      const newItem = convertModuleToItem(temporaryModule)

      setTemporaryItem(newItem)
      setSelectedItem(newItem)
    },
    [setTemporaryItem, setSelectedItem],
  )

  const handleUpdate = useCallback(async () => {
    const module = selectedItem?.data ?? null
    await trigger({ module })
    mutate()
    onUpdate(module)
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
        <FormControl title="Module">
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
