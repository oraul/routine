# selfcheck Specification

## Purpose

The harness integrity gate: proves the repo's scripts are lint-clean and its
test suite is green before any other guarantee is trusted.

## Requirements

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

### Requirement: Test names state the claim they defend and bodies prove it honestly
`bin/routine-test-lint` SHALL read every `@test` name under `test/` and refuse a name that does not state a claim: one opening with a mechanism word (`test`, `check`, `verify`, `should`, `it`, `ensure`, `does`, `works`, `handles`, `correctly`, or their plurals, each followed by a space), one shorter than three words, one longer than 100 characters, or one repeated within its own suite. The pattern SHALL match an opener followed by a literal space rather than a word boundary, since `\b` is unavailable in BSD grep and a boundary match misclassifies topic paths such as `testing/tdd`. Uniqueness SHALL be scoped to a single file, because bats runs and reports per suite and the same claim may legitimately hold of two subjects. The lint SHALL report every violation in one run, naming the file, the test name, and the rule, The lint SHALL also refuse a test body carrying no visible expectation: a bats test passes when its last command exits 0, so a body that asserts nothing can never fail and defends no claim. An expectation SHALL be recognised by token — a `[` or `[[` condition, bats' `status` or `output` handles, a `grep` or `diff` comparison, an `assert` or `refute` helper, `-eq` or `-ne`, or a leading `!` negation — never by parsing the shell, since a lint whose own correctness needs a lint is not an improvement; an unrecognised assertion form SHALL be answered by widening the token list. The lint SHALL name the naming rule and the body rule distinctly, because one failure rewrites a sentence and the other adds an expectation. The lint SHALL also refuse a negated assertion whose subject carries no positive assertion in the same body. A negated grep passes when its subject does not exist — a typed path, a deleted directory, or a glob that matched nothing all read as "the forbidden thing is absent" — so an unpaired negative cannot distinguish a satisfied claim from an unexamined one. The pairing SHALL be on the subject the negative names, since a positive assertion about some other file leaves the negative exactly as vacuous. A negation on `$output` SHALL be exempt from subject pairing only when the body also asserts `$status`. `$output` is always defined after `run` but not always non-empty: a crashed command leaves it empty, and a negated grep over an empty string passes, so an unpaired negation on `$output` reports the forbidden thing absent when in truth nothing ran. Asserting `$status` establishes that the command reached a known conclusion, which makes an empty `$output` a real observation rather than a missing one — `$status` is the pairing partner for `$output` exactly as an existence test is for a file. The lint SHALL report every violation in one run, naming the file, the test and the rule, and SHALL exit 0 when the corpus is clean and 1 when any name or body violates a rule.

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

#### Scenario: A body that asserts nothing is refused
- **WHEN** a test body sets up fixtures and carries no expectation token
- **THEN** the lint exits non-zero naming that test and the body rule

#### Scenario: Every token form the corpus uses is accepted
- **WHEN** a body asserts through a bracket condition, a status or output
  check, a grep or diff, an assert or refute helper, or a negation
- **THEN** the lint accepts it

#### Scenario: The two rule families are told apart
- **WHEN** one test has a bad name and another an empty body
- **THEN** the output names the naming rule for the first and the body
  rule for the second

#### Scenario: A negative assertion alone is refused
- **WHEN** a body negates a grep against a file and asserts nothing else
  about that file
- **THEN** the lint exits non-zero naming that test and the pairing rule

#### Scenario: A positive assertion on the same subject protects it
- **WHEN** a body asserts the file exists, or greps it positively, beside
  the negation
- **THEN** the lint accepts it

#### Scenario: A positive assertion on some other subject does not
- **WHEN** the only positive assertion names a different file than the
  negation does
- **THEN** the lint exits non-zero, because the negation is still vacuous

#### Scenario: A negation against run output is exempt
- **WHEN** a body negates a grep against `$output`
- **THEN** the lint accepts it without requiring a pairing

#### Scenario: A negation on output without a status assertion is refused
- **WHEN** a body negates a grep over `$output` and never asserts `$status`
- **THEN** the lint exits non-zero, because a crashed command would
  satisfy that negation

#### Scenario: A status assertion pairs a negation on output
- **WHEN** the body asserts `$status` beside the negation
- **THEN** the lint accepts it

### Requirement: A suite must notice when its script is gutted
`bin/routine-mutation-check` SHALL, for each script in `bin/`, replace that script's body with a stub that exits 0 silently, run the suite the script declares in its `routine-test:` frontmatter, and require that suite to fail. A suite that still passes against a gutted script is not constraining that script's behaviour, and the check SHALL name the script and the suite together without guessing which is at fault. The original script SHALL be restored through a trap on `EXIT`, `INT` and `TERM`, so an interrupted run never leaves a gutted script on disk — a check that reports correctly and leaves the repository broken is worse than no check. The check SHALL print how many scripts were mutated and how many suites noticed, and SHALL exit 0 when every suite noticed, 1 when any suite stayed green, and 2 on usage. It SHALL NOT run inside `routine-selfcheck`: it invokes one suite per script and would make the ordinary gate too slow to run, and a gate people avoid running decides nothing.

#### Scenario: A suite that notices its gutted script passes the check
- **WHEN** a script is replaced by a stub and its declared suite fails
- **THEN** the check counts that script as covered

#### Scenario: A suite that stays green is named
- **WHEN** a script is replaced by a stub and its declared suite still passes
- **THEN** the check names that script and its suite and exits non-zero

#### Scenario: The script is restored even when interrupted
- **WHEN** the check is interrupted mid-run
- **THEN** every mutated script is restored to its original content

#### Scenario: The summary counts both sides
- **WHEN** the check finishes
- **THEN** it prints how many scripts were mutated and how many suites noticed
