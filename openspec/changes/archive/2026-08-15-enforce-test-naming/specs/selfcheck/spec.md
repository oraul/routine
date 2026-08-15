# selfcheck Specification (delta)

## ADDED Requirements

### Requirement: Test names state the claim they defend
`bin/routine-test-lint` SHALL read every `@test` name under `test/` and refuse a name that does not state a claim: one opening with a mechanism word (`test`, `check`, `verify`, `should`, `it`, `ensure`, `does`, `works`, `handles`, `correctly`, or their plurals, each followed by a space), one shorter than three words, one longer than 100 characters, or one repeated within its own suite. The pattern SHALL match an opener followed by a literal space rather than a word boundary, since `\b` is unavailable in BSD grep and a boundary match misclassifies topic paths such as `testing/tdd`. Uniqueness SHALL be scoped to a single file, because bats runs and reports per suite and the same claim may legitimately hold of two subjects. The lint SHALL report every violation in one run, naming the file, the test name, and the rule, and SHALL exit 0 when the corpus is clean and 1 when any name violates a rule.

#### Scenario: A clean corpus passes
- **WHEN** every test name states a claim
- **THEN** `routine-test-lint` exits 0

#### Scenario: A mechanism-flavored name is refused
- **WHEN** a test is named `it should work`
- **THEN** the lint exits non-zero naming that test and the opener rule

#### Scenario: A topic path is not a mechanism opener
- **WHEN** a test is named `testing/tdd teaches the loop's own discipline`
- **THEN** the lint passes it, because the opener rule requires a following space

#### Scenario: A label is not a claim
- **WHEN** a test name is shorter than three words or longer than 100 characters
- **THEN** the lint exits non-zero naming the length rule

#### Scenario: A repeated name inside one suite is ambiguous
- **WHEN** one file declares the same test name twice
- **THEN** the lint exits non-zero naming the duplicate, while the same name in two different files passes

#### Scenario: All violations surface in one run
- **WHEN** a corpus holds several bad names
- **THEN** the lint reports all of them before exiting non-zero

## MODIFIED Requirements

### Requirement: Selfcheck verifies lint cleanliness and test success
`bin/routine-selfcheck` SHALL run `bin/routine-caffeine-lint` first (a
malformed topic tree makes downstream results meaningless), then
`bin/routine-script-lint` (a script whose contract lies fails before
its tests can pass), then shellcheck over every script in `bin/` and
`lib/` and every caffeine sidecar (`caffeine/*/*.sh`) that exists, then
`bin/routine-test-lint` (a test whose name states no claim fails
before the suite runs), then the full bats suite under `test/`, and
SHALL exit 0 only when all stages succeed.

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

#### Scenario: A lying contract aborts before shellcheck
- **WHEN** any `bin/` script fails the script lint
- **THEN** `routine-selfcheck` exits non-zero and surfaces the lint
  output before the shellcheck stage

#### Scenario: A nameless claim aborts before the suite
- **WHEN** any test name fails the naming lint
- **THEN** `routine-selfcheck` exits non-zero surfacing it without
  running the bats suite

