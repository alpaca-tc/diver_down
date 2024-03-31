import { FC, useState } from 'react'
import { Outlet } from 'react-router-dom'
import { ThemeProvider as SmartHRUIThemeProvider } from 'smarthr-ui'
import styled, { ThemeProvider as StyledComponentsThemeProvider } from 'styled-components'
import { SWRConfig } from 'swr'

import { GlobalStyle, theme } from '@/constants/theme'
import 'smarthr-ui/smarthr-ui.css'
import { Notification, NotificationContext } from '@/context/NotificationContext'

import { Loading } from '../Loading'

import { Header } from './Header'
import { InitializationStatusChecker } from './InitializationStatusChecker'

type Props = {
  isLoading: boolean
}

export const Layout: FC<Props> = ({ isLoading }) => {
  const [notification, setNotification] = useState<Notification | null>(null)

  return (
    <SmartHRUIThemeProvider theme={theme}>
      <StyledComponentsThemeProvider theme={theme}>
        <SWRConfig
          value={{
            revalidateOnFocus: false,
            shouldRetryOnError: false,
          }}
        >
          <NotificationContext.Provider value={{ notification, setNotification }}>
            <GlobalStyle />
            <InitializationStatusChecker />

            {isLoading ? (
              <Loading text="Loading..." alt="Loading" />
            ) : (
              <>
                <Header />
                <Wrapper>
                  <Outlet />
                </Wrapper>
              </>
            )}
          </NotificationContext.Provider>
        </SWRConfig>
      </StyledComponentsThemeProvider>
    </SmartHRUIThemeProvider>
  )
}

const Wrapper = styled.div`
  /* for boarder */
  padding-top: 1px;

  /* 40px is the height of the header */
  height: calc(100% - 40px - 1px);
`
