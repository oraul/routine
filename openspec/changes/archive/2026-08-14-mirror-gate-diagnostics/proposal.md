## Why

When a gate fails, *why* it failed exists only on the driving session's
stderr. The lint's defect list survives on `lint.log` (that precedent
was earned last council), but the gate's own diagnostics — an index
row with no directory, a missing task, a manifest naming an unknown
topic — and, more expensively, the developer hook's and sidecars'
output die with the terminal. A fresh session resuming a run that died
on a red gate can only learn why by re-running it: for the analyst
gate that spends a counted revise, and for the developer gate that is
a full lint-and-test cycle of the target.

## What Changes

- **`<ticket>/gate.log`** — script-owned, truncated at the start of
  every gate run that has a ticket context (after the usage check, so
  an invalid gate name never touches a ticket), carrying every
  `routine-gate:` diagnostic line and the output of the stages it
  runs, in order. Live output to the caller is unchanged — the log is
  a mirror, not a redirect.
- **Health points at it**: when a ticket's `gate.log` is non-empty,
  `routine-health` names it as the surviving reason, the way it
  already names `lint.log`.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `gates`: the gate's reasons survive the session that ran them.
- `health`: the reader names the surviving gate reason.

## Impact

- Modified: `bin/routine-gate`, `bin/routine-health`,
  `test/gate.bats`, `test/health.bats`.
