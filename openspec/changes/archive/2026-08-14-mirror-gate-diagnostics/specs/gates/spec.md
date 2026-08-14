# gates Specification (delta)

## ADDED Requirements

### Requirement: The gate's reasons survive the session
`bin/routine-gate` SHALL mirror into the ticket's script-owned
`gate.log` every `routine-gate:` diagnostic line it prints and the
output of the stages it runs, in the order they occurred. The file
SHALL be truncated at the start of each run that has a ticket context,
after the gate-name check — a usage error never touches a ticket — and
a run without a ticket context SHALL write no log. Live output to the
caller SHALL be unchanged: the log is a mirror, never a redirect. A
fresh session therefore learns why a gate failed by reading, never by
re-running a gate that would spend a counted revise or a full
lint-and-test cycle.

#### Scenario: A failing gate leaves its reason behind
- **WHEN** a gate fails with diagnostics
- **THEN** the ticket's `gate.log` carries those lines and the caller
  still saw them live

#### Scenario: A failing hook's output survives
- **WHEN** the developer hook fails printing its own output
- **THEN** that output appears in `gate.log`

#### Scenario: Each run starts clean
- **WHEN** a gate runs after an earlier failing run
- **THEN** `gate.log` holds only the current run's lines
