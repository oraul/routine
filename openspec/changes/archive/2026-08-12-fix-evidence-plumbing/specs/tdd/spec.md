## MODIFIED Requirements

### Requirement: Red and green are scripted, evidence-emitting phases
`bin/routine-tdd <red|green> <scenario> -- <command...>` SHALL require a
ticket context (`ROUTINE_TICKET_DIR`), run the command, and emit one
`tdd.red` or `tdd.green` line into the ticket's telemetry whose `script`
field is the scenario followed by a bracketed short hash of the command
(`<scenario> [<hash8>]`) — so the audit's byte-exact pairing proves red
and green ran the same command — with the command's actual exit code.
The recorded form SHALL be printed. When the telemetry write fails (a
rejected value or write error) `routine-tdd` SHALL exit 3 naming the
cause and SHALL NOT report the phase as recorded. It SHALL enforce the
phase: under `red` a passing command SHALL make `routine-tdd` exit
non-zero naming the violation (a red that isn't red); under `green` a
failing command's exit code SHALL be relayed. The evidence line SHALL be
emitted before any refusal exit.

#### Scenario: Red evidence recorded
- **WHEN** `routine-tdd red "login rejects bad password" -- <cmd>` runs
  and the command fails
- **THEN** `routine-tdd` exits 0 and the ticket's telemetry gains one
  `tdd.red` line carrying the scenario, the command hash, and the
  command's non-zero exit

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

#### Scenario: A silent record is impossible
- **WHEN** the scenario contains a value telemetry rejects (a quote)
- **THEN** `routine-tdd` exits 3 naming the rejected value and never
  prints "recorded"

#### Scenario: The pair binds to the command
- **WHEN** red runs with one command and green runs the same scenario
  with a different command
- **THEN** the recorded scenario strings differ (different hashes) and
  the audit does not pair them
