import { Dispatch, SetStateAction, useCallback, useLayoutEffect, useRef, useState } from 'react'

type DeserializeValue<T> = { [key in keyof T]: (v: T[key] | null) => T[key] } | ((v: any) => T)
type Value = Record<string, unknown> | boolean

const deserializer = JSON.parse
const serializer = JSON.stringify

const getInitialState = <T extends Value>(
  value: Record<string, unknown>,
  deserializeValue: DeserializeValue<T>,
): T => {
  if (typeof deserializeValue === 'function') {
    return deserializeValue(value)
  } else {
    return Object.entries(deserializeValue).reduce((acc, [key, deserialize]) => {
      return { ...acc, [key]: deserialize(value[key]) }
    }, {} as T)
  }
}

const useLocalStorage = <T extends Value>(
  key: string,
  deserializeValue: DeserializeValue<T>,
): [T, Dispatch<SetStateAction<T>>, () => void] => {
  if (!key) {
    throw new Error('useLocalStorage key may not be falsy')
  }

  // eslint-disable-next-line react-hooks/rules-of-hooks
  const initializer = useRef((keystring: string): T => {
    try {
      const localStorageValue = localStorage.getItem(keystring)
      const deserialized = deserializer(localStorageValue!)

      return getInitialState(deserialized, deserializeValue)
    } catch {
      try {
        localStorage.removeItem(key)
      } catch {
        // If user is in private mode or has storage restriction
      }

      return getInitialState({}, deserializeValue)
    }
  })

  // eslint-disable-next-line react-hooks/rules-of-hooks
  const [state, setState] = useState<T>(() => initializer.current(key))

  // eslint-disable-next-line react-hooks/rules-of-hooks
  useLayoutEffect(() => setState(initializer.current(key)), [key])

  // eslint-disable-next-line react-hooks/rules-of-hooks
  const set: Dispatch<SetStateAction<T>> = useCallback(
    (valOrFunc) => {
      try {
        const newState = typeof valOrFunc === 'function' ? (valOrFunc as (prev: T) => T)(state) : valOrFunc
        if (typeof newState === 'undefined') return

        const value = serializer(newState)

        localStorage.setItem(key, value)
        setState(deserializer(value))
      } catch {
        // If user is in private mode or has storage restriction
        // localStorage can throw. Also JSON.stringify can throw.
      }
    },
    [key, setState, state],
  )

  // eslint-disable-next-line react-hooks/rules-of-hooks
  const remove = useCallback(() => {
    try {
      localStorage.removeItem(key)
      setState(getInitialState({}, deserializeValue))
    } catch {
      // If user is in private mode or has storage restriction
      // localStorage can throw.
    }
  }, [key, deserializeValue, setState])

  return [state, set, remove]
}

export { useLocalStorage }
