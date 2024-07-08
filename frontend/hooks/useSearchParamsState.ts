import { parse, stringify } from '@/utils/queryString'
import { useEffect, useState } from 'react'
import { useSearchParams } from 'react-router-dom'

type DeserializeSearchParams<T> = { [urlParam in keyof T]: (v: T[urlParam] | null) => T[urlParam] }

const getInitialState = <T extends Record<string, unknown>>(
  searchParams: Record<string, unknown>,
  deserializeSearchParams: DeserializeSearchParams<T>,
): T => {
  return Object.entries(deserializeSearchParams).reduce((acc, [key, deserialize]) => {
    return { ...acc, [key]: deserialize(searchParams[key]) }
  }, {} as T)
}

export const useSearchParamsState = <T extends Record<string, unknown>>(deserializeSearchParams: DeserializeSearchParams<T>) => {
  const [searchParams, setSearchParams] = useSearchParams()
  const [state, setState] = useState<T>(() => getInitialState(parse(searchParams.toString()), deserializeSearchParams))

  useEffect(() => {
    setSearchParams(new URLSearchParams(stringify(state)))
  }, [state, setSearchParams])

  return [state, setState] as const
}
