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
contains at least one scenario heading of either form — `## Scenario: <label>` for red-then-green behaviour (the label the audit binds tdd evidence to) or `## Characterization: <label>` for a green-at-birth pin whose coverage is the task's passing developer gate — at least one scenario using Given/When/Then
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

#### Scenario: A characterization heading satisfies the scenario rule
- **WHEN** a task carries `## Characterization: <label>` and no
  `## Scenario:` heading
- **THEN** the lint accepts it, and a task with neither heading still
  fails naming the rule

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
evidence behind the contract: a `## Evidence` section whose every
non-empty line matches `- <path> — <claim>` — the claim stating what
the file was found to contain or do, with `- <path> — ruled out:
<reason>` the blessed form for surveyed-and-rejected paths; a
`## Alternatives` section and an `## Assumptions` section each holding
at least one `- ` bullet, with the literal floor `- none — <why
nothing qualifies>` as the considered opt-out. `bin/routine-spec-lint`
SHALL check every Evidence line individually (one well-formed bullet
never masks a malformed sibling) and, once any task carries a
`defect.md`, SHALL additionally require a `## Reconciliation` line for
each defective task id matching `- <tid> — <what the defect
invalidated>`, matched without interpreting the id as a pattern. All
checks are mechanical form checks; the linter never judges the claim's
content — a false claim is the approve reader's catch, not the lint's. The file SHALL also carry a `Grounded-at: <sha>` header line (column 0, a 40-hex commit id — the target's HEAD when the evidence was gathered, obtained by reading the target, never writing it); the lint checks presence and form only.

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

#### Scenario: A claim-less evidence bullet fails
- **WHEN** an `## Evidence` line reads `- app/models/user.rb` with no
  ` — <claim>` part
- **THEN** the lint exits non-zero naming the line and the required
  form

#### Scenario: A bare id does not reconcile
- **WHEN** the only occurrence of a defective task id in
  `## Reconciliation` is inside other text (not a `- <tid> — <text>`
  line)
- **THEN** the lint exits non-zero naming the task id

#### Scenario: Silent Assumptions fail
- **WHEN** `## Assumptions` carries no bullet
- **THEN** the lint exits non-zero naming the section and the
  `- none — <why nothing qualifies>` floor

#### Scenario: A missing or malformed anchor fails
- **WHEN** `grounding.md` has no `Grounded-at:` line, or its value is
  not a 40-hex commit id
- **THEN** the lint exits non-zero naming the line and the form

### Requirement: The defect list survives the run
`routine-spec-lint` SHALL mirror every defect line it prints to stderr
into the ticket's script-owned `lint.log`, truncating the file at the
start of each run — after the usage check, so a usage error never
touches the ticket. A passing run SHALL leave `lint.log` empty. The
file is a script product: agents read it, never write it. Recovering
the defect list therefore never requires re-running the lint, so
information recovery is never charged against the revise budget.

#### Scenario: Defects persist for the next reader
- **WHEN** the lint fails with defects
- **THEN** `<ticket>/lint.log` carries each defect line printed to
  stderr

#### Scenario: A passing run clears the log
- **WHEN** the lint passes after an earlier failure
- **THEN** `<ticket>/lint.log` is empty

#### Scenario: Usage errors touch nothing
- **WHEN** the lint is invoked without a valid ticket directory
- **THEN** no `lint.log` is created or modified
