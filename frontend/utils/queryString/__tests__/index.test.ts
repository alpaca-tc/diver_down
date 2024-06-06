import { describe, expect, it } from 'vitest'

import { stringify } from '..'

describe('stringify', () => {
  it('converts simple values to params', () => {
    expect(stringify({ a: 1 })).toEqual('a=1')
    expect(stringify({ a: '1' })).toEqual('a=1')
    expect(stringify({ a: null })).toEqual('')
    expect(stringify({ a: undefined })).toEqual('')
    expect(stringify({ a: 1, b: 2 })).toEqual('a=1&b=2')
  })

  it('converts object values to params', () => {
    expect(stringify({ a: {} })).toEqual('')
    expect(stringify({ a: [] })).toEqual('')
    expect(stringify({ a: [1] })).toEqual('a[]=1')
    expect(stringify({ a: [1, 2] })).toEqual('a[]=1&a[]=2')
    expect(stringify({ a: { b: 1 } })).toEqual('a[b]=1')
    expect(stringify({ a: [{ b: 1 }] })).toEqual('a[][b]=1')
    expect(stringify({ a: { b: { c: [1] } } })).toEqual('a[b][c][]=1')
  })
})
