# contract Specification (delta)

## MODIFIED Requirements

### Requirement: The contract is typed and its topics are checked at lint
Each work type SHALL require its contract topics in `requirement.md`,
enforced by `routine-spec-lint` at the analyst gate: `bug` requires
`## Reproduction`; `feature` requires `## Touchpoints`; `greenfield`
requires `## Contracts`; `epic` requires `## Order` (and at least two
briefings). A requirement missing its type's topic SHALL fail lint naming
the section.
 A defect return SHALL be bounded per task by the same shared counter file: past 3 `spec.defective` lines for one task, `routine-defect` SHALL refuse and name `routine-abort`, matching the shape the analyst's exhausted revise budget already uses. The bound is per task rather than per ticket, because a ticket whose tasks each returned once carries three healthy signals while a task returned three times carries one sick spec.
#### Scenario: Feature without touchpoints
- **WHEN** a `Type: feature` requirement lacks `## Touchpoints`
- **THEN** lint exits non-zero naming the missing section

#### Scenario: Greenfield without contracts
- **WHEN** a `Type: greenfield` requirement lacks `## Contracts`
- **THEN** lint exits non-zero naming the missing section


#### Scenario: An endlessly returned task is refused
- **WHEN** a task records a fourth `spec.defective`
- **THEN** `routine-defect` refuses and names `routine-abort`
