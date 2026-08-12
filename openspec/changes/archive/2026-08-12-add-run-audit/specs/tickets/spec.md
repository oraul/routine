## MODIFIED Requirements

### Requirement: Conclude is evidence-checked and archives the ticket
`bin/routine-conclude <ticket-dir>` SHALL refuse (naming the offending
tasks) unless every index row is `done`, and SHALL refuse unless
`bin/routine-audit` passes over the ticket — surfacing the audit's
violations. Each refusal SHALL emit one `ticket.conclude` line with its
non-zero exit. On success it SHALL write `report.md` summarizing the run
from the index, emit one `ticket.conclude` telemetry line, and move the
ticket directory to `tickets/archive/<id>/`, printing the archived path.

#### Scenario: Refuses with work remaining
- **WHEN** any index row is not `done`
- **THEN** `routine-conclude` exits non-zero naming the unfinished tasks,
  moves nothing, and the ticket's `telemetry.jsonl` gains one
  `ticket.conclude` line with a non-zero `exit`

#### Scenario: Refuses a run that fails the audit
- **WHEN** every index row is `done` but the audit finds a violation
- **THEN** `routine-conclude` exits non-zero surfacing the violation and
  moves nothing

#### Scenario: Concludes a finished ticket
- **WHEN** every index row is `done` and the audit passes
- **THEN** `report.md` exists in the archived ticket at
  `tickets/archive/<id>/`, the active directory is gone, and the archived
  `telemetry.jsonl` ends with a `ticket.conclude` line
