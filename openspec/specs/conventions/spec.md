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
CI SHALL run `routine-convention-check` as its own job on every pull
request and on every push to main. The diff base SHALL be the pull
request's base on pull-request events and the pre-push tip
(`github.event.before`) on pushes — falling back to the tip's parent
when the pre-push tip is the zero hash or unreachable — so pushed
history (the merge commit included) is scanned exactly once and old
history is never rescanned.

#### Scenario: PR with a violation
- **WHEN** a pull request contains a commit violating any rule above
- **THEN** the `conventions` job fails

#### Scenario: The merge commit is scanned on main
- **WHEN** a pull request merges to main
- **THEN** the push-triggered `conventions` job checks the pushed
  commits — the merge commit's message included — instead of skipping
