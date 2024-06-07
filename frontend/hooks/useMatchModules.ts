import { parse, stringify } from '@/utils/queryString'
import { useEffect, useRef, useState } from 'react'
import { useSearchParams } from 'react-router-dom'

export const KEY = 'match_modules'

const encode = (matchModules: string[][]): Record<string, any> => {
  const searchParams = new URLSearchParams(stringify({ [KEY]: matchModules }))
  const entries: { [key: string]: string } = {}

  const keys = [...searchParams.keys()]
  keys.forEach((key: string) => {
    const value = searchParams.get(key)

    if (typeof value === 'string') {
      entries[key] = value
    }
  })

  return entries
}

const isNestedArrayString = (value: any): value is string[][] => {
  return (Array.isArray(value) && value.every((v) => Array.isArray(v) && v.every((s) => typeof s === 'string')))
}

const decode = (searchParams: URLSearchParams): string[][] => {
  const string = searchParams.toString()
  const params = parse(string)

  if (isNestedArrayString(params[KEY])) {
    return params[KEY]
  } else {
    return []
  }
}

export const useMatchModules = () => {
  const [matchModules, setMatchModules] = useState<string[][]>([])
  const initialized = useRef<boolean>(false)
  const [searchParams, setSearchParams] = useSearchParams()

  // Load ids on load
  useEffect(() => {
    if (!initialized.current) {
      try {
        setMatchModules(decode(searchParams))
      } catch (e) {
        setSearchParams((prev) => ({ ...prev, [KEY]: '' }))
      }

      initialized.current = true
    }
  }, [initialized, setMatchModules, searchParams, setSearchParams])

  useEffect(() => {
    if (!initialized.current) return

    setSearchParams((prev) => ({ ...prev, ...encode(matchModules) }))
  }, [matchModules, setSearchParams])

  return [matchModules, setMatchModules] as const
}
