import type { ComboBoxItem } from '@/components/ui'
import { Module } from '@/models/module'

export type Item = ComboBoxItem<Module>

export const convertModuleToItem = (module: Module): Item => ({
  label: module,
  value: module,
  data: module,
})
