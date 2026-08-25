# tdd Specification

## Purpose

Red before green as checkable protocol: the TDD phases run through a
script that enforces each phase's expectation and records it as
telemetry evidence.

## Requirements

### Requirement: Red and green are scripted, evidence-emitting phases
`bin/routine-tdd <red|green|characterize> <scenario> -- <command...>` SHALL require a
ticket context (`ROUTINE_TICKET_DIR`), run the command, and emit one
`tdd.red`, `tdd.green` or `tdd.characterize` line into the ticket's telemetry whose `script`
field is the scenario followed by a bracketed short hash of the command
(`<scenario> [<hash8>]`) — so the audit's byte-exact pairing proves red
and green ran the same command — with the command's actual exit code.
The recorded form SHALL be printed. When the telemetry write fails (a
rejected value or write error) `routine-tdd` SHALL exit 3 naming the
cause and SHALL NOT report the phase as recorded. It SHALL enforce the
phase: under `red` a passing command SHALL make `routine-tdd` exit
non-zero naming the violation (a red that isn't red); under `green` a
failing command's exit code SHALL be relayed; and under `characterize` a failing command SHALL make `routine-tdd` exit non-zero naming the violation, because `characterize` asserts the scenario was already true before the developer touched anything and a failing one is a false claim in the spec rather than work for the developer. `characterize` and `green` SHALL stay distinct phases though both require a passing command, because the audit demands a covering red for a `## Scenario:` label and none for a `## Characterization:` one, and merging them would erase the distinction it pairs on. When `characterize` refuses, `routine-tdd` SHALL persist the command's verbatim output to a script-owned log in the task's own directory, truncated per run, so the analyst reads what actually printed rather than a paraphrase. A passing `characterize` SHALL remove that task's `characterize.log`: the claim is proven, the refusal history lives in telemetry, and a stale log left behind reaches a re-entering analyst as the current failure — measured three times in one run — so the interface built to deliver verbatim evidence would deliver wrong evidence confidently. The evidence line SHALL be
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

#### Scenario: A characterization that is green at birth is recorded
- **WHEN** `routine-tdd characterize "<label>" -- <cmd>` runs and the
  command passes
- **THEN** `routine-tdd` exits 0 and the telemetry gains one
  `tdd.characterize` line carrying the scenario and the command hash

#### Scenario: A characterization that is red is refused
- **WHEN** the command under `characterize` exits non-zero
- **THEN** `routine-tdd` exits non-zero naming the violation, because
  the claim that the scenario was already true is false

#### Scenario: The refused characterization keeps its verbatim output
- **WHEN** `characterize` refuses
- **THEN** the command's output is persisted verbatim to the task's
  script-owned log, replacing any previous run's, so the reader is never
  guessing which failure is current

#### Scenario: A pass removes the stale refusal log
- **WHEN** a refused `characterize` has written the task's log and a
  later `characterize` for the same task passes
- **THEN** the task's `characterize.log` is gone, because a proven
  claim leaves no stale failure for a re-entering analyst to trust
