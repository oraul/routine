## Why

A run that dies mid-flight — the driving session hits its token limit,
the terminal closes, a subagent stops — leaves everything it needs on
disk and nothing that reads it. Phase 0 resolves state by inference
over prose ("if no active ticket exists…"), which is a load-bearing
prompt at the highest-stakes moment (Law 1). Three council lenses found
this independently and it survived adversarial verification: a fresh
session must guess which ticket is live and where it stopped, and
guessing wrong is expensive — `routine-ticket-new` allocates
unconditionally, orphaning the dying run's ticket, and re-running the
analyst gate to *learn* state spends a counted revise.

Every fact needed is already script-owned: the fixed telemetry key
order, the append-only line order (time order), the index statuses,
and the gate's own episode rule. What is missing is the reader.

## What Changes

- **`bin/routine-health [ticket-dir]`** — a pure reader (writes
  nothing) that answers, for a live run, what the audit answers for a
  finished one:
  - with no argument: scans the app's tickets and reports zero, one,
    or many active tickets — many is itself a diagnosis;
  - the **derived phase**, first match wins over telemetry and index:
    no passing `gate.preflight` → preflight; no passing `gate.analyst`
    since the last `spec.defective` → specify; no passing
    `ticket.approve` since that boundary → approve; a blocked row →
    develop/blocked; an in_progress or pending row → develop; all rows
    done → conclude;
  - **what is in flight**: the in_progress task id, blocked rows,
    revises spent this episode, and a `index.tsv.new` warning (the one
    true mid-write death artifact);
  - a final `next: <exact command>` line — the command a fresh session
    runs to resume.
- **Exit codes carry the branch**: 0 the driver can proceed on rails,
  1 a human is needed first (blocked line, approve pending, many
  active tickets, exhausted revises), 2 usage.
- **`lib/episode.sh`** — the gate's revise-counting awk becomes one
  function with two shipped consumers (gate and health), so the budget
  can never be counted two ways.
- **Phase 0 calls it**: the skill runs `routine-health` after scaffold
  and branches on the exit code instead of inferring.

## Capabilities

### New Capabilities

- `health`: the live-run reader and its phase derivation.

### Modified Capabilities

- `operation`: phase 0 resolves state by script, not by prose.
- `gates`: the revise counter is shared, not duplicated.

## Impact

- Added: `bin/routine-health`, `lib/episode.sh`, `test/health.bats`.
- Modified: `bin/routine-gate`, `skills/routine/SKILL.md`.
