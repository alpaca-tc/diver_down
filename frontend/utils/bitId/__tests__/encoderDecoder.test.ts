import { describe, expect, it } from 'vitest';

import { decode, encode } from ".."

describe('encode', () => {
  const testCases: Array<[bigint, string]> = [
    [0n, 'A'],
    [1n, 'B'],
    [13029n, 'DLl'],
    [11n, 'L'],
    [10000n, 'CcQ'],
    [BigInt('10195092303920935493'), 'I18Pm87hrJF'],
  ]

  it('encodes bitId', () => {
    testCases.forEach(([input, expected]) => {
      expect(encode(input)).toEqual(expected)
    })
  })
})

describe('decodes', () => {
  const testCases: bigint[] = [
    0n,
    1n,
    13029n,
    11n,
    10000n,
    BigInt('10195092303920935493'),
  ]

  it('decodes encoded value', () => {
    testCases.forEach((input) => {
      expect(decode(encode(input))).toEqual(input)
    })
  })
})
