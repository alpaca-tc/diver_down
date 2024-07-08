import { describe, expect, it } from 'vitest'

import { ascString } from '../sort'

describe('ascString', () => {
  it('sort strings', () => {
    expect(ascString('', 'a')).toEqual(-1)
    expect(ascString('a', '')).toEqual(1)
  })
})
