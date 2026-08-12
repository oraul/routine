## Why

The council found the evidence trail has holes exactly where the loop
claims rigor: gate events carry empty `ticket`/`task` fields (the wrapper
reads env vars nobody sets); lifecycle refusals exit without a line, so a
refused transition is indistinguishable from one never attempted;
scaffold and deps leave no trace at all; TDD's red→green discipline is
asserted in prose but recorded nowhere; and retro pairs block/unblock
lines by ticket+task across apps, so colliding ticket ids silently merge.

## What Changes

- **Attribution is derived, never passed**: ticket-bound telemetry
  carries the ticket directory's basename as `ticket` and the
  `in_progress` index row's id as `task` when one exists.
- **Refusals leave evidence**: `routine-done`, `routine-block`,
  `routine-unblock`, `routine-next` (including exits 3 and 4), and
  `routine-conclude` emit their event with the real exit code before a
  refusal exit — usage errors without a valid ticket dir excepted.
- **App-level evidence**: `routine-scaffold` emits `app.scaffold` and
  `routine-deps` emits `app.deps` to `runs/<app>/telemetry.jsonl`; deps
  skips emission when no app state exists (never invents a destination).
- **`bin/routine-tdd <red|green> <scenario> -- <command>`** (new
  capability `tdd`): runs the command, emits `tdd.red`/`tdd.green` with
  the scenario riding the `script` field and the command's exit code, and
  enforces the phase — a passing command under `red` is refused, a
  failing one under `green` relays its exit.
- **Retro gains the app dimension**: blocked-seconds pairing is scoped
  per app, so the same ticket id in two apps never cross-pairs.

## Capabilities

### New Capabilities

- `tdd`: red and green become scripted, evidence-emitting phases.

### Modified Capabilities

- `telemetry`: ticket-bound events carry derived attribution.
- `tickets`: lifecycle and conclude refusals emit; scaffold leaves
  app-level evidence.
- `caffeine`: deps emits app-level evidence when state exists.
- `retro`: blocked-seconds pairing scoped per app.

## Impact

- Modified: `lib/telemetry.sh`, `bin/routine-done`, `bin/routine-block`,
  `bin/routine-unblock`, `bin/routine-next`, `bin/routine-conclude`,
  `bin/routine-scaffold`, `bin/routine-deps`, `bin/routine-retro`, their
  tests. Added: `bin/routine-tdd`, `test/tdd.bats`. Auditing the event
  set against the protocol stays out (C4).
