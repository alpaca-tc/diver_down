import React, { ComponentProps, useCallback, useContext } from 'react'
import { useLocation, useNavigate } from 'react-router-dom'
import styled from 'styled-components'

import {
  AppNavi,
  NotificationBar,
} from '@/components/ui'
import { NotificationContext } from "@/context/NotificationContext"

export const Header: React.FC = () => {
  const { notification, setNotification } = useContext(NotificationContext)
  const { pathname } = useLocation()
  const navigate = useNavigate()

  const onCloseNotification = useCallback(() => {
    if (notification?.onClose) {
      notification.onClose()
    }

    setNotification(null)
  }, [notification, setNotification])

  const buttons: ComponentProps<typeof AppNavi>['buttons'] = [
    {
      children: 'Home',
      current: pathname === '/',
      onClick: () => navigate('/'),
    },
  ]

  return (
    <>
      <header>
        <StyledAppNavi label="DiverDown" buttons={buttons} />
      </header>

      {notification && (
        <NotificationBar type={notification.type} message={notification.message} onClose={onCloseNotification} />
      )}
    </>
  )
}

const StyledAppNavi = styled(AppNavi)`
  min-height: 40px;
`
