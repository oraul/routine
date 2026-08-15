# selfcheck Specification (delta)

## MODIFIED Requirements

### Requirement: Test names state the claim they defend and bodies prove it
`bin/routine-test-lint` SHALL read every `@test` name under `test/` and refuse a name that does not state a claim: one opening with a mechanism word (`test`, `check`, `verify`, `should`, `it`, `ensure`, `does`, `works`, `handles`, `correctly`, or their plurals, each followed by a space), one shorter than three words, one longer than 100 characters, or one repeated within its own suite. The pattern SHALL match an opener followed by a literal space rather than a word boundary, since `\b` is unavailable in BSD grep and a boundary match misclassifies topic paths such as `testing/tdd`. Uniqueness SHALL be scoped to a single file, because bats runs and reports per suite and the same claim may legitimately hold of two subjects. The lint SHALL report every violation in one run, naming the file, the test name, and the rule, The lint SHALL also refuse a test body carrying no visible expectation: a bats test passes when its last command exits 0, so a body that asserts nothing can never fail and defends no claim. An expectation SHALL be recognised by token — a `[` or `[[` condition, bats' `status` or `output` handles, a `grep` or `diff` comparison, an `assert` or `refute` helper, `-eq` or `-ne`, or a leading `!` negation — never by parsing the shell, since a lint whose own correctness needs a lint is not an improvement; an unrecognised assertion form SHALL be answered by widening the token list. The lint SHALL name the naming rule and the body rule distinctly, because one failure rewrites a sentence and the other adds an expectation. It SHALL report every violation in one run, naming the file, the test and the rule, and SHALL exit 0 when the corpus is clean and 1 when any name or body violates a rule.

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
