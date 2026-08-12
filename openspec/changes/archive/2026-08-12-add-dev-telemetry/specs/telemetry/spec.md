## ADDED Requirements

### Requirement: Ticket-bound events carry derived attribution
Events emitted through the ticket-bound wrapper SHALL carry the ticket
directory's basename in the `ticket` field and the `in_progress` index
row's task id in the `task` field when one exists. Attribution SHALL be
derived from the ticket state, never passed by the caller; an empty
`task` field means no task was in progress at emission time.

#### Scenario: Gate event names its ticket and task
- **WHEN** `routine-gate developer` runs with a ticket whose index holds
  an `in_progress` row
- **THEN** the emitted gate lines carry the ticket's id and that task's id

#### Scenario: No task in progress leaves task empty
- **WHEN** a ticket-bound event is emitted while no index row is
  `in_progress`
- **THEN** the line carries the ticket id and an empty `task` field
