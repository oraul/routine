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
explicit destination file; when a script runs outside any ticket context it
SHALL skip emission rather than invent a destination.

#### Scenario: No ticket context
- **WHEN** a gate runs with no ticket directory configured
- **THEN** no telemetry line is written and the gate's exit code is unaffected

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
