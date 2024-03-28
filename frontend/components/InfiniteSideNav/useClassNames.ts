import { useMemo } from 'react'

import { InfiniteSideNav } from './InfiniteSideNav'
import { useClassNameGenerator } from '@/components/ui'

export function useClassNames() {
  const generate = useClassNameGenerator(InfiniteSideNav.displayName || 'SideNav')
  return useMemo(
    () => ({
      wrapper: generate(),
      item: generate('item'),
      itemTitle: generate('itemTitle'),
    }),
    [generate],
  )
}
