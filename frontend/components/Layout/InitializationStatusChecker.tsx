import { FC, useContext, useEffect, useState } from 'react'

import { Notification, NotificationContext } from '@/context/NotificationContext'
import { usePrimitiveLocalStorage } from '@/hooks/useLocalStorage'
import { useInitializationStatus } from '@/repositories/initializationStatusRepository'
import { usePid } from '@/repositories/pidRepository'

const INITIAL_KEY = 'InitializationStatusChecker-closed'

export const InitializationStatusChecker: FC = () => {
  const { setNotification } = useContext(NotificationContext)

  const { pid, error } = usePid()
  const key = pid ? `InitializationStatusChecker-closed-${pid}` : INITIAL_KEY
  const [closed, setClosed] = usePrimitiveLocalStorage<boolean>(key, Boolean)
  const [initialized, setInitialized] = useState<boolean>(false)

  // Stop loading if initialization process is finished
  const { initializationStatus } = useInitializationStatus(initialized || closed ? 0 : 100)

  useEffect(() => {
    if (error) {
      setNotification({
        type: 'error',
        message: `Failed to load definitions! ${JSON.stringify(error.data)}`,
      })
    }
  }, [error, setNotification])

  useEffect(() => {
    if (!initializationStatus || !pid) return

    let notification: Notification | undefined = undefined

    if (initializationStatus.total === initializationStatus.loaded) {
      setInitialized(true)

      notification = {
        type: 'success',
        message: `Successfully loaded ${initializationStatus.loaded} definitions!`,
        onClose: () => setClosed(true),
      }
    } else if (!closed) {
      const progress = Math.round((initializationStatus.loaded / initializationStatus.total) * 100)

      notification = {
        type: 'info',
        message: `Loading definitions... ${progress}% (${initializationStatus.loaded}/${initializationStatus.total})`,
        onClose: () => setClosed(true),
      }
    }

    if (closed) {
      setNotification(null)
    } else if (notification) {
      setNotification(notification)
    }
  }, [pid, closed, setClosed, initializationStatus, setNotification])

  return null
}
