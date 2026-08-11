## Why

A ticket needs a scripted ending — evidence-checked, reported, archived — and
the whole tool needs its feedback loop: the retro that turns accumulated
telemetry into the plain-text evidence every future abstraction must be
earned from.

## What Changes

- Add `bin/routine-conclude <ticket-dir>`: refuses unless the index shows
  every task `done`; writes `report.md` summarizing the run from the index;
  emits `ticket.conclude`; moves the ticket to `tickets/archive/<id>/`.
- Add `bin/routine-retro`: aggregates
  `runs/*/tickets/{,archive/}*/telemetry.jsonl` into a plain-text report —
  runs and fail counts per event, duration min/p50/p95/max per event, fail
  counts per script, and time-in-blocked per task. Computes on demand,
  stores nothing.

## Capabilities

### New Capabilities

- `retro`: the aggregation contract — inputs, computed metrics, and the
  compute-don't-store rule.

### Modified Capabilities

- `tickets`: gains the conclude requirement (all-done check, `report.md`,
  archive move, `ticket.conclude` event).

## Impact

- New: `bin/routine-conclude`, `bin/routine-retro`, bats suites, fixture
  telemetry files.
- `routine-ticket-new` already skips archived ids, so concluded tickets slot
  into the existing allocation rule.
