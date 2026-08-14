# health Specification (delta)

## MODIFIED Requirements

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
end with a `next:` line naming the exact command that resumes the run. When the ticket holds a non-empty `gate.log`, the report SHALL name it as the surviving reason the last gate failed, so recovery reads it instead of re-running the gate.

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

#### Scenario: The surviving gate reason is named
- **WHEN** the ticket holds a non-empty `gate.log`
- **THEN** the report names that file as the last gate's reason
