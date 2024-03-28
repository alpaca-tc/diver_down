import { Link as ReactRouterLink } from 'react-router-dom'
import styled from 'styled-components'

import { color, theme } from '@/constants/theme'

export const Link = styled(ReactRouterLink)`
  color: ${color.TEXT_LINK};
  transition: color 0.2s;

  &:hover {
    color: ${theme.color.hoverColor(color.TEXT_LINK)};
  }
`
