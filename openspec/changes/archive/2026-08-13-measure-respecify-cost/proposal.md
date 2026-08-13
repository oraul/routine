## Why

Every grounding extension this council weighed ultimately hangs on one
unmeasured number: what a re-specify episode actually costs. Without
it, no future grounding section can be earned or refuted with evidence
(Law 2's feedback loop is the retro, and the retro is silent here).
The telemetry already carries everything needed — spec.defective marks
each episode boundary, spec.lint carries the failures, timestamps carry
the recovery time.

## What Changes

- **`bin/routine-retro` gains a "re-specify cost" section**, computed
  on demand from existing telemetry — no new state, no new events, the
  retro stays a pure reader. Per app+ticket (the blocked-seconds key
  discipline — ticket ids collide across apps): specify episodes
  (1 + `spec.defective` count), total and worst-episode failed
  `spec.lint` runs counted with exactly the gate's semantics (the
  per-episode counter resets on `spec.defective`), and recovery
  seconds from each `spec.defective` to the next passing `spec.lint`
  (an unrecovered defect prints as such). Only tickets with cost
  appear.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `retro`: the report carries the re-specify cost section.

## Impact

- Modified: `bin/routine-retro`, `test/retro.bats`.
