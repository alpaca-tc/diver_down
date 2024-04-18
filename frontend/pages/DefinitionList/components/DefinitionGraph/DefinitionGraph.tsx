import { FC, useCallback } from 'react'
import styled from 'styled-components'

import { Button, FaGearIcon, Heading, LineClamp, Section, Text } from '@/components/ui'
import { color } from '@/constants/theme'
import { CombinedDefinition } from '@/models/combinedDefinition'

import { ConfigureGraphOptionsDialog, GraphOptions } from '../ConfigureGraphOptionsDialog'

import { ScrollableSvg } from './ScrollableSvg'

import type { DialogProps } from '../dialog'

type Props = {
  combinedDefinition: CombinedDefinition
  visibleDialog: DialogProps | null
  setVisibleDialog: React.Dispatch<React.SetStateAction<DialogProps | null>>
  graphOptions: GraphOptions
  setGraphOptions: React.Dispatch<React.SetStateAction<GraphOptions>>
}

export const DefinitionGraph: FC<Props> = ({
  combinedDefinition,
  graphOptions,
  setGraphOptions,
  visibleDialog,
  setVisibleDialog,
}) => {
  const onClickCloseDialog = useCallback(() => {
    setVisibleDialog(null)
  }, [setVisibleDialog])

  return (
    <WrapperSection>
      <ConfigureGraphOptionsDialog
        isOpen={visibleDialog?.type === 'configureGraphOptionsDialog'}
        onClickClose={onClickCloseDialog}
        graphOptions={graphOptions}
        setGraphOptions={setGraphOptions}
      />
      <FixedHeightHeading type="sectionTitle">
        <LineClamp>
          {combinedDefinition.titles.map((title, index) => (
            <BlockText key={index} size="XXS">
              {title}
            </BlockText>
          ))}
        </LineClamp>
        <Button
          size="s"
          square
          onClick={() => setVisibleDialog({ type: 'configureGraphOptionsDialog' })}
          prefix={<FaGearIcon alt="Open Options" />}
        >
          Open Graph Options
        </Button>
      </FixedHeightHeading>
      <FlexHeightSvgWrapper>
        <ScrollableSvg combinedDefinition={combinedDefinition} setVisibleDialog={setVisibleDialog} />
      </FlexHeightSvgWrapper>
    </WrapperSection>
  )
}

const WrapperSection = styled(Section)`
  display: flex;
  flex-direction: column;
  height: inherit;
  flex-grow: 1;
  width: 1px; /* flex width */
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
