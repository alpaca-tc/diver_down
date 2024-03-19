import { ReactNode, useState } from "react"
import { ThemeProvider as SmartHRUIThemeProvider } from 'smarthr-ui'
import { ThemeProvider as StyledComponentsThemeProvider } from 'styled-components'
import { SWRConfig } from 'swr'
import 'smarthr-ui/smarthr-ui.css'

import { GlobalStyle, theme } from "@/constants/theme"
import { Notification, NotificationContext } from '@/context/NotificationContext'

export const Provider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [notification, setNotification] = useState<Notification | null>(null)

  return (
    <SmartHRUIThemeProvider theme={theme}>
      <StyledComponentsThemeProvider theme={theme}>
        <SWRConfig value={{
          revalidateOnFocus: false,
          shouldRetryOnError: false,
        }}>
          <GlobalStyle />
          <NotificationContext.Provider value={{ notification, setNotification }}>
            {children}
          </NotificationContext.Provider>
        </SWRConfig>
      </StyledComponentsThemeProvider>
    </SmartHRUIThemeProvider>
  )
}
