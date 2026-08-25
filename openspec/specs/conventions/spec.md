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
hit. The pattern list SHALL have one implementation, in `lib/sensitive.sh`,
shared by every check that hunts these shapes. The checker script, its test
file, and the shared pattern library SHALL be excluded from the diff scan,
since they must name the patterns they hunt.

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

### Requirement: The pull request body is checked before it ships
`bin/routine-pr-body-check <file>` SHALL scan a pull request body,
saved to a file by whoever fetched it, for the shared sensitive
patterns, and SHALL exit non-zero naming each hit's line number and
pattern class — never echoing the matched text itself, since the
check's output travels where the body was about to. A clean body
SHALL exit zero. A missing argument or unreadable file SHALL exit 2
with usage. Every run SHALL emit one `harness.prbody` telemetry line,
and the road SHALL be declared in `lib/roads.txt`. The check decides
the scrub — the hard rule that no session URL or credential shape
ships in a pull request body stops being held by vigilance alone —
while what to write instead stays the author's.

#### Scenario: An injected session URL is caught
- **WHEN** the saved body carries a session URL in its footer
- **THEN** the check exits non-zero naming the line and the pattern
  class, without printing the URL

#### Scenario: A clean body passes
- **WHEN** the saved body carries prose and the bare attribution
  footer
- **THEN** the check exits 0

#### Scenario: No body file is a usage error
- **WHEN** the check runs with no argument or a path that is not a
  readable file
- **THEN** it exits 2 with usage
