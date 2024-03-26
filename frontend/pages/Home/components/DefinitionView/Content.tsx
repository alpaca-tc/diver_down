import { FC } from "react";
import styled from "styled-components";

import { Section } from "@/components/ui";
import { CombinedDefinition } from "@/models/combinedDefinition";

import { Dot } from "./Dot";

type Props = {
  combinedDefinition: CombinedDefinition
}

export const Content: FC<Props> = ({ combinedDefinition }) => (
    <StyledSection>
      {combinedDefinition.ids}
      {combinedDefinition.title}
      <Dot dot={combinedDefinition.dot} />
    </StyledSection>
  )


const StyledSection = styled(Section)`
  height: inherit;
  overflow: scroll;
`
