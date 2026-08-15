# selfcheck Specification (delta)

## MODIFIED Requirements

### Requirement: Test names state the claim they defend and bodies prove it honestly
`bin/routine-test-lint` SHALL read every `@test` name under `test/` and refuse a name that does not state a claim: one opening with a mechanism word (`test`, `check`, `verify`, `should`, `it`, `ensure`, `does`, `works`, `handles`, `correctly`, or their plurals, each followed by a space), one shorter than three words, one longer than 100 characters, or one repeated within its own suite. The pattern SHALL match an opener followed by a literal space rather than a word boundary, since `\b` is unavailable in BSD grep and a boundary match misclassifies topic paths such as `testing/tdd`. Uniqueness SHALL be scoped to a single file, because bats runs and reports per suite and the same claim may legitimately hold of two subjects. The lint SHALL report every violation in one run, naming the file, the test name, and the rule, The lint SHALL also refuse a test body carrying no visible expectation: a bats test passes when its last command exits 0, so a body that asserts nothing can never fail and defends no claim. An expectation SHALL be recognised by token — a `[` or `[[` condition, bats' `status` or `output` handles, a `grep` or `diff` comparison, an `assert` or `refute` helper, `-eq` or `-ne`, or a leading `!` negation — never by parsing the shell, since a lint whose own correctness needs a lint is not an improvement; an unrecognised assertion form SHALL be answered by widening the token list. The lint SHALL name the naming rule and the body rule distinctly, because one failure rewrites a sentence and the other adds an expectation. The lint SHALL also refuse a negated assertion whose subject carries no positive assertion in the same body. A negated grep passes when its subject does not exist — a typed path, a deleted directory, or a glob that matched nothing all read as "the forbidden thing is absent" — so an unpaired negative cannot distinguish a satisfied claim from an unexamined one. The pairing SHALL be on the subject the negative names, since a positive assertion about some other file leaves the negative exactly as vacuous. A negation on `$output` SHALL be exempt from subject pairing only when the body also asserts `$status`. `$output` is always defined after `run` but not always non-empty: a crashed command leaves it empty, and a negated grep over an empty string passes, so an unpaired negation on `$output` reports the forbidden thing absent when in truth nothing ran. Asserting `$status` establishes that the command reached a known conclusion, which makes an empty `$output` a real observation rather than a missing one — `$status` is the pairing partner for `$output` exactly as an existence test is for a file. The lint SHALL also refuse a suite that uses `BATS_SUITE_TMPDIR` or `BATS_FILE_TMPDIR`, and a test that writes into `$ROUTINE_REPO_ROOT` — a redirect, `cp`, `mv`, `rm`, `mkdir`, `sed -i` or `touch` targeting the repository. Each bats test is a separate process with its own `BATS_TEST_TMPDIR`, and that boundary is why order dependence cannot arise here; a shared tmpdir or a write into the repository is the only way to opt out of it. Reads of `$ROUTINE_REPO_ROOT` SHALL remain unrestricted, since the content pins depend on them and a read cannot make one test depend on another. Removing the hazard is preferred to detecting it after the fact, which is why this rule exists and a seeded execution order does not. The lint SHALL report every violation in one run, naming the file, the test and the rule, and SHALL exit 0 when the corpus is clean and 1 when any name or body violates a rule.

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


#### Scenario: A shared tmpdir is refused
- **WHEN** a suite references `BATS_SUITE_TMPDIR` or `BATS_FILE_TMPDIR`
- **THEN** the lint exits non-zero naming that suite and the isolation rule

#### Scenario: A write into the repository is refused
- **WHEN** a test redirects, copies, moves, removes or creates a path
  under `$ROUTINE_REPO_ROOT`
- **THEN** the lint exits non-zero naming that test and the isolation rule

#### Scenario: Reading the repository stays unrestricted
- **WHEN** a test greps a file under `$ROUTINE_REPO_ROOT`
- **THEN** the lint accepts it
