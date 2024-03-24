import React, { FC, ReactNode } from 'react'
import styled from 'styled-components'

import { UnstyledButton, isTouchDevice } from '@/components/ui'
import { color, fontSize, interaction, theme } from '@/constants/theme'

import { useClassNames } from './useClassNames'

export type SideNavSizeType = 'default' | 's'
export type OnClick = (e: React.MouseEvent<HTMLButtonElement, MouseEvent>, id: string) => void

type Props = {
  /** アイテムの識別子 */
  id: string
  /** アイテムのタイトル */
  title: ReactNode
  /** タイトルのプレフィックスの内容。通常、StatusLabel の配置に用います。 */
  prefix?: ReactNode
  /** 選択されているアイテムかどうか */
  isSelected?: boolean
  /** アイテムの大きさ */
  size?: SideNavSizeType
  /** アイテムを押下したときに発火するコールバック関数 */
  onClick?: OnClick
}

export const InfiniteSideNavItemButton: FC<Props> = ({
  id,
  title,
  prefix,
  isSelected = false,
  size,
  onClick,
}) => {
  const classNames = useClassNames()
  const handleClick = onClick
    ? (e: React.MouseEvent<HTMLButtonElement, MouseEvent>) => onClick(e, id)
    : undefined

  const itemClassName = `${isSelected ? 'selected' : ''} ${classNames.item}`
  return (
    <Wrapper className={itemClassName}>
      <Button className={size} onClick={handleClick}>
        {prefix && <PrefixWrapper>{prefix}</PrefixWrapper>}
        <span className={classNames.itemTitle}>{title}</span>
      </Button>
    </Wrapper>
  )
}

const Wrapper = styled.li`
  color: ${color.TEXT_BLACK};
  transition: ${isTouchDevice
    ? 'none'
    : `background-color ${interaction.hover.animation}, color ${interaction.hover.animation}`};

  &:hover {
    background-color: ${theme.color.hoverColor(color.COLUMN)};
  }

  &.selected {
    background-color: ${color.MAIN};
    color: ${color.TEXT_WHITE};
    position: relative;

    &::after {
      position: absolute;
      top: 50%;
      right: -4px;
      transform: translate(0, -50%);
      border-style: solid;
      border-width: 4px 0 4px 4px;
      border-color: transparent transparent transparent ${color.MAIN};
      content: '';
    }
  }
`

const Button = styled(UnstyledButton)`
  outline: none;
  width: 100%;
  line-height: 1;
  box-sizing: border-box;
  cursor: pointer;

  &.default {
    padding: ${theme.spacingByChar(1)};
    font-size: ${fontSize.M};
  }

  &.s {
    padding: ${theme.spacingByChar(0.5)} ${theme.spacingByChar(1)};
    font-size: ${fontSize.S};
  }

  &:focus-visible {
    ${theme.shadow.focusIndicatorStyles}
  }
`
const PrefixWrapper = styled.span`
  margin-right: ${theme.spacingByChar(0.5)};
`
