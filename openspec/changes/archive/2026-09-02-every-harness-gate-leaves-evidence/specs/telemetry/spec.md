# telemetry Specification (delta)

## MODIFIED Requirements

### Requirement: Harness scripts leave evidence where a destination exists
Every harness gate — a `bin/` script that judges the repository or a
release rather than a ticket: `routine-selfcheck`, `routine-release-check`,
`routine-convention-check`, `routine-caffeine-lint`, `routine-script-lint`,
`routine-change-check`, `routine-mutation-check`, `routine-pr-body-check`,
`routine-render-check`, `routine-road-check`, `routine-record-lint` and
`routine-test-lint` — SHALL emit exactly one telemetry line per run
naming its `harness.*` road, and `lib/roads.txt` SHALL be the
authoritative list of those roads, so this prose can never again name
fewer scripts than emit or more than are declared, recording
their exit code to `runs/<app>/telemetry.jsonl`, deriving the app from
`TARGET` (default: current directory), when that app directory already
exists — and SHALL emit nothing otherwise. Emission SHALL never change
the script's exit code.

#### Scenario: Harness verdicts recorded against existing app state
- **WHEN** `routine-selfcheck` runs with `TARGET` naming an app whose
  `runs/<app>/` exists
- **THEN** `runs/<app>/telemetry.jsonl` gains one `harness.selfcheck`
  line carrying the run's exit code

#### Scenario: No app state, no invented destination
- **WHEN** a harness script runs where no `runs/<app>/` exists
- **THEN** no telemetry file is created and the exit code is unaffected

#### Scenario: A lint leaves evidence like its siblings
- **WHEN** `routine-record-lint` or `routine-test-lint` runs where
  `runs/<app>/` exists
- **THEN** `runs/<app>/telemetry.jsonl` gains one `harness.record` or
  `harness.test` line carrying the run's exit code

#### Scenario: The registry and the prose name the same scripts
- **WHEN** `lib/roads.txt` is read against the scripts that emit a
  `harness.*` road
- **THEN** every emitter is declared and every declared harness road has
  an emitter, which `routine-road-check` decides


## Removed Lines

- `bin/routine-selfcheck`, `bin/routine-release-check`,
- `bin/routine-convention-check`, and `bin/routine-caffeine-lint` SHALL
- each emit exactly one telemetry line (`harness.selfcheck`,
- `harness.release`, `harness.convention`, `harness.caffeine`) recording
