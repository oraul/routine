## ADDED Requirements

### Requirement: The defect return is a lifecycle transition
`bin/routine-defect <ticket-dir> <reason>` SHALL return the `in_progress`
task to `pending` with the stated reason written to the task's
`defect.md`, refusing without a reason or without an `in_progress` task,
and SHALL emit one `spec.defective` telemetry event.

#### Scenario: Defective task returned to the line
- **WHEN** `routine-defect` runs with an in_progress task and a reason
- **THEN** the task is `pending`, `defect.md` carries the reason, and one
  `spec.defective` event is recorded
