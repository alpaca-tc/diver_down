import { FC, useContext, useEffect, useState } from "react"

import { NotificationContext } from "@/context/NotificationContext"
import { useInitializationStatus } from "@/repositories/initializationStatusRepository"

export const InitializationStatusChecker: FC = () => {
  const { setNotification } = useContext(NotificationContext)

  const [closed, setClosed] = useState<boolean>(false)
  const [initialized, setInitialized] = useState<boolean>(false)

  // Stop loading if initialization process is finished
  const { initializationStatus } = useInitializationStatus((initialized || closed) ? 0 : 100)

  useEffect(() => {
    if (!initializationStatus) return;

    if (initializationStatus.total === initializationStatus.loaded) {
      setInitialized(true)

      if (!closed) {
        setNotification(
          {
            type: 'success',
            message: `Successfully loaded ${initializationStatus.loaded} definitions!`,
            onClose: () => setClosed(true)
          }
        )
      }
    } else if (!closed) {
      const progress = Math.round(initializationStatus.loaded / initializationStatus.total * 100)

      setNotification(
        {
          type: 'info',
          message: `Loading definitions... ${progress}% (${initializationStatus.loaded}/${initializationStatus.total})`,
          onClose: () => setClosed(true)
        }
      )
    }
  }, [closed, initializationStatus, setNotification])

  return null
}
