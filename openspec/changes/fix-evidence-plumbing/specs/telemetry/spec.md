## MODIFIED Requirements

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
