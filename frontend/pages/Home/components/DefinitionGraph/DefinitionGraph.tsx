import { FC, useEffect, useState } from 'react'
import styled from 'styled-components'

import { Heading, LineClamp, Section, Text } from '@/components/ui'
import { color } from '@/constants/theme'
import { CombinedDefinition } from '@/models/combinedDefinition'
import { renderDot } from '@/utils/renderDot'

import { ScrollableSvg } from './ScrollableSvg'

type Props = {
  combinedDefinition: CombinedDefinition
}

export const DefinitionGraph: FC<Props> = ({ combinedDefinition }) => {
  const [svg, setSvg] = useState<string>('')

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

  return (
    <WrapperSection>
      <FixedHeightHeading type="sectionTitle">
        <LineClamp>
          {combinedDefinition.titles.map((title, index) => (
            <BlockText key={index} size="XXS">
              {title}
            </BlockText>
          ))}
        </LineClamp>
      </FixedHeightHeading>
      <FlexHeightSvgWrapper>
        <ScrollableSvg svg={svg} />
      </FlexHeightSvgWrapper>
    </WrapperSection>
  )
}

const WrapperSection = styled(Section)`
  display: flex;
  flex-direction: column;
  height: inherit;
  flex-grow: 1;
`

const FixedHeightHeading = styled(Heading)`
  min-height: 60px;
  overflow: scroll;
  border-bottom: ${color.BORDER} 1px solid;
`

const FlexHeightSvgWrapper = styled.div`
  height: calc(100% - 60px);
`

const BlockText = styled(Text)`
  display: block;
`
