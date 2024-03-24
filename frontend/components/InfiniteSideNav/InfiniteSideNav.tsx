import React, { ComponentProps, FC, HTMLAttributes } from 'react'
import styled from 'styled-components'

import { color } from '@/constants/theme'

import { InfiniteSideNavItemButton, OnClick, SideNavSizeType } from './InfiniteSideNavItemButton'
import { useClassNames } from './useClassNames'

type SideNavItemButtonProps = Omit<ComponentProps<typeof InfiniteSideNavItemButton>, 'size' | 'onClick'>

type Props = {
  /** 各アイテムのデータの配列 */
  items: SideNavItemButtonProps[]
  /** 各アイテムの大きさ */
  size?: SideNavSizeType
  /** アイテムを押下したときに発火するコールバック関数 */
  onClick?: OnClick
  /** コンポーネントに適用するクラス名 */
  className?: string
}
type ElementProps = Omit<HTMLAttributes<HTMLUListElement>, keyof Props>

export const InfiniteSideNav: FC<Props & ElementProps> = ({
  items,
  size = 'default',
  onClick,
  className = '',
  ...props
}) => {
  const classNames = useClassNames()

  return (
    <Wrapper {...props} className={`${className} ${classNames.wrapper}`}>
      {items.map((item) => (
        <InfiniteSideNavItemButton
          id={item.id}
          title={item.title}
          prefix={item.prefix}
          isSelected={item.isSelected}
          size={size}
          key={item.id}
          onClick={onClick}
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
