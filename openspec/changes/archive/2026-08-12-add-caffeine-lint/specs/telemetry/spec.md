## MODIFIED Requirements

### Requirement: Harness scripts leave evidence where a destination exists
`bin/routine-selfcheck`, `bin/routine-release-check`,
`bin/routine-convention-check`, and `bin/routine-caffeine-lint` SHALL
each emit exactly one telemetry line (`harness.selfcheck`,
`harness.release`, `harness.convention`, `harness.caffeine`) recording
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
