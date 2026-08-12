# spec-grammar Specification

## Purpose

The structural contract for ticket artifacts: what a requirement, briefing,
and task file must contain before development may start, enforced by grep/awk
alone.

## Requirements

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

### Requirement: Grounding is part of the ticket grammar
Every ticket SHALL carry a ticket-level `grounding.md` holding the
evidence behind the contract: a `## Evidence` section with at least one
`- ` bullet (files read and why they matter), a `## Alternatives`
section (decompositions rejected, with reasons), and a `## Assumptions`
section (claims to re-verify). `bin/routine-spec-lint` SHALL check the
structure — headers present, Evidence non-empty — and, once any task
carries a `defect.md`, SHALL additionally require a `## Reconciliation`
section naming each defective task's id, so grounding never outlives
the evidence that invalidated it. All checks are structural; the linter
never judges content.

#### Scenario: Missing grounding fails the lint
- **WHEN** a ticket has no `grounding.md`
- **THEN** the lint exits non-zero naming the file

#### Scenario: Empty evidence fails the lint
- **WHEN** `grounding.md` exists but `## Evidence` has no bullet
- **THEN** the lint exits non-zero naming the section

#### Scenario: A defect return demands reconciliation
- **WHEN** `briefings/01-x/tasks/02-y/defect.md` exists and
  `grounding.md` has no `## Reconciliation` line naming `01-02`
- **THEN** the lint exits non-zero naming the task id
