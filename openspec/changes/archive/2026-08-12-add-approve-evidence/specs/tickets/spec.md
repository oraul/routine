## ADDED Requirements

### Requirement: Approval is recorded evidence
`bin/routine-approve <ticket-dir> [note]` SHALL refuse unless the
ticket's telemetry holds a passing `gate.analyst` line (approval of
ungated artifacts is meaningless), SHALL append any note to the
ticket-level `approve.md` under a timestamped heading, and SHALL emit
one `ticket.approve` telemetry line. Repeated approvals (after a defect
return) SHALL keep the full note history.

#### Scenario: Approval leaves a line
- **WHEN** `routine-approve <ticket> "ship without the CSV export"`
  runs after a passing analyst gate
- **THEN** the telemetry gains one `ticket.approve` line and
  `approve.md` carries the note under a timestamp

#### Scenario: Ungated artifacts cannot be approved
- **WHEN** `routine-approve` runs with no passing `gate.analyst` on
  record
- **THEN** it exits non-zero naming the missing gate
