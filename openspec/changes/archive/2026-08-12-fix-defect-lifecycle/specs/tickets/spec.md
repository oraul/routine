## MODIFIED Requirements

### Requirement: The defect return is a lifecycle transition
`bin/routine-defect <ticket-dir> <reason>` SHALL return the `in_progress`
task to `pending` with the stated reason **appended** to the task's
`defect.md` under a timestamped heading — repeated returns keep the full
history, newest last — refusing without a reason or without an
`in_progress` task, and SHALL emit one `spec.defective` telemetry event.

#### Scenario: Defective task returned to the line
- **WHEN** `routine-defect` runs with an in_progress task and a reason
- **THEN** the task is `pending`, `defect.md` carries the reason, and one
  `spec.defective` event is recorded

#### Scenario: History survives a second return
- **WHEN** the same task takes two defect returns with different reasons
- **THEN** `defect.md` holds both, each under its own timestamp

## ADDED Requirements

### Requirement: Abort is a scripted lifecycle transition
`bin/routine-abort <ticket-dir> <reason>` SHALL refuse without a
non-empty reason, SHALL write the reason to the ticket-level `abort.md`,
SHALL emit one `ticket.abort` telemetry line before moving anything,
SHALL move the ticket directory to `tickets/archive/<id>/` with every
artifact intact (no `report.md` — that file asserts completion), and
SHALL print the archived path. An aborted ticket SHALL never linger in
the active directory.

#### Scenario: Abort archives with evidence
- **WHEN** `routine-abort <ticket> "revise limit exhausted on grammar"`
  runs
- **THEN** the ticket lands in `tickets/archive/<id>/` containing
  `abort.md` with the reason, its telemetry ends with a `ticket.abort`
  line, and the output names the archived path

#### Scenario: Abort without a reason is refused
- **WHEN** `routine-abort` runs with no reason
- **THEN** it exits non-zero naming the missing reason and moves nothing
