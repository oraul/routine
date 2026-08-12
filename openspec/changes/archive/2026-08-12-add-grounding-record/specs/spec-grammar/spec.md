## ADDED Requirements

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
