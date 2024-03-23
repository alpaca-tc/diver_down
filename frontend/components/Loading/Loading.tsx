import { FC } from 'react'
import styled from 'styled-components'

import { Loader } from '@/components/ui'

export const Loading: FC = () => (
  <LoaderWrapper>
    <Loader text="Loading..." size="m" alt="Loading" />
  </LoaderWrapper>
)

const LoaderWrapper = styled.div`
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
`
