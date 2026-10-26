# Multiples generator

Pure TypeScript in `src/domain/` (fully unit-tested). Picks from pending predictions in a date window (default: today) and returns legs, total odd, combined probability and expected value.

| Mode | Ordering |
| --- | --- |
| `confidence` | highest confidence level; tie-break highest odd |
| `value` | highest value index (p × odd) |
| `highest_odds` | highest odd |
| `lowest_odds` | lowest odd |
| `random` | shuffle, optional seed to reproduce |
| `target_odd` | combination whose total odd is closest to the target, preferring better value |

Parameters: number of legs **or** target odd (with tolerance, e.g. ±10%), minimum confidence, min/max odd per leg, league and market filters, include non-punter only or all.

Rules:

- At most one leg per event (correlation; bookmakers often refuse same-game legs).
- `target_odd`: search in log space (sum of log(odd) towards log(target)) with beam search.
- Always show combined probability (product of leg probabilities, assuming independence) and EV = p × odd − 1.
- Regenerate, swap a leg manually, then save as simulated (`is_placed = false`) or placed (with stake).
