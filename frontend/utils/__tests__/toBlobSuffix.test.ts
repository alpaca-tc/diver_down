import { describe, expect, it } from 'vitest'

import { toBlobSuffix } from '../toBlobSuffix'

describe('toBlobSuffix', () => {
  it('returns github style line', () => {
    expect(toBlobSuffix('app.rb:2')).toEqual('app.rb#L2')
  })

  it('returns raw string if it contains multiple :', () => {
    expect(toBlobSuffix('app.rb:2:2')).toEqual('app.rb:2#L2')
  })
})
