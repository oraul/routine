# spec-grammar Specification (delta)

## MODIFIED Requirements

### Requirement: Spec lint checks ticket grammar structurally
`bin/routine-spec-lint <ticket-dir>` SHALL verify, with structural checks
only: `requirement.md` exists, contains a `# Requirement:` header, a
`Type: <bug|feature|greenfield|epic>` declaration, and at least one RFC
2119 keyword (SHALL, MUST, SHOULD, or MAY); every briefing directory
contains `briefing.md` and at least one task directory; every `task.md`
contains at least one `## Scenario: <label>` heading (the label the
audit binds evidence to), at least one scenario using Given/When/Then
lines, a `## Acceptance` section with at least one enumerated item, and
a `## Caffeine` section whose lines each match `- <topic>` and resolve
against `caffeine/` — and the list SHALL NOT be empty: `testing/tdd`
applies to any task, so a topicless manifest is unconsidered, not
inapplicable. It SHALL apply the type-specific structure rules of the
calibration and contract capabilities. It SHALL exit 0 only when every
check passes.

#### Scenario: Well-formed ticket passes
- **WHEN** a ticket satisfies every grammar rule
- **THEN** `routine-spec-lint` exits 0

#### Scenario: Missing requirement header
- **WHEN** `requirement.md` lacks a `# Requirement:` header
- **THEN** the lint exits non-zero naming `requirement.md` and the rule

#### Scenario: Missing type declaration
- **WHEN** `requirement.md` lacks a `Type:` line
- **THEN** the lint exits non-zero naming the four valid types

#### Scenario: Task without a scenario
- **WHEN** a `task.md` has no Given/When/Then scenario
- **THEN** the lint exits non-zero naming that task file and the rule

#### Scenario: Task without a caffeine section
- **WHEN** a `task.md` has no `## Caffeine` section
- **THEN** the lint exits non-zero naming that task file and the rule

#### Scenario: Task without a scenario label
- **WHEN** a `task.md` has Given/When/Then lines but no
  `## Scenario: <label>` heading
- **THEN** the lint exits non-zero naming that task file and the rule

#### Scenario: Empty manifest rejected
- **WHEN** a `task.md`'s `## Caffeine` section carries no topics
- **THEN** the lint exits non-zero naming that task file and pointing
  at `testing/tdd` as the floor
