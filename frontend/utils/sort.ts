export const ascString = (a: string, b: string) => {
  if (a > b) return 1
  if (a < b) return -1
  return 0
}

export const ascNumber = (a: number, b: number) => {
  return a - b
}

export const sortTypes = ['asc', 'desc', 'none'] as const

export type SortTypes = (typeof sortTypes)[number]
