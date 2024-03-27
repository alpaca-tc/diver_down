import { FC, useEffect, useRef, useState } from "react"
import styled from "styled-components"

import { useRefSize } from "@/hooks/useRefSize"

type Props = {
  svg: string
}

const fitSvg = (svg: string, width: string, height: string): string => {
  const html: SVGElement = new DOMParser().parseFromString(svg, "text/html").body.querySelector('svg')!

  // set width and height
  html.setAttribute("width", width);
  html.setAttribute("height", height);

  // set viewBox
  applyFit(html)

  return html.outerHTML
}

const applyFit = (svg: SVGElement) => {
  const width = parseInt(svg.getAttribute('width')!.replace('pt', ''), 10) * 4 / 3;
  const height = parseInt(svg.getAttribute('height')!.replace('pt', ''), 10) * 4 / 3;
  const scale = 1

  svg.setAttribute("viewBox", `0 0 ${width * 3 / 4 / scale} ${height * 3 / 4 / scale}`);
}

export const ScrollableSvg: FC<Props> = ({ svg }) => {
  const ref = useRef<HTMLDivElement>(null);
  const [fittedSvg, setFittedSvg] = useState<string>('')
  const [width, height] = useRefSize(ref)

  useEffect(() => {
    if (svg && ref.current) {
      setFittedSvg(fitSvg(svg, `${width}px`, `${height}px`))
    } else {
      setFittedSvg('')
    }
  }, [svg, ref, width, height])

  return (
    <StyledDiv ref={ref}>
      <div dangerouslySetInnerHTML={{ __html: fittedSvg }} />
    </StyledDiv>
  )
}

const StyledDiv = styled.div`
  height: inherit;
  width: 100%;
  overflow: hidden;
`
