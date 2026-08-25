# telemetry Specification

## Purpose

The evidence trail: every script invocation reports exactly one machine-
parseable line, so retros can be computed from plain files with awk alone.

## Requirements

### Requirement: Telemetry lines use a fixed key order
`lib/telemetry.sh` SHALL provide a function that appends exactly one JSON
line per event to a named `telemetry.jsonl`, with keys in the fixed order
`ts,event,script,ticket,task,exit,ms`, ISO-8601 UTC timestamp, and
dot-notation event names.

#### Scenario: Line appended with fixed key order
- **WHEN** a script emits an event with exit code and duration
- **THEN** one line is appended whose keys appear exactly in the order
  `ts,event,script,ticket,task,exit,ms`

#### Scenario: Append never truncates
- **WHEN** the telemetry file already holds lines
- **THEN** emitting adds one line at the end and existing lines are unchanged

### Requirement: Telemetry is script-owned
Only scripts SHALL write telemetry. The emit function SHALL require an
explicit destination file; when a script runs outside any ticket context
it SHALL skip emission rather than invent a destination — and a script
whose evidence is mandatory (the gates, `routine-tdd`) SHALL refuse to
run unrecorded instead of proceeding silently.

#### Scenario: No ticket context
- **WHEN** a ticket-bound emission is attempted with no ticket directory
  configured
- **THEN** no telemetry line is written and no destination is invented


### Requirement: Durations are measured at platform precision
Every emitting script SHALL record its measured duration in the `ms` field
via a shared clock helper that SHALL return milliseconds where the
platform's `date` supports nanoseconds and whole seconds × 1000 otherwise,
detected at runtime. A constant duration SHALL never be emitted.

#### Scenario: Millisecond clock on GNU date
- **WHEN** the platform's `date +%s%N` prints digits
- **THEN** the helper returns epoch milliseconds

#### Scenario: Fallback on BSD date
- **WHEN** `date +%s%N` prints a literal `N` suffix
- **THEN** the helper returns epoch seconds × 1000

### Requirement: Ticket-bound events carry derived attribution
Events emitted through the ticket-bound wrapper SHALL carry the ticket
directory's basename in the `ticket` field and the `in_progress` index
row's task id in the `task` field when one exists. Attribution SHALL be
derived from the ticket state, never passed by the caller; an empty
`task` field means no task was in progress at emission time.

#### Scenario: Gate event names its ticket and task
- **WHEN** `routine-gate developer` runs with a ticket whose index holds
  an `in_progress` row
- **THEN** the emitted gate lines carry the ticket's id and that task's id

#### Scenario: No task in progress leaves task empty
- **WHEN** a ticket-bound event is emitted while no index row is
  `in_progress`
- **THEN** the line carries the ticket id and an empty `task` field

### Requirement: Harness scripts leave evidence where a destination exists
`bin/routine-selfcheck`, `bin/routine-release-check`,
`bin/routine-convention-check`, and `bin/routine-caffeine-lint` SHALL
each emit exactly one telemetry line (`harness.selfcheck`,
`harness.release`, `harness.convention`, `harness.caffeine`) recording
their exit code to `runs/<app>/telemetry.jsonl`, deriving the app from
`TARGET` (default: current directory), when that app directory already
exists — and SHALL emit nothing otherwise. Emission SHALL never change
the script's exit code.

#### Scenario: Harness verdicts recorded against existing app state
- **WHEN** `routine-selfcheck` runs with `TARGET` naming an app whose
  `runs/<app>/` exists
- **THEN** `runs/<app>/telemetry.jsonl` gains one `harness.selfcheck`
  line carrying the run's exit code

#### Scenario: No app state, no invented destination
- **WHEN** a harness script runs where no `runs/<app>/` exists
- **THEN** no telemetry file is created and the exit code is unaffected

### Requirement: The repository ships its own harness destination
`runs/routine/` SHALL exist in a fresh clone, carried by a tracked
marker (`runs/routine/README.md`) and ignore rules that re-include only
the marker, so a harness script gating routine itself always finds its
destination and its verdict is recorded instead of silently skipped;
every other path under `runs/` SHALL remain untracked, because run
evidence is session-local, script-owned state and the durable record
travels through `evidence/` and the specs. The no-invented-destination
rule SHALL stand unchanged: nothing is invented when the destination is
shipped.

#### Scenario: The marker survives a clone
- **WHEN** the repository is cloned fresh
- **THEN** `runs/routine/` exists and git tracks exactly one path under
  `runs/` — the marker

#### Scenario: Session state stays ignored
- **WHEN** telemetry lands in `runs/routine/telemetry.jsonl` or any
  other `runs/<app>/` path
- **THEN** git ignores it

#### Scenario: A repo-context gate records
- **WHEN** `routine-release-check` or `routine-convention-check` runs
  from the repository with no `TARGET`
- **THEN** `runs/routine/telemetry.jsonl` gains the harness line,
  because the destination the emit rule requires is now always there

### Requirement: Declared roads are walked or waivered
`lib/roads.txt` SHALL declare every telemetry event name the contracts
can emit — one event per line, `#` comments and blank lines ignored, a
road not yet exercised carrying the waiver form
`<event> — never walked: <why>`. `bin/routine-road-check [runs-dir]`
(default: the routine root's `runs/`) SHALL judge the declared list
against every `telemetry.jsonl` under that directory, at any depth, and
SHALL report in one run: an observed event that is not declared; a
declared, unwaivered event that no line ever recorded; and a waivered
event that was in fact walked, because a stale waiver misstates
coverage exactly the way a stale count misstates a suite. It SHALL exit
0 when every declared road is walked or honestly waivered and nothing
undeclared was observed, 1 when any violation is reported, and 2 on a
usage error, a missing roads file, or a missing runs directory. The
check SHALL read evidence and write none of it; its own invocation
SHALL be a declared road (`harness.roads`), recorded through the
harness wrapper like any other verdict, so the road the check opens is
walked by walking it. It SHALL remain a session and release-record
instrument rather than a clone-time gate, because run evidence is
session-local and a fresh clone holds nothing to judge.

#### Scenario: A clean tree passes
- **WHEN** every declared, unwaivered road appears in some telemetry
  line under the runs directory and no waivered road does
- **THEN** the check exits 0

#### Scenario: An undeclared road fails
- **WHEN** a telemetry line carries an event name absent from
  `lib/roads.txt`
- **THEN** the check exits 1 naming the event as undeclared

#### Scenario: An unwalked road fails
- **WHEN** a declared, unwaivered event appears in no telemetry line
- **THEN** the check exits 1 naming the event and the waiver form that
  would record the why

#### Scenario: A stale waiver fails
- **WHEN** a waivered event appears in a telemetry line
- **THEN** the check exits 1 naming the waiver as stale

#### Scenario: Every violation surfaces in one run
- **WHEN** several rules are broken at once
- **THEN** all violations are reported before the single non-zero exit

#### Scenario: Nested ticket evidence counts as walked
- **WHEN** an event appears only in a ticket's or an archived ticket's
  `telemetry.jsonl` under the runs directory
- **THEN** that road counts as walked

#### Scenario: Missing evidence is a refusal, not a verdict
- **WHEN** the runs directory or the roads file does not exist
- **THEN** the check exits 2 naming the missing path
