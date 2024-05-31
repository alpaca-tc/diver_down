import { DotMetadata } from '@/models/combinedDefinition'
import React from 'react'

export type HoverDotMetadataContextProps = {
  hoverDotMetadata: DotMetadata | null
  setHoverDotMetadata: React.Dispatch<React.SetStateAction<DotMetadata | null>>
}

export const HoverDotMetadataContext = React.createContext<HoverDotMetadataContextProps>({
  hoverDotMetadata: null,
  setHoverDotMetadata: () => {},
})
