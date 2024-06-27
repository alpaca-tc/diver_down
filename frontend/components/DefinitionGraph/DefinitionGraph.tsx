import { FC, useCallback, useState } from 'react'
import styled from 'styled-components'

import { Button, FaGearIcon, Heading, LineClamp, Section, Stack, Text } from '@/components/ui'
import { color } from '@/constants/theme'
import { CombinedDefinition, DotMetadata, GraphOptions } from '@/models/combinedDefinition'

import { ScrollableSvg } from './ScrollableSvg'

import { HoverDotMetadataContext } from '@/context/HoverMetadataContext'
import { ConfigureGraphOptionsDialog } from '@/components/ConfigureGraphOptionsDialog'
import { DotMetadataDialog, DotMetadataDialogProps } from '@/components/DotMetadataDialog'
import { Loading } from '@/components/Loading'

type Props = {
  combinedDefinition: CombinedDefinition | null
  mutateCombinedDefinition: () => void
  graphOptions: GraphOptions
  setGraphOptions: React.Dispatch<React.SetStateAction<GraphOptions>>
}

const SOURCES_LIMIT = 3000

export const DefinitionGraph: FC<Props> = ({ combinedDefinition, mutateCombinedDefinition, graphOptions, setGraphOptions }) => {
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
            {(combinedDefinition?.titles ?? []).map((title, index) => (
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
          {!combinedDefinition ? (
            <CenterStack>
              <Loading text="Loading..." alt="Loading" />
            </CenterStack>
          ) : combinedDefinition.dotMetadata.length > SOURCES_LIMIT ? (
            <Text size="S">
              Unable to render the graph due to performance issues. The maximum number of elements is {SOURCES_LIMIT}, but you are
              trying to render {combinedDefinition.dotMetadata.length} elements. Please reduce the number of elements by narrowing
              down the modules from "Open Graph Options".
            </Text>
          ) : (
            <ScrollableSvg combinedDefinition={combinedDefinition} setOpenedDotMetadataDialog={setOpenedDotMetadataDialog} />
          )}
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

const CenterStack = styled(Stack)`
  display: flex;
  flex-direction: row;
  height: inherit;
  justify-content: center;
`
