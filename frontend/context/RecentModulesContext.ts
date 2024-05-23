import { Module } from '@/models/module'
import React from 'react'

export type RecentModulesProps = {
  recentModules: Module[]
  setRecentModules: React.Dispatch<React.SetStateAction<Module[]>>
}

export const RecentModulesContext = React.createContext<RecentModulesProps>({
  recentModules: [],
  setRecentModules: () => {},
})
