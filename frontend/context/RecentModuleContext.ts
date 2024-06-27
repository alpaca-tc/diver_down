import { Module } from '@/models/module'
import React from 'react'

export type RecentModuleProps = {
  recentModule: Module | null
  setRecentModule: React.Dispatch<React.SetStateAction<Module | null>>
}

export const RecentModuleContext = React.createContext<RecentModuleProps>({
  recentModule: null,
  setRecentModule: () => {},
})
