import React  from 'react'

export type Notification = {
  type: 'success' | 'info' | 'warning' | 'error'
  message: string
  onClose: () => void
}

export type NotificationContextProps = {
  notification: Notification | null
  setNotification: React.Dispatch<React.SetStateAction<Notification | null>>
}

export const NotificationContext = React.createContext<NotificationContextProps>({
  notification: null,
  setNotification: () => {},
})
