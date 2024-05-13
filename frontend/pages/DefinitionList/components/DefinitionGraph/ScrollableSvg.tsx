import React, { FC, useCallback, useEffect, useRef, useState } from 'react'
import { ReactSVGPanZoom, TOOL_NONE, TOOL_PAN } from 'react-svg-pan-zoom'
import { ReactSvgPanZoomLoader } from 'react-svg-pan-zoom-loader'
import styled from 'styled-components'

import { useRefSize } from '@/hooks/useRefSize'
import { CombinedDefinition, DotMetadata } from '@/models/combinedDefinition'
import { renderDot } from '@/utils/renderDot'
import { extractSvgSize, getClosestAndSmallestElement, toSVGPoint } from '@/utils/svgHelper'

import { DialogProps } from '../dialog'

import type { Tool, Value } from 'react-svg-pan-zoom'

type Props = {
  combinedDefinition: CombinedDefinition
  setVisibleDialog: React.Dispatch<React.SetStateAction<DialogProps | null>>
}

// Return .cluster, .node, .edge or null
const findClosestElementOnCursor = (event: MouseEvent): SVGGElement | null => {
  const svg = (event.target as HTMLElement).closest<SVGSVGElement>('svg')

  // If outside svg, do nothing.
  if (!svg) {
    return null
  }

  const elementsUnderCursor = document.elementsFromPoint(event.clientX, event.clientY)
  const point = toSVGPoint(svg, event.target! as Element, event.clientX, event.clientY)
  const neastElement = getClosestAndSmallestElement(elementsUnderCursor, point)

  const neastGeometryElement = neastElement?.closest<SVGGElement>('g.node, g.edge, g.cluster')

  return neastGeometryElement ?? null
}

export const ScrollableSvg: FC<Props> = ({ combinedDefinition, setVisibleDialog }) => {
  const { observeRef, size } = useRefSize<HTMLDivElement>()
  const viewerRef = useRef<ReactSVGPanZoom | null>(null)

  const [value, setValue] = useState<Value>({} as Value) // NOTE: react-svg-pan-zoom supported blank object as a initial value. but types is not supported.
  const [tool, setTool] = useState<Tool>(TOOL_PAN)
  const [hoverMetadata, setHoverMetadata] = useState<DotMetadata | null>(null)
  const [svg, setSvg] = useState<string>('')

  const svgSize = extractSvgSize(svg)

  const fitToViewerOnMount = useCallback((node: ReactSVGPanZoom) => {
    if (node) {
      node.fitToViewer('center', 'top')
      viewerRef.current = node
    } else {
      viewerRef.current = null
    }
  }, [])

  // Convert dot to SVG
  useEffect(() => {
    const loadSvg = async () => {
      if (combinedDefinition.dot) {
        const newSvg = await renderDot(combinedDefinition.dot)
        setSvg(newSvg)
      } else {
        setSvg('')
      }
    }

    loadSvg()
  }, [combinedDefinition.dot, setSvg])

  // On click .node, .edge, .cluster
  useEffect(() => {
    if (tool !== TOOL_NONE) {
      setVisibleDialog(null)
      return
    }

    const onClickGeometry = (event: MouseEvent) => {
      if (hoverMetadata) {
        event.preventDefault()
        setVisibleDialog({ type: 'metadataDialog', metadata: hoverMetadata, left: event.clientX, top: event.clientY })
      }
    }

    document.addEventListener('click', onClickGeometry)

    return () => {
      document.removeEventListener('click', onClickGeometry)
    }
  }, [tool, hoverMetadata, setVisibleDialog])

  // On hover .node, .edge, .cluster
  useEffect(() => {
    if (tool !== TOOL_NONE) {
      setHoverMetadata(null)
      return
    }

    const onMouseMove = (event: MouseEvent) => {
      const element = findClosestElementOnCursor(event)

      if (element) {
        const metadata = combinedDefinition.dotMetadata.find(({ id }) => element.id === id)
        setHoverMetadata(metadata ?? null)
      } else {
        setHoverMetadata(null)
      }
    }

    document.addEventListener('mousemove', onMouseMove)

    return () => {
      document.removeEventListener('mousemove', onMouseMove)
    }
  }, [tool, combinedDefinition.dotMetadata])

  // On update combinedDefinition
  useEffect(() => {
    const findNewMetadata = (prev: DotMetadata | null): DotMetadata | null => {
      if (prev) {
        switch (prev.type) {
          case 'source':
            return (
              combinedDefinition.dotMetadata.find(
                (metadata) => metadata.type === 'source' && metadata.sourceName === prev.sourceName,
              ) ?? null
            )
          case 'dependency':
          case 'module':
            // Can't find previous module
            return prev
        }
      } else {
        return null
      }
    }

    setHoverMetadata((prev) => findNewMetadata(prev))
    setVisibleDialog((prev) => {
      if (prev?.type === 'metadataDialog') {
        const newMetadata = findNewMetadata(prev.metadata)

        if (newMetadata) {
          return { ...prev, metadata: newMetadata }
        } else {
          return null
        }
      } else {
        return prev
      }
    })
  }, [combinedDefinition.dotMetadata, setVisibleDialog, setHoverMetadata])

  if (!svg) return null

  return (
    <Wrapper ref={observeRef} $idOnHover={hoverMetadata?.id}>
      <ReactSvgPanZoomLoader
        svgXML={svg}
        render={(content) => (
          <ReactSVGPanZoom
            ref={fitToViewerOnMount}
            background="white"
            width={size.width ?? 1000}
            height={size.height ?? 1000}
            defaultTool={TOOL_PAN}
            preventPanOutside={false}
            detectAutoPan={false}
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

const Wrapper = styled.div<{ $idOnHover: string | undefined }>`
  height: 100%;
  width: 100%;

  /* overwride pointer-events: none; for oncursormove events */
  .node,
  .edge,
  .cluster {
    pointer-events: all;
  }

  ${(props) =>
    props.$idOnHover &&
    `
    #${props.$idOnHover} {
      stroke-width: 3;
    }

    cursor: pointer;
  `}
`
