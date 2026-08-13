# spec-grammar Specification (delta)

## ADDED Requirements

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
