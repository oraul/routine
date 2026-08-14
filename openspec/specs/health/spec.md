# health Specification

## Purpose

The live-run reader: what phase a run is factually in, what is in
flight, and the exact command that resumes it — so a session that died
mid-flight is diagnosed by reading, never by inference.

## Requirements

### Requirement: The live run has a scripted reader
`bin/routine-health [ticket-dir]` SHALL report the state of a run in
flight, writing nothing — the audit judges a finished run, this reads a
living one. Given a ticket directory it SHALL derive the phase from
script-owned state alone (telemetry's fixed key order and append-only
line order, plus `index.tsv`), first match winning: no passing
`gate.preflight` is `preflight`; no passing `gate.analyst` since the
last `spec.defective` is `specify`; no passing `ticket.approve` since
that same boundary is `approve`; a blocked index row is
`develop/blocked`; an in_progress or pending row is `develop`; all rows
done is `conclude`. It SHALL print what is in flight — the in_progress
task id, blocked rows, and the revises spent this episode — and SHALL
end with a `next:` line naming the exact command that resumes the run.

#### Scenario: A dead run names its own next step
- **WHEN** a ticket's telemetry records a passing developer gate for
  its in_progress task and no `ticket.done`
- **THEN** `routine-health` reports phase `develop`, names that task,
  and its `next:` line is the `routine-done` command

#### Scenario: The reader writes nothing
- **WHEN** `routine-health` runs twice against the same ticket
- **THEN** no file in the ticket changes and both runs print the same
  report

#### Scenario: Revises spent are visible before the gate is spent
- **WHEN** a ticket recorded two failing `spec.lint` runs since its
  last `spec.defective`
- **THEN** the report shows two revises spent without running the lint

### Requirement: Health's exit code carries the branch
`routine-health` SHALL exit 0 when the run is resumable by the driving
session on the rails, 1 when a human must act first — a blocked line, a
pending approve, an exhausted revise budget, or more than one active
ticket — and 2 on usage. The exit code SHALL be the phase machine's
branch, so no caller infers state from prose.

#### Scenario: A blocked line needs a human
- **WHEN** the ticket holds a blocked row
- **THEN** `routine-health` exits 1 and its `next:` line names the
  unblock road

#### Scenario: A resumable run exits zero
- **WHEN** the ticket holds an in_progress task with no block
- **THEN** `routine-health` exits 0

### Requirement: Active tickets are resolved by script, never by guess
With no argument `routine-health` SHALL resolve the app's active
tickets and report zero, one, or many. Zero means a new ticket is
legitimate; one names the ticket to adopt as `ROUTINE_TICKET_DIR`; more
than one is a protocol violation (WIP is 1) that SHALL exit 1 naming
every candidate. It SHALL also warn when a ticket holds a stale
`index.tsv.new`, the artifact a lifecycle script killed mid-write
leaves behind — naming it as evidence, since removal is the human's
call.

#### Scenario: One live ticket is adopted, not duplicated
- **WHEN** an app holds exactly one active ticket
- **THEN** `routine-health` prints its path and exits 0

#### Scenario: Two active tickets are a diagnosis
- **WHEN** an app holds two active tickets
- **THEN** `routine-health` exits 1 naming both

#### Scenario: A mid-write death leaves a named artifact
- **WHEN** a ticket holds `index.tsv.new`
- **THEN** the report warns naming the file
