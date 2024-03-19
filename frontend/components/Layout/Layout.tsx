import { FC } from 'react'
import { Outlet } from 'react-router-dom'
import styled from 'styled-components'

import { spacing } from '@/constants/theme'

import { Header } from './Header'
import { Loading } from './Loading'
import { Provider } from './Provider'

type Props = {
  isLoading: boolean
}

export const Layout: FC<Props> = ({ isLoading }) => {
  if (isLoading) {
    return <Loading />
  }

  return (
    <Provider>
      <Header />

      <Wrapper>
        <Outlet />
      </Wrapper>
    </Provider>
  )
}

const Wrapper = styled.div`
  padding: ${spacing.XS};
`
