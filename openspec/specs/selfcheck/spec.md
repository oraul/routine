# selfcheck Specification

## Purpose

The harness integrity gate: proves the repo's scripts are lint-clean and its
test suite is green before any other guarantee is trusted.

## Requirements

### Requirement: Selfcheck verifies lint cleanliness and test success
`bin/routine-selfcheck` SHALL run shellcheck over every script in `bin/` and
`lib/` and every caffeine sidecar (`caffeine/*/*.sh`) that exists, then run
the full bats suite under `test/`, and SHALL exit 0 only when both stages
succeed.

#### Scenario: Everything green
- **WHEN** all scripts are shellcheck-clean and the bats suite passes
- **THEN** `routine-selfcheck` exits 0

#### Scenario: Lint failure aborts before tests
- **WHEN** any checked script fails shellcheck
- **THEN** `routine-selfcheck` exits non-zero and surfaces the shellcheck
  output without running the bats suite

#### Scenario: Test failure
- **WHEN** shellcheck is clean but any bats test fails
- **THEN** `routine-selfcheck` exits non-zero and surfaces the bats output

### Requirement: Selfcheck resolves its root from ROUTINE_ROOT
`routine-selfcheck` SHALL resolve the repo root from the `ROUTINE_ROOT`
environment variable, defaulting to `$CLAUDE_PLUGIN_ROOT` and falling back to
the script's own repository root, and SHALL NOT hardcode any state path.

#### Scenario: Explicit root
- **WHEN** `ROUTINE_ROOT` points at a fixture directory containing `bin/` and
  `test/`
- **THEN** `routine-selfcheck` checks the scripts and tests under that
  directory, not the installation directory

### Requirement: Selfcheck tolerates not-yet-built layers
`routine-selfcheck` SHALL treat optional layers that do not exist yet (such as
`caffeine/` sidecars before change 7) as absent rather than as failures.

#### Scenario: No sidecars present
- **WHEN** the repo contains no `caffeine/*/*.sh` files
- **THEN** the shellcheck stage covers `bin/` and `lib/` only and selfcheck
  proceeds to the bats stage
