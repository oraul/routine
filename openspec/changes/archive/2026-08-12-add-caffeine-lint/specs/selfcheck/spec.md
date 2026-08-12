## MODIFIED Requirements

### Requirement: Selfcheck verifies lint cleanliness and test success
`bin/routine-selfcheck` SHALL run `bin/routine-caffeine-lint` first (a
malformed topic tree makes downstream results meaningless), then
shellcheck over every script in `bin/` and `lib/` and every caffeine
sidecar (`caffeine/*/*.sh`) that exists, then the full bats suite under
`test/`, and SHALL exit 0 only when all stages succeed.

#### Scenario: Everything green
- **WHEN** the caffeine corpus is well-formed, all scripts are
  shellcheck-clean, and the bats suite passes
- **THEN** `routine-selfcheck` exits 0

#### Scenario: Lint failure aborts before tests
- **WHEN** any checked script fails shellcheck
- **THEN** `routine-selfcheck` exits non-zero and surfaces the shellcheck
  output without running the bats suite

#### Scenario: Test failure
- **WHEN** shellcheck is clean but any bats test fails
- **THEN** `routine-selfcheck` exits non-zero and surfaces the bats output

#### Scenario: Malformed topic aborts first
- **WHEN** the caffeine lint reports a violation
- **THEN** `routine-selfcheck` exits non-zero surfacing it before the
  shellcheck stage
