import { describe, expect, it } from 'vitest'
import { fairOdd, valueBand, valueIndex } from '../value'
import { DEFAULT_CONFIDENCE_ANCHORS, probabilityFor } from '../confidence'

describe('value', () => {
  it('computes the fair odd from a probability', () => {
    expect(fairOdd(0.65)).toBeCloseTo(1.538, 3)
    expect(() => fairOdd(0)).toThrow(RangeError)
  })

  it('flags a level 3 pick at 1.80 as favourable', () => {
    const index = valueIndex(probabilityFor(3), 1.8)
    expect(index).toBeCloseTo(1.17, 2)
    expect(valueBand(index)).toBe('favourable')
  })

  it('flags a level 4 pick at 1.25 as unfavourable', () => {
    expect(valueBand(valueIndex(DEFAULT_CONFIDENCE_ANCHORS[4], 1.25))).toBe('unfavourable')
  })

  it('treats values near 1 as neutral', () => {
    expect(valueBand(1)).toBe('neutral')
    expect(valueBand(1.05)).toBe('neutral')
    expect(valueBand(0.95)).toBe('neutral')
  })
})
