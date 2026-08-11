## Context

See proposal.md — Why. Two scripts now need the identical append-only sync;
duplicating the loop would let them drift.

## Goals / Non-Goals

- **Goals**: one sync implementation, called by both `routine-next` and the
  analyst baseline; fresh tickets pass the analyst gate.
- **Non-Goals**: any change to selection, marking, or lifecycle semantics;
  a standalone sync script (still not earned).

## Decisions

- **`index_sync <ticket-dir> <timestamp>` lives in `lib/index.sh`** beside
  the other single-writer index helpers — the gate baseline mutating the
  index stays within Law 3 because the mutation is the scripts' own
  append-only derivation, identical to what `routine-next` would write a
  phase later.
- **Sync runs after spec-lint** in the baseline: grammar first, so rows are
  only derived from a tree that parses.

## Risks / Trade-offs

- [Gate now writes state] → append-only and idempotent; a second run
  appends nothing.

## Migration Plan

Behavior-preserving for `routine-next`; analyst gate strictly more
permissive (fresh tickets pass). Rollback = revert the merge commit.
