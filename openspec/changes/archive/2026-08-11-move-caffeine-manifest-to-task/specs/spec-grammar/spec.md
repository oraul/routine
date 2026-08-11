## MODIFIED Requirements

### Requirement: Spec lint checks ticket grammar structurally
`bin/routine-spec-lint <ticket-dir>` SHALL verify, with structural checks
only: `requirement.md` exists, contains a `# Requirement:` header and at
least one RFC 2119 keyword (SHALL, MUST, SHOULD, or MAY); every briefing
directory contains `briefing.md` and at least one task directory; every
`task.md` contains at least one scenario using Given/When/Then lines, a
`## Acceptance` section with at least one enumerated item, and a
`## Caffeine` section naming the task's topics (the list MAY be empty
beneath the heading). It SHALL exit 0 only when every check passes.

#### Scenario: Well-formed ticket passes
- **WHEN** a ticket satisfies every grammar rule
- **THEN** `routine-spec-lint` exits 0

#### Scenario: Missing requirement header
- **WHEN** `requirement.md` lacks a `# Requirement:` header
- **THEN** the lint exits non-zero naming `requirement.md` and the rule

#### Scenario: Task without a scenario
- **WHEN** a `task.md` has no Given/When/Then scenario
- **THEN** the lint exits non-zero naming that task file and the rule

#### Scenario: Task without a caffeine section
- **WHEN** a `task.md` has no `## Caffeine` section
- **THEN** the lint exits non-zero naming that task file and the rule
