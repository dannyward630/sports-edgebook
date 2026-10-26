export type ValueBand = 'favourable' | 'neutral' | 'unfavourable'

/** Odd that pays exactly break-even for a given probability. */
export function fairOdd(probability: number): number {
  if (probability <= 0 || probability > 1) throw new RangeError('probability must be in (0, 1]')
  return 1 / probability
}

/** p × odd: above 1 means the odd pays more than your read of the event justifies. */
export function valueIndex(probability: number, odd: number): number {
  return probability * odd
}

export function valueBand(index: number): ValueBand {
  if (index > 1.05) return 'favourable'
  if (index < 0.95) return 'unfavourable'
  return 'neutral'
}
