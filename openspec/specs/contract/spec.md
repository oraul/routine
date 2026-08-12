# contract Specification

## Purpose

The analyst↔developer seam as an explicit, typed, enforced contract: what
each agent guarantees the other, checked before the handoff instead of
discovered after it.

## Requirements

### Requirement: The contract is typed and its topics are checked at lint
Each work type SHALL require its contract topics in `requirement.md`,
enforced by `routine-spec-lint` at the analyst gate: `bug` requires
`## Reproduction`; `feature` requires `## Touchpoints`; `greenfield`
requires `## Contracts`; `epic` requires `## Order` (and at least two
briefings). A requirement missing its type's topic SHALL fail lint naming
the section.

#### Scenario: Feature without touchpoints
- **WHEN** a `Type: feature` requirement lacks `## Touchpoints`
- **THEN** lint exits non-zero naming the missing section

#### Scenario: Greenfield without contracts
- **WHEN** a `Type: greenfield` requirement lacks `## Contracts`
- **THEN** lint exits non-zero naming the missing section

### Requirement: Manifests are valid at the handoff
Every non-empty line under a task's `## Caffeine` SHALL match the exact
form `- <topic>`, and every named topic SHALL resolve to
`caffeine/<topic>.sh` or `caffeine/<topic>.md` at lint time — the analyst
gate, not the developer gate, is where an unbuildable manifest fails.

#### Scenario: Unresolvable topic fails the analyst side
- **WHEN** a task manifest names `ruby/nonexistent`
- **THEN** `routine-spec-lint` exits non-zero naming the topic

#### Scenario: Malformed bullet fails
- **WHEN** a manifest lists a topic as `* ruby/rails`
- **THEN** lint exits non-zero naming the line form

### Requirement: The defect return is scripted
`bin/routine-defect <ticket-dir> <reason>` SHALL be the developer's only
path for returning a defective spec: it SHALL refuse without a non-empty
reason or without an `in_progress` task, SHALL write the reason to the
task's `defect.md`, SHALL reset the task to `pending`, and SHALL emit one
`spec.defective` telemetry event carrying a non-zero exit value.

#### Scenario: Defect return with a reason
- **WHEN** the developer runs `routine-defect <ticket> "scenarios
  contradict"`
- **THEN** `defect.md` exists in the task, the task is `pending`, and the
  ticket's telemetry gains one `spec.defective` line

#### Scenario: Refusal without a reason
- **WHEN** `routine-defect` runs with no reason argument
- **THEN** it exits non-zero and changes nothing

### Requirement: The revise limit is counted, not remembered
The analyst gate SHALL fail once the ticket's telemetry records more
than 3 failed `spec.lint` runs in the current specify episode, naming
the exhausted limit — the abort decision is the script's, never the
LLM's memory. A `spec.defective` line opens a new episode: failures at
or before it SHALL NOT count against the limit.

#### Scenario: Fourth failed lint aborts
- **WHEN** a ticket's telemetry holds 4 `spec.lint` events with non-zero
  exit and no later `spec.defective` line
- **THEN** `routine-gate analyst` exits non-zero naming the revise limit

#### Scenario: The defect return resets the count
- **WHEN** a `spec.defective` line follows the failed lints
- **THEN** only failures after it count toward the limit

### Requirement: The analyst's grounding survives the analyst
The analyst SHALL record the ground its contract stands on in the
ticket's `grounding.md` before the artifacts are gated, and on any
fresh invocation against an existing ticket (a defect return, a new
specify episode) SHALL re-ground from `grounding.md` and every
`defect.md` before re-deriving — and SHALL NOT rename or renumber
existing task directories on a re-specify (the index is append-only and
orphan rows are gate-fatal; restructuring means `routine-abort` and a
fresh ticket). Reconciliation after a defect return is enforced by the
lint, never by memory.

#### Scenario: Fresh invocation re-grounds first
- **WHEN** the analyst prompt is read
- **THEN** it instructs writing grounding.md before the gate and
  re-grounding from grounding.md and defect.md on re-entry, and forbids
  renaming existing task directories
