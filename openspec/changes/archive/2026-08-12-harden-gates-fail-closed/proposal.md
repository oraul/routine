## Why

The council found the developer gate's guarantees evaporate silently: no
ticket context → baseline skipped, gate green; no in-progress task →
baseline skipped, gate green; and `routine-gate` resolves caffeine and
spec-lint from a different root than hooks and selfcheck, so `ROUTINE_ROOT`
redirects only half the machine. Gates must fail closed, and hook/doc-only
outcomes must be distinguishable in evidence.

## What Changes

- **Developer gate fails closed**: missing `ROUTINE_TICKET_DIR` or no
  `in_progress` row fails the baseline naming the condition (matching the
  analyst gate's posture).
- **One root**: sidecars and spec-lint resolve from the same root as hooks
  and selfcheck (`routine_root`), so fixtures and `ROUTINE_ROOT` redirect
  everything or nothing. Gate fixtures ship the real lint/caffeine files.
- **Hook outcomes become events**: every hook stage emits `gate.hook`
  (script = the hook path, exit = its code); an absent optional hook emits
  `gate.hook.absent`; a doc-only manifest topic emits
  `gate.developer.doc` — "passed because it ran" and "passed because it
  was absent" stop being byte-identical.
- **`routine-unblock` gains an optional task-id argument** matching the
  `/unblock <ticket> <task>` signature: given an id it releases exactly
  that task or refuses; without one it keeps releasing the first blocked
  row.
- **`routine-conclude` prints the archived path.**

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `gates`: fail-closed developer baseline, single-root resolution, hook and
  doc-only telemetry events.
- `tickets`: unblock task addressing; conclude output names the archive.

## Impact

- Modified: `bin/routine-gate`, `bin/routine-unblock`,
  `bin/routine-conclude`, gate/lifecycle tests (fixture roots gain
  symlinked `lib/`, `caffeine/`, and `spec-lint` so one-root resolution
  stays fixture-testable). Ticket/task attribution on gate events lands
  in C3.
