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
shared by every check that hunts these shapes. The hunters' own files —
each checker script, its test file, and the shared pattern library — SHALL
be excluded from the diff scan, since they must name the patterns they
hunt.

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

### Requirement: A delta carries what it modifies
`bin/routine-change-check <change-id>` SHALL judge every requirement
under a `## MODIFIED Requirements` section of the change's deltas
against the live spec it modifies: each line of the live requirement —
heading to next heading, blank lines exempt — must survive into the
delta's version, either as an identical line or inside an extended
one, and the check SHALL exit non-zero naming the capability, the
requirement, and the first line the delta lost. A requirement the
delta claims to modify that the live spec does not hold SHALL also
fail by name. `## ADDED Requirements` sections carry nothing and are
exempt. A missing or unknown change id SHALL exit 2 with usage. Every
run SHALL emit one `harness.change` telemetry line, and the road
SHALL be declared in `lib/roads.txt`. The check runs before sync —
after sync the live spec already contains the delta and the
comparison decides nothing — and it hunts the dropped-line class: a
line whose text happens to survive inside an unrelated line can
escape it, so byte-exactness outside stated additions stays the
author's diff, while the silent loss that already shipped once
becomes an exit code. A removal the delta declares SHALL NOT count as
a loss: a `## Removed Lines` section in the delta file, holding one
`- <text>` bullet per deliberately dropped live line, exempts exactly
those lines and no others, and the check SHALL still refuse every
undeclared loss in the same run. The declaration is a statement of
intent the author writes and the reviewer reads — the check decides
only whether a loss was declared, never whether the removal was
wise.

#### Scenario: A complete carry passes
- **WHEN** a modified requirement's delta holds every live line,
  some extended in place, plus its additions
- **THEN** the check exits 0

#### Scenario: A dropped line is named
- **WHEN** the delta's version of a modified requirement lost one
  live line
- **THEN** the check exits non-zero naming the capability, the
  requirement, and the lost line

#### Scenario: Modifying a requirement that does not exist fails
- **WHEN** a delta's MODIFIED section names a requirement absent from
  the live spec
- **THEN** the check exits non-zero naming it

#### Scenario: An unknown change id is a usage error
- **WHEN** the check runs with no argument or an id no change
  directory holds
- **THEN** it exits 2 with usage

#### Scenario: A declared removal is not a loss
- **WHEN** a modified requirement's delta drops a live line and the
  delta file's `## Removed Lines` section carries that line as a
  bullet
- **THEN** the check exits 0

#### Scenario: An undeclared loss still fails beside a declared one
- **WHEN** one dropped line is declared and another is not
- **THEN** the check exits non-zero naming only the undeclared line
