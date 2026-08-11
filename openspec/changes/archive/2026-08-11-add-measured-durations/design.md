## Context

See proposal.md — Why. The original design deferred precision "until retro
evidence asks"; the retro asking for meaningful duration stats is that ask.

## Goals / Non-Goals

- **Goals**: one clock helper; every `ms` measured; graceful degradation.
- **Non-Goals**: sub-millisecond precision; monotonic-clock guarantees
  (epoch time is fine for coarse retro stats); backfilling old telemetry.

## Decisions

- **Runtime detection over configuration**: `date +%s%N` either prints
  digits (GNU) or a trailing literal `N` (BSD); one case statement decides,
  no flags, no probing at install time.
- **Helper lives in `lib/telemetry.sh`** beside the emitter it serves.

## Risks / Trade-offs

- [Mixed precision across platforms in one retro] → acceptable: p50/p95 of
  mostly-zero macOS values degrade to what they were before; Linux (CI and
  most operation) gains real numbers.

## Migration Plan

Additive helper + call-site swaps; telemetry format unchanged.
Rollback = revert the merge commit.
