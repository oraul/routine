# tickets Specification (delta)

## MODIFIED Requirements

### Requirement: Approval is recorded evidence
`bin/routine-approve <ticket-dir> [note]` SHALL refuse unless the
ticket's telemetry holds a passing `gate.analyst` line (approval of
ungated artifacts is meaningless), SHALL append any note to the
ticket-level `approve.md` under a timestamped heading, and SHALL emit
one `ticket.approve` telemetry line. Repeated approvals (after a defect
return) SHALL keep the full note history. It SHALL additionally refuse a proceed while the ticket's `grounding.md` carries a non-floor `## Questions` section and no note is given, because a question only the operator can answer is cheap to overturn before implementation and a caller-visible break after it — showing the questions makes them visible, and only an exit code makes them answered. A `## Questions` section at its `- none — <why>` floor SHALL NOT block a proceed, so asking is a deliberate act rather than a tax on every ticket. The gate SHALL decide presence and floor only: whether a question is real, whether the answer is good, and whether the human read it rather than typing a word to pass are judgments no script here makes.
#### Scenario: Approval leaves a line
- **WHEN** `routine-approve <ticket> "ship without the CSV export"`
  runs after a passing analyst gate
- **THEN** the telemetry gains one `ticket.approve` line and
  `approve.md` carries the note under a timestamp

#### Scenario: Ungated artifacts cannot be approved
- **WHEN** `routine-approve` runs with no passing `gate.analyst` on
  record
- **THEN** it exits non-zero naming the missing gate
#### Scenario: An unanswered operator question blocks the proceed
- **WHEN** `grounding.md` carries a non-floor `## Questions` section and
  `routine-approve` is called with no note
- **THEN** it exits non-zero naming the unanswered questions, and no
  `ticket.approve` line is recorded

#### Scenario: Nothing to ask never blocks
- **WHEN** `## Questions` is at its `- none — <why>` floor
- **THEN** `routine-approve` records the proceed exactly as it does today
