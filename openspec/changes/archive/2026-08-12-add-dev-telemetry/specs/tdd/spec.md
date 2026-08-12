## ADDED Requirements

### Requirement: Red and green are scripted, evidence-emitting phases
`bin/routine-tdd <red|green> <scenario> -- <command...>` SHALL require a
ticket context (`ROUTINE_TICKET_DIR`), run the command, and emit one
`tdd.red` or `tdd.green` line into the ticket's telemetry with the
scenario riding the `script` field and the command's actual exit code.
It SHALL enforce the phase: under `red` a passing command SHALL make
`routine-tdd` exit non-zero naming the violation (a red that isn't red);
under `green` a failing command's exit code SHALL be relayed. The
evidence line SHALL be emitted before any refusal exit.

#### Scenario: Red evidence recorded
- **WHEN** `routine-tdd red "login rejects bad password" -- <cmd>` runs
  and the command fails
- **THEN** `routine-tdd` exits 0 and the ticket's telemetry gains one
  `tdd.red` line carrying the scenario and the command's non-zero exit

#### Scenario: A red that isn't red is refused
- **WHEN** the command under `red` exits 0
- **THEN** `routine-tdd` exits non-zero naming the violation and the
  `tdd.red` line records exit 0

#### Scenario: Green relays failure
- **WHEN** the command under `green` exits non-zero
- **THEN** `routine-tdd` exits with that code and the `tdd.green` line
  records it

#### Scenario: No ticket context
- **WHEN** `routine-tdd` runs without `ROUTINE_TICKET_DIR`
- **THEN** it exits non-zero naming the missing context and emits nothing
