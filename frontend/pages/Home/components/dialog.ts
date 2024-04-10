import { DotMetadata } from '@/models/combinedDefinition'

type ConfigureGraphOptionsDialogProps = {
  type: 'configureGraphOptionsDialog'
}

type MetadataDialogProps = {
  type: 'metadataDialog'
  metadata: DotMetadata
  top: number
  left: number
}

export type DialogProps = ConfigureGraphOptionsDialogProps | MetadataDialogProps
