import { isArray } from "util"

const isSkipValue = (value: any): boolean => {
  return (
    value === null ||
    value === undefined ||
    (typeof value === 'object' && Object.keys(value).length === 0)
  )
}

const internalStringify = (key: string, value: any): Array<[string, string]> => {
  const entries: Array<[string, string]> = []

  if (isSkipValue(value)) {
    return entries
  } else if (Array.isArray(value)) {
    value.forEach((v) => {
      entries.push(...internalStringify(`${key}[]`, v))
    })
  } else if (typeof value === 'object') {
    Object.entries(value).forEach(([k, v]) => {
      entries.push(...internalStringify(`${key}[${k}]`, v))
    })
  } else {
    entries.push([key, value])
  }

  return entries
}

export const stringify = (params: Record<string, any>): string => {
  const entries: Array<[string, string]> = []

  Object.entries(params).forEach(([key, value]) => {
    entries.push(...internalStringify(key, value))
  })

  return entries.map(([key, value]) => `${key}=${value}`).join('&')
}
