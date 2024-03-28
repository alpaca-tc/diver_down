export const groupBy = <T>(array: readonly T[], prop: (v: T) => string) =>
  array.reduce((groups: { [key: string]: T[] }, item) => {
    const val = prop(item)
    groups[val] = groups[val] ?? []
    groups[val].push(item)

    return groups
  }, {})
