import { FC, useEffect, useState } from "react"
import styled from 'styled-components'

import { renderDot } from "@/utils/renderDot"

type Props = {
  dot: string
}

export const Dot: FC<Props> = ({ dot }) => {
  const [svg, setSvg] = useState<string>('');

  useEffect(() => {
    if (dot) {
      const loadSvg = async () => {
        if (dot) {
          setSvg(await renderDot(dot));
        } else {
          setSvg('');
        }
      }

      loadSvg()
    } else {
      setSvg('');
    }
  }, [dot, setSvg])

  if (!dot || !svg) return null;

  return (
    <Wrapper>
      <Svg dangerouslySetInnerHTML={{ __html: svg }} />
    </Wrapper>
  )
}

const Wrapper = styled.div`
  height: inherit;
  width: 100%;
  overflow: scroll;
`

const Svg = styled.div`
`
