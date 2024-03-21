import normalizeCss from 'smarthr-normalize-css'
import { createGlobalStyle } from 'styled-components'

import {
  FONT_FAMILY,
  createTheme,
  defaultBorder,
  defaultBreakpoint,
  defaultColor,
  defaultFontSize,
  defaultInteraction,
  defaultLeading,
  defaultRadius,
  defaultSpacing,
} from '../components/ui'

export const theme = createTheme()

export { FONT_FAMILY }
export const border = defaultBorder
export const breakpoint = defaultBreakpoint
export const color = defaultColor
export const fontSize = defaultFontSize
export const interaction = defaultInteraction
export const leading = defaultLeading
export const radius = defaultRadius
export const spacing = defaultSpacing

export const GlobalStyle = createGlobalStyle`
  ${normalizeCss};

  html, body, #root {
    height: 100%;
  }

  body {
    background-color: ${color.BACKGROUND};
    line-height: ${leading.NORMAL};
    font-family: ${FONT_FAMILY};
    font-size: ${fontSize.S};
    color: ${color.TEXT_BLACK};
  }
`
