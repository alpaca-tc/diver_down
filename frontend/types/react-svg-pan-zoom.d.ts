import { ReactSVGPanZoom as original } from 'react-svg-pan-zoom'

declare module 'react-svg-pan-zoom' {
  interface ReactSVGPanZoom {
    // @types/react-svg-pan-zoom is not supported alignX and alignY
    fitToViewer(alignX: 'left' | 'center' | 'right', alignY: 'top' | 'center' | 'bottom'): void
    ViewerDOM: SVGElement | undefined
  }
}
