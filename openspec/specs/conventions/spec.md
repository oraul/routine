# conventions Specification

## Purpose

Mechanical enforcement of the rules that keep the repository trustworthy:
no sensitive data ever lands, and history stays readable by convention.

## Requirements

### Requirement: Sensitive patterns fail the check
`bin/routine-convention-check <base-ref>` SHALL scan the diff since
`<base-ref>` and every commit message in that range for sensitive patterns
— session URLs, common credential shapes (GitHub tokens, API-key prefixes,
AWS key ids), and private key blocks — and SHALL exit non-zero naming each
hit. The checker script and its test file SHALL be excluded from the diff
scan, since they must name the patterns they hunt.

#### Scenario: Leaked token in the diff
- **WHEN** a commit in the range adds a GitHub-token-shaped string
- **THEN** the check exits non-zero naming the pattern

#### Scenario: Session URL in a commit message
- **WHEN** a commit message in the range contains a session URL
- **THEN** the check exits non-zero naming the commit

### Requirement: Commit grammar is enforced
For every non-merge commit since `<base-ref>`, the subject SHALL match the
conventional format (`type(scope)?: subject`, types
`spec|feat|fix|test|refactor|docs|ci|chore`) and SHALL be at most 72
characters; commits of a behavior type (`spec|feat|fix|test|refactor`)
SHALL carry a `Change:` trailer. Merge commits are exempt.

#### Scenario: Malformed subject
- **WHEN** a commit subject reads `updated stuff`
- **THEN** the check exits non-zero naming the commit and the rule

#### Scenario: Behavior commit without its trailer
- **WHEN** a `feat:` commit carries no `Change:` trailer
- **THEN** the check exits non-zero naming the commit

### Requirement: The check runs on every pull request
CI SHALL run `routine-convention-check` against the pull request's base on
every pull request, as its own job.

#### Scenario: PR with a violation
- **WHEN** a pull request contains a commit violating any rule above
- **THEN** the `conventions` job fails
