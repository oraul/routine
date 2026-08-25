# conventions Specification (delta)

## MODIFIED Requirements

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

## ADDED Requirements

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
