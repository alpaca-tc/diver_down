import React, { FC, useCallback, useEffect, useMemo, useState } from 'react'

import { MultiComboBox } from '@/components/ui'
import { Module } from '@/models/module'
import { Item, convertModuleToItem } from '@/components/SourceModuleComboBox/utils'

type Props = {
  isLoading: boolean
  data: Module[]
  modules: Module[]
  setModules: (modules: Module[]) => void
}

export const ModuleMultiComboBox: FC<Props> = ({ data, modules, setModules, isLoading }) => {
  const [selectedItems, setSelectedItems] = useState<Item[]>([])

  const defaultItems: Item[] = useMemo(() => (data ?? []).map((modules) => convertModuleToItem(modules)), [data])

  useEffect(() => {
    if (isLoading || modules.length === 0 || selectedItems.length > 0) return

    const initialItems = modules.map((module) => defaultItems.find((item) => item.data! === module)).filter(Boolean) as Item[]
    setSelectedItems(initialItems)
  }, [isLoading, defaultItems, selectedItems, modules])

  const handleSelectItem = useCallback(
    (item: Item) => {
      const newSelectedItems = [...selectedItems, item]
      setSelectedItems(newSelectedItems)
      setModules(newSelectedItems.map((i) => i.data!))
    },
    [selectedItems, setSelectedItems],
  )

  const handleDeleteItem = useCallback(
    (item: Item) => {
      const newSelectedItems = selectedItems.filter((i) => i !== item)
      setSelectedItems(newSelectedItems)
      setModules(newSelectedItems.map((i) => i.data!))
    },
    [setSelectedItems, selectedItems],
  )

  return (
    <MultiComboBox
      items={defaultItems}
      selectedItems={selectedItems}
      dropdownHelpMessage="Select or input Module"
      isLoading={isLoading}
      onSelect={handleSelectItem}
      onDelete={handleDeleteItem}
      decorators={{
        noResultText: () => `no result.`,
        destroyButtonIconAlt: (text) => `destroy.(${text})`,
      }}
    />
  )
}
