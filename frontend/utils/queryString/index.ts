const isSkipValue = (value: any): boolean => {
  return value === null || value === undefined || (typeof value === 'object' && Object.keys(value).length === 0)
}

const isObject = (value: any): value is Record<any, any> => {
  return typeof value === 'object' && !Array.isArray(value)
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

const stringifyValue = (value: any): any => {
  if (typeof value === 'boolean') {
    return value ? '1' : null
  } else {
    return value
  }
}

export const stringify = (params: Record<string, any>): string => {
  const entries: Array<[string, string]> = []

  Object.entries(params).forEach(([key, value]) => {
    const v = stringifyValue(value)

    if (v !== null && v !== undefined) {
      entries.push(...internalStringify(key, v))
    }
  })

  return entries.map(([key, value]) => `${key}=${value}`).join('&')
}

const paramDepthLimit = 32

class QueryStringParserError extends Error { }
class ParameterTypeError extends QueryStringParserError { }
class ParamsTooDeepError extends QueryStringParserError { }

const normalizeParams = (params: Record<string, any>, name: string, v: any, depth: number = 0): Record<string, any> => {
  if (depth >= paramDepthLimit) {
    throw new ParamsTooDeepError()
  }

  let k: string
  let after: string
  let start: string

  if (!name) {
    // nil name, treat same as empty string (required by tests)
    k = after = ''
  } else if (depth === 0) {
    // Start of parsing, don't treat [] or [ at start of string specially
    const start = name.indexOf('[', 1)
    if (start !== -1) {
      // Start of parameter nesting, use part before brackets as key
      k = name.slice(0, start)
      after = name.slice(start)
    } else {
      // Plain parameter with no nesting
      k = name
      after = ''
    }
  } else if (name.startsWith('[]')) {
    // Array nesting
    k = '[]'
    after = name.slice(2)
  } else if (name.startsWith('[') && (start = name.indexOf(']', 1)) !== -1) {
    // Hash nesting, use the part inside brackets as the key
    k = name.slice(1, start)
    after = name.slice(start + 1)
  } else {
    // Probably malformed input, nested but not starting with [
    // treat full name as key for backwards compatibility.
    k = name
    after = ''
  }

  if (k === '') {
    return params
  }

  if (after === '') {
    if (k === '[]' && depth !== 0) {
      return [v]
    } else {
      params[k] = v
    }
  } else if (after === '[') {
    params[name] = v
  } else if (after === '[]') {
    params[k] ??= []
    if (!Array.isArray(params[k])) {
      throw new ParameterTypeError(`expected Array (got ${typeof params[k]}) for param '${k}'`)
    }
    params[k].push(v)
  } else if (after.startsWith('[]')) {
    // Recognize x[][y] (hash inside array) parameters
    let childKey = ''
    if (
      !(
        after[2] === '[' &&
        after.endsWith(']') &&
        (childKey = after.slice(3, 3 + after.length - 4)) &&
        !childKey.includes('[') &&
        !childKey.includes(']')
      )
    ) {
      // Handle other nested array parameters
      childKey = after.slice(2)
    }
    params[k] ??= []
    if (!Array.isArray(params[k])) {
      throw new ParameterTypeError(`expected Array (got ${typeof params[k]}) for param '${k}'`)
    }

    const last = params[k][params[k].length - 1]
    if (isObject(last) && !paramsHashHasKey(params[k].slice(-1)[0], childKey)) {
      normalizeParams(last, childKey, v, depth + 1)
    } else {
      params[k].push(normalizeParams({}, childKey, v, depth + 1))
    }
  } else {
    params[k] ??= {}
    if (!isObject(params[k])) {
      throw new ParameterTypeError(`expected object (got ${typeof params[k]}) for param '${k}'`)
    }
    params[k] = normalizeParams(params[k], after, v, depth + 1)
  }

  return params
}

const paramsHashHasKey = (hash: { [key: string]: any }, key: string): boolean => {
  if (/\[\]/.test(key)) {
    return false
  }

  const parts = key.split(/[\[\]]+/)
  let currentHash = hash

  for (const part of parts) {
    if (part === '') {
      continue
    }
    if (!isObject(currentHash) || !currentHash.hasOwnProperty(part)) {
      return false
    }

    currentHash = currentHash[part]
  }

  return true
}

export const parse = (queryString: string): Record<string, any> => {
  return [...new URLSearchParams(queryString).entries()].reduce(
    (obj, [key, value]) => {
      return normalizeParams(obj, key, value, 0)
    },
    {} as Record<string, any>,
  )
}
