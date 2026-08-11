## Purpose

The structural contract for ticket artifacts: what a requirement, briefing,
and task file must contain before development may start, enforced by grep/awk
alone.

## ADDED Requirements

### Requirement: Spec lint checks ticket grammar structurally
`bin/routine-spec-lint <ticket-dir>` SHALL verify, with structural checks
only: `requirement.md` exists, contains a `# Requirement:` header and at
least one RFC 2119 keyword (SHALL, MUST, SHOULD, or MAY); every briefing
directory contains `briefing.md` with a `## Caffeine` section and at least
one task directory; every `task.md` contains at least one scenario using
Given/When/Then lines and a `## Acceptance` section with at least one
enumerated item. It SHALL exit 0 only when every check passes.

#### Scenario: Well-formed ticket passes
- **WHEN** a ticket satisfies every grammar rule
- **THEN** `routine-spec-lint` exits 0

#### Scenario: Missing requirement header
- **WHEN** `requirement.md` lacks a `# Requirement:` header
- **THEN** the lint exits non-zero naming `requirement.md` and the rule

#### Scenario: Task without a scenario
- **WHEN** a `task.md` has no Given/When/Then scenario
- **THEN** the lint exits non-zero naming that task file and the rule

### Requirement: Lint failures name file and rule
Every lint failure SHALL print the offending file path and the violated rule;
the linter SHALL report all failures in a run, not just the first.

#### Scenario: Two defects reported together
- **WHEN** a ticket has a briefing without tasks and a task without
  acceptance items
- **THEN** one run reports both, each naming its file

### Requirement: Lint emits evidence
`routine-spec-lint` SHALL emit exactly one `spec.lint` telemetry line per run
into the ticket's `telemetry.jsonl`, recording the exit code.

#### Scenario: Failed lint recorded
- **WHEN** the lint fails
- **THEN** the ticket's `telemetry.jsonl` gains one `spec.lint` line with a
  non-zero exit value
