## MODIFIED Requirements

### Requirement: Ticket ids are allocated sequentially by script
`bin/routine-ticket-new` SHALL allocate the next sequential zero-padded
4-digit ticket id under `runs/<app>/tickets/`, SHALL create the ticket
directory with an empty `index.tsv`, SHALL emit one `ticket.new` telemetry
line into the created ticket's `telemetry.jsonl`, and SHALL print the
ticket path.

#### Scenario: First ticket
- **WHEN** no tickets exist and `routine-ticket-new` runs
- **THEN** `tickets/0001/` exists with an empty `index.tsv`, its
  `telemetry.jsonl` holds one `ticket.new` line, and its path is printed

#### Scenario: Sequential allocation skips archived ids
- **WHEN** tickets `0001` and `archive/0002` exist
- **THEN** `routine-ticket-new` creates `0003`
