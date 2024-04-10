type ErrorResponse = {
  // TODO: Render error on backend
  messages: string[]
}

export class HTTPError extends Error {
  status: number
  data: ErrorResponse

  constructor(response: Response, data: ErrorResponse) {
    super(`HTTP Error: ${response.statusText}`)
    this.status = response.status
    this.data = data
  }
}

const parseResponse = (response: Response): void | Promise<any> => {
  if (!response.ok) {
    return response.json().then((data) => {
      throw new HTTPError(response, data)
    })
  }

  if (response.status === 200) return response.json()
  return
}

export const get = async <T>(url: string): Promise<T> => {
  const response = await fetch(url)

  if (url.endsWith('.json') && response.headers.get('content-type') !== 'application/json') {
    throw new HTTPError(response, { messages: ['content-type is invalid'] })
  }

  return parseResponse(response)
}

export const post = async <T>(url: string, data: Record<string, any> | FormData): Promise<T> => {
  const body = data instanceof FormData ? data : JSON.stringify(data)
  const headers: RequestInit['headers'] = data instanceof FormData ? {} : { 'Content-Type': 'application/json; charset=utf-8' }

  const response = await fetch(url, {
    method: 'POST',
    body,
    headers,
  })

  return parseResponse(response)
}
