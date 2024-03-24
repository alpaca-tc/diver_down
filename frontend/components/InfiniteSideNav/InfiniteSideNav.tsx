import React, { ComponentProps, FC, HTMLAttributes } from 'react'
import styled from 'styled-components'

import { color } from '@/constants/theme'

import { InfiniteSideNavItemButton, SideNavSizeType } from './InfiniteSideNavItemButton'
import { useClassNames } from './useClassNames'

type InfiniteSideNavItemButtonProps = Omit<ComponentProps<typeof InfiniteSideNavItemButton>, 'size'> & {
  ref?: React.Ref<HTMLLIElement>
  key: string
}

type Props = {
  /** 各アイテムのデータの配列 */
  items: InfiniteSideNavItemButtonProps[]
  /** 各アイテムの大きさ */
  size?: SideNavSizeType
  /** コンポーネントに適用するクラス名 */
  className?: string
}
type ElementProps = Omit<HTMLAttributes<HTMLUListElement>, keyof Props>

export const InfiniteSideNav: FC<Props & ElementProps> = ({
  items,
  size = 'default',
  className = '',
  ...props
}) => {
  const classNames = useClassNames()

  return (
    <Wrapper {...props} className={`${className} ${classNames.wrapper}`}>
      {items.map((item) => (
        <InfiniteSideNavItemButton
          ref={item.ref}
          title={item.title}
          prefix={item.prefix}
          isSelected={item.isSelected}
          onClick={item.onClick}
          size={size}
          key={item.key}
        />
      ))}
    </Wrapper>
  )
}

const Wrapper = styled.ul`
  background-color: ${color.COLUMN};
  list-style: none;
  padding: 0;
`
