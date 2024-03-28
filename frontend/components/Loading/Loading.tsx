import { FC } from 'react'
import styled from 'styled-components'

import { Loader } from '@/components/ui'

export const Loading: FC<{ text?: string; alt?: string }> = ({ text = 'Loading...', alt = 'Loading' }) => (
  <LoaderWrapper>
    <Loader text={text} size="m" alt={alt} />
  </LoaderWrapper>
)

const LoaderWrapper = styled.div`
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
`
