import React, { FC, useState } from 'react'
import { ReactSVGPanZoom, TOOL_PAN } from 'react-svg-pan-zoom'
import { ReactSvgPanZoomLoader } from 'react-svg-pan-zoom-loader'
import styled from 'styled-components'

import { useRefSize } from '@/hooks/useRefSize'

import type { Tool, Value } from 'react-svg-pan-zoom'

type Props = {
  svg: string
}

const extractSvgSize = (svg: string) => {
  const html: SVGElement = new DOMParser().parseFromString(svg, 'text/html').body.querySelector('svg')!
  const width = parseInt(html.getAttribute('width')!.replace(/pt/, ''), 10)!
  const height = parseInt(html.getAttribute('height')!.replace(/pt/, ''), 10)!

  return { width, height }
}

export const ScrollableSvg: FC<Props> = ({ svg }) => {
  const { observeRef, size } = useRefSize<HTMLDivElement>()
  const [value, setValue] = useState<Value>({} as Value) // NOTE: react-svg-pan-zoom supported blank object as a initial value. but types is not supported.
  const [tool, setTool] = useState<Tool>(TOOL_PAN)

  if (!svg) return null

  const svgSize = extractSvgSize(svg)

  return (
    <Wrapper ref={observeRef}>
      <ReactSvgPanZoomLoader
        svgXML={svg}
        render={(content) => (
          <ReactSVGPanZoom
            background="white"
            width={size.width ?? 1000}
            height={size.height ?? 1000}
            defaultTool={TOOL_PAN}
            preventPanOutside={false}
            tool={tool}
            onChangeTool={setTool}
            value={value}
            onChangeValue={setValue}
            miniatureProps={{ background: '#616264', position: 'none', width: 0, height: 0 }}
          >
            <svg width={svgSize.width} height={svgSize.height}>
              {content}
            </svg>
          </ReactSVGPanZoom>
        )}
      />
    </Wrapper>
  )
}

const Wrapper = styled.div`
  height: 100%;
  width: 100%;
`
