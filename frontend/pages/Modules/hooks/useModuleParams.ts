import { useSearchParamsState } from '@/hooks/useSearchParamsState'
import { Module } from '@/models/module'

export const validTabs = ['sources', 'sourceReverseDependencies', 'moduleDependencies', 'moduleReverseDependencies'] as const
export type ValidTab = (typeof validTabs)[number]

export type Params = {
  tab: ValidTab
  filteredModule: Module | null
}

export const useModuleParams = () => {
  return useSearchParamsState<Params>({
    tab: (val: any) => (validTabs.includes(String(val) as ValidTab) ? (String(val) as ValidTab) : 'sources'),
    filteredModule: (val: any) => {
      return val ? String(val) : null
    },
  })
}
