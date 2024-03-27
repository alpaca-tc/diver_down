import { FC, useEffect, useRef, useState } from "react";
import styled from "styled-components";

import { CombinedDefinition } from "@/models/combinedDefinition";
import { renderDot } from "@/utils/renderDot";

import { ScrollableSvg } from "./ScrollableSvg";

type Props = {
  combinedDefinition: CombinedDefinition
}

export const Content: FC<Props> = ({ combinedDefinition }) => {
  const [svg, setSvg] = useState<string>('');

  useEffect(() => {
    const loadSvg = async () => {
      if (combinedDefinition.dot) {
        const newSvg = await renderDot(combinedDefinition.dot)
        setSvg(newSvg);
      } else {
        setSvg('');
      }
    }

    loadSvg()
  }, [combinedDefinition.dot, setSvg])

  return (
    <ScrollableSvg svg={svg} />
  )
}
