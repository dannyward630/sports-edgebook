export type BetStatus = 'pending' | 'won' | 'lost' | 'void'

/** Profit in units for a single bet; null while it is still pending. */
export function betProfit(stakeUnits: number, odd: number, status: BetStatus): number | null {
  switch (status) {
    case 'pending':
      return null
    case 'won':
      return stakeUnits * (odd - 1)
    case 'lost':
      return -stakeUnits
    case 'void':
      return 0
  }
}

export interface MultipleLeg {
  odd: number
  status: BetStatus
}

/** Lost if any leg lost; void legs count as odd 1.00; won once every other leg won. */
export function multipleStatus(legs: MultipleLeg[]): BetStatus {
  if (legs.some((leg) => leg.status === 'lost')) return 'lost'
  if (legs.some((leg) => leg.status === 'pending')) return 'pending'
  if (legs.every((leg) => leg.status === 'void')) return 'void'
  return 'won'
}

export function multipleOdd(legs: MultipleLeg[]): number {
  return legs.reduce((total, leg) => total * (leg.status === 'void' ? 1 : leg.odd), 1)
}

export function unitsToCurrency(units: number, unitValue: number): number {
  return units * unitValue
}
