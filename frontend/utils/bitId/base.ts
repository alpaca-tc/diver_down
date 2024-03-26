export const bitIdToIds = (bitId: bigint): number[] => {
  const ids: number[] = []
  let shift = 0

  while (bitId > 0n) {
    if (bitId & 1n) {
      ids.push(shift + 1)
    }

    bitId >>= 1n
    shift += 1
  }

  return ids
}

const idToBitId = (id: number): bigint => 1n << BigInt(id - 1)

export const idsToBitId = (ids: number[]): bigint => {
  const bitId = ids.reduce((current, id) => current | idToBitId(id), 0n)
  return bitId
}
