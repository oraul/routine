# gates Specification (delta)

## MODIFIED Requirements

### Requirement: Analyst baseline lints the ticket and checks coherence
The analyst gate baseline SHALL resolve the ticket from
`ROUTINE_TICKET_DIR` (failing with a message when unset), SHALL fail
naming the exhausted revise limit when the ticket's telemetry records
more than 3 failed `spec.lint` runs **in the current specify episode** —
failures at or before the most recent `spec.defective` line do not
count, because re-specified work is new work — SHALL run
`routine-spec-lint` over it, SHALL then append any index rows missing
for existing task directories (the same append-only, file-ordered sync
`routine-next` performs), and SHALL verify the index is coherent with
the directory tree: every index row's task directory exists and every
task directory has an index row. The episode revise count SHALL come from one shared implementation (`lib/episode.sh`), so the gate that spends the budget and any reader that reports it can never disagree.

#### Scenario: No ticket context
- **WHEN** `routine-gate analyst` runs without `ROUTINE_TICKET_DIR`
- **THEN** it exits non-zero naming the missing variable

#### Scenario: Revise limit exhausted
- **WHEN** the ticket's telemetry holds 4 failed `spec.lint` events
  with no later `spec.defective` line
- **THEN** the analyst gate exits non-zero naming the revise limit

#### Scenario: Grammar failure fails the gate
- **WHEN** the ticket violates the spec grammar
- **THEN** the analyst gate exits non-zero surfacing the lint output

#### Scenario: Fresh ticket is coherent by construction
- **WHEN** a well-formed ticket has task directories but an empty index
- **THEN** the analyst baseline appends the rows as `pending` and passes

#### Scenario: Index row without a directory
- **WHEN** the index lists a task whose directory does not exist
- **THEN** the analyst baseline exits non-zero naming the row

#### Scenario: A defect return opens a fresh budget
- **WHEN** the telemetry holds 4 failed `spec.lint` events, then a
  `spec.defective` line, then 1 failed `spec.lint`
- **THEN** the analyst gate does not name the revise limit

#### Scenario: One counter, two consumers
- **WHEN** the same telemetry is counted by the analyst gate and by a
  reader of the budget
- **THEN** both derive the count from the shared library function
