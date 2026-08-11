## Why

Every phase transition in the operational loop must be gated by a script exit
code, and every guarantee must leave an evidence trail. Change 2 builds both
rails: the gate runner that composes selfcheck, baseline, and app hook into a
single exit-code decision, and the telemetry helper every script will use to
report what it did.

## What Changes

- Add `lib/telemetry.sh`: a sourced helper that appends exactly one JSON line
  per event to a named `telemetry.jsonl`, with fixed key order
  (`ts,event,script,ticket,task,exit,ms`) so awk can parse it without a JSON
  library.
- Add `bin/routine-gate <gate>`: composes, in order, selfcheck (preflight gate
  only) → routine's baseline for the gate → the app hook at
  `runs/<app>/hooks/<gate>.sh` if present. Exit 0 passes; non-zero aborts and
  surfaces the output.
- Implement the seam contract: optional hooks (preflight, analyst) log one
  line and pass when missing; the developer hook is mandatory — when missing,
  exit non-zero naming the exact file to create and a one-line example that
  delegates to the app's own tooling.
- Implement the preflight baseline: `routine-selfcheck` green first, then a
  clean git worktree and on-a-branch check in the target project.
- Later baselines (analyst structure checks, developer sidecars) stay out of
  scope — changes 3–4 and 7 own them; the runner treats them as
  baseline-absent gates that still honor the seam contract.

## Capabilities

### New Capabilities

- `gates`: the gate composition order, exit-code semantics, the seam contract
  for optional vs mandatory hooks, and the preflight baseline.
- `telemetry`: the event-line format, fixed key order, and the
  script-owned/append-only rules.

### Modified Capabilities

<!-- none -->

## Impact

- New files: `bin/routine-gate`, `lib/telemetry.sh`, their bats suites and
  fixtures.
- `bin/routine-selfcheck` picks them up automatically (glob-based lint, full
  suite) — no changes to existing scripts.
- No target-project files, committed or ignored (Law: targets stay pristine).
