## Why

The first end-to-end run surfaced a sequencing flaw: index rows are only
created by `routine-next`, which the protocol runs after approve — so the
analyst gate's index/tree coherence check is guaranteed to fail on every
fresh ticket. The gate must see the index the way `routine-next` would.

## What Changes

- Extract the append-only index sync from `bin/routine-next` into a shared
  `index_sync` helper in `lib/index.sh`.
- The analyst gate baseline runs `index_sync` before checking coherence, so
  a fresh, well-formed ticket is coherent by construction; stale rows
  pointing at missing directories still fail.
- `routine-next` behavior is unchanged (it now calls the shared helper).

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `gates`: the analyst baseline requirement gains the sync-before-check
  step.

## Impact

- Modified: `lib/index.sh`, `bin/routine-next`, `bin/routine-gate`,
  `test/gate.bats`.
- Found by evidence (first operational run), not speculation.
