import { FC, useCallback, useState } from 'react'
import styled from 'styled-components'

import { Button, FaGearIcon, Heading, LineClamp, Section, Text } from '@/components/ui'
import { color } from '@/constants/theme'
import { CombinedDefinition, DotMetadata } from '@/models/combinedDefinition'

import { ConfigureGraphOptionsDialog, GraphOptions } from '../ConfigureGraphOptionsDialog'

import { ScrollableSvg } from './ScrollableSvg'

import { HoverDotMetadataContext } from '@/context/HoverMetadataContext'
import { DotMetadataDialog, DotMetadataDialogProps } from '../DotMetadataDialog'

type Props = {
  combinedDefinition: CombinedDefinition
  mutateCombinedDefinition: () => void
  graphOptions: GraphOptions
  setGraphOptions: React.Dispatch<React.SetStateAction<GraphOptions>>
}

export const DefinitionGraph: FC<Props> = ({
  combinedDefinition,
  mutateCombinedDefinition,
  graphOptions,
  setGraphOptions,
}) => {
  const [hoverDotMetadata, setHoverDotMetadata] = useState<DotMetadata | null>(null)
  const [openedDotMetadataDialog, setOpenedDotMetadataDialog] = useState<DotMetadataDialogProps | null>(null)
  const [openedConfigureGraphOptionsDialog, setOpenedConfigureGraphOptionsDialog] = useState<boolean>(false)

  const onCloseConfigureGraphOptionsDialog = useCallback(() => {
    setOpenedConfigureGraphOptionsDialog(false)
  }, [setOpenedConfigureGraphOptionsDialog])

  const onCloseDotMetadataDialog = useCallback(() => {
    setOpenedDotMetadataDialog(null)
  }, [setOpenedDotMetadataDialog])

  return (
    <HoverDotMetadataContext.Provider value={{ hoverDotMetadata, setHoverDotMetadata }}>
      <WrapperSection>
        <ConfigureGraphOptionsDialog
          isOpen={openedConfigureGraphOptionsDialog}
          onClickClose={onCloseConfigureGraphOptionsDialog}
          graphOptions={graphOptions}
          setGraphOptions={setGraphOptions}
        />
        <DotMetadataDialog
          dotMetadata={openedDotMetadataDialog?.dotMetadata ?? null}
          top={openedDotMetadataDialog ? openedDotMetadataDialog.top : 0}
          left={openedDotMetadataDialog ? openedDotMetadataDialog.left : 0}
          onClose={onCloseDotMetadataDialog}
          mutateCombinedDefinition={mutateCombinedDefinition}
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
            onClick={() => setOpenedConfigureGraphOptionsDialog(true)}
            prefix={<FaGearIcon alt="Open Options" />}
          >
            Open Graph Options
          </Button>
        </FixedHeightHeading>
        <FlexHeightSvgWrapper>
          <ScrollableSvg combinedDefinition={combinedDefinition} setOpenedDotMetadataDialog={setOpenedDotMetadataDialog} />
        </FlexHeightSvgWrapper>
      </WrapperSection>
    </HoverDotMetadataContext.Provider>
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
