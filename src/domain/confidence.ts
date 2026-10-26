export const CONFIDENCE_LEVELS = [1, 2, 3, 4, 5] as const

export type ConfidenceLevel = (typeof CONFIDENCE_LEVELS)[number]

export type ConfidenceAnchors = Record<ConfidenceLevel, number>

/** Probability each confidence level stands for. Configurable per user; recalibrated from history. */
export const DEFAULT_CONFIDENCE_ANCHORS: ConfidenceAnchors = {
  1: 0.4,
  2: 0.55,
  3: 0.65,
  4: 0.75,
  5: 0.85,
}

export const CONFIDENCE_LABELS: Record<ConfidenceLevel, string> = {
  1: 'Palpite',
  2: 'Moderada',
  3: 'Boa',
  4: 'Alta',
  5: 'Muito alta',
}

export function probabilityFor(
  level: ConfidenceLevel,
  anchors: ConfidenceAnchors = DEFAULT_CONFIDENCE_ANCHORS,
): number {
  return anchors[level]
}
