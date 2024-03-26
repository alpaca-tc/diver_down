import { Graphviz } from '@hpcc-js/wasm/graphviz'
import { FC, useEffect, useRef, useState } from "react"
import styled from 'styled-components'

type Props = {
  dot: string
}

export const Dot: FC<Props> = ({ dot }) => {
  const [svg, setSvg] = useState<string>('');
  const widthRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    if (dot && widthRef.current) {
      const loadSvg = async () => {
        if (dot) {
          const graphviz = await Graphviz.load();
          setSvg(graphviz.dot(dot));
        } else {
          setSvg('');
        }
      }

      loadSvg()
    }
  }, [dot, setSvg])

  if (!dot || !svg) return null;

  return (
    <Wrapper dangerouslySetInnerHTML={{ __html: svg }} />
  )
}

const Wrapper = styled.div`
  width: 80px;
`
