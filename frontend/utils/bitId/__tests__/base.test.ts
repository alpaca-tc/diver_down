import { describe, expect, it } from 'vitest'

import { bitIdToIds, idsToBitId } from '..'

describe('bitIdToIds', () => {
  it('converts bit_id to ids', () => {
    const ids = Array.from({ length: 100 }, (_, i) => i + 1)
    const bitIds = ids.map((id) => BigInt(idsToBitId([id])))
    const intOr = bitIds.reduce((current, bitId) => current | bitId, 0n)

    expect(bitIdToIds(intOr)).toEqual(ids)
  })
})

describe('idsToBitId', () => {
  it('converts ids to bitId', () => {
    expect(idsToBitId([1])).toEqual(1n)
    expect(idsToBitId([2])).toEqual(2n)
    expect(idsToBitId([3])).toEqual(4n)
    expect(idsToBitId([4])).toEqual(8n)

    expect(idsToBitId([])).toEqual(0n)
    expect(idsToBitId([1, 4])).toEqual(9n)
    expect(idsToBitId([1, 2, 3, 4])).toEqual(15n)
  })
})
