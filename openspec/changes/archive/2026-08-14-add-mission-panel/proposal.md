## Why

The loop's state is legible one question at a time — `routine-health`
answers "where is this run", `routine-retro` answers "what has the
corpus cost" — but nothing shows a run *while it happens*. Watching
requires re-asking, and re-asking is exactly what a human does not do
while an agent works. Every signal worth watching is already
script-owned; what is missing is a face for it.

## What Changes

- **`bin/routine-panel`** — a pure reader that prints one
  self-contained HTML page to stdout, computed from script-owned state
  alone (the `routine-retro` discipline: computes, never stores, writes
  no file of its own). No server, no dependency, no daemon: redirect it
  to a file and open that file; re-run it on an interval and the page
  refreshes itself.
- **Every gauge names its source** — no signal ships that the state
  cannot back:
  - *status*: phase, in-flight task, blocked line, uncommitted work and
    the next command, from `routine-health`'s own derivation;
  - *latency*: gate and TDD durations from telemetry's `ms` field;
  - *traffic*: the phase machine with the run's position marked, and
    event counts per script;
  - *errors*: failing gate and lint lines, defect returns, and the
    revise budget against its ceiling;
  - *saturation*: blocked seconds per task and the in-flight versus
    done task counts;
  - *caffeine*: topics ranked by sidecar failure rate — the deepening
    queue the retro already computes.
- **A refresh interval** is embedded so an open page re-reads itself
  while a watch loop regenerates it.

## Capabilities

### New Capabilities

- `panel`: the computed live view and its signal contract.

## Impact

- Added: `bin/routine-panel`, `test/panel.bats`.
