## ADDED Requirements

### Requirement: Analyst baseline lints the ticket and checks coherence
The analyst gate baseline SHALL resolve the ticket from
`ROUTINE_TICKET_DIR` (failing with a message when unset), SHALL run
`routine-spec-lint` over it, and SHALL verify the index is coherent with the
directory tree: every index row's task directory exists and every task
directory has an index row.

#### Scenario: No ticket context
- **WHEN** `routine-gate analyst` runs without `ROUTINE_TICKET_DIR`
- **THEN** it exits non-zero saying a ticket context is required

#### Scenario: Grammar failure fails the gate
- **WHEN** the ticket fails `routine-spec-lint`
- **THEN** `routine-gate analyst` exits non-zero surfacing the lint output

#### Scenario: Index row without a directory
- **WHEN** the index lists a task whose directory does not exist
- **THEN** the analyst baseline exits non-zero naming the row
