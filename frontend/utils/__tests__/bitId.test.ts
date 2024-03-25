import { describe, expect, it } from 'vitest';

import { bitIdToIds, idsToBitId } from "../bitId"

describe('bitIdToIds', () => {
  it('converts bit_id to ids', () => {
    const ids = Array.from({length: 100}, (_, i) => i + 1)
    const bitIds = ids.map((id) => BigInt(idsToBitId([id])))
    const intOr = bitIds.reduce((current, bitId) => current | bitId, 0n)

    expect(bitIdToIds(String(intOr))).toEqual(ids)
  })
})

describe('idsToBitId', () => {
  it('converts ids to bitId', () => {
    expect(idsToBitId([1])).toEqual('1')
    expect(idsToBitId([2])).toEqual('2')
    expect(idsToBitId([3])).toEqual('4')
    expect(idsToBitId([4])).toEqual('8')

    expect(idsToBitId([])).toEqual('0')
    expect(idsToBitId([1, 4])).toEqual('9')
    expect(idsToBitId([1, 2, 3, 4])).toEqual('15')
  })
})
