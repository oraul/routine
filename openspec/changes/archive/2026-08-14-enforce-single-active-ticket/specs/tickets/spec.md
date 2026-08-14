# tickets Specification (delta)

## MODIFIED Requirements

### Requirement: Ticket ids are allocated sequentially by script
`bin/routine-ticket-new` SHALL allocate the next sequential zero-padded
4-digit ticket id under `runs/<app>/tickets/`, SHALL create the ticket
directory with an empty `index.tsv`, SHALL emit one `ticket.new` telemetry
line into the created ticket's `telemetry.jsonl`, and SHALL print the
ticket path. It SHALL refuse — a distinct exit naming the incumbent ticket and both roads out, adopting it or ending it — while any non-archived ticket directory exists for the app: WIP is 1, and a run that died mid-flight must be adopted or ended, never orphaned by a second allocation. Archived tickets SHALL NOT block allocation.

#### Scenario: First ticket
- **WHEN** no tickets exist and `routine-ticket-new` runs
- **THEN** `tickets/0001/` exists with an empty `index.tsv`, its
  `telemetry.jsonl` holds one `ticket.new` line, and its path is printed

#### Scenario: Sequential allocation skips archived ids
- **WHEN** tickets `0001` and `archive/0002` exist
- **THEN** `routine-ticket-new` creates `0003`

#### Scenario: A live ticket blocks a second allocation
- **WHEN** `tickets/0001` exists and `routine-ticket-new` runs
- **THEN** it exits non-zero naming `0001`, creates nothing, and names
  adopting or ending it as the roads out

#### Scenario: Archived tickets never block
- **WHEN** only `archive/0001` exists
- **THEN** `routine-ticket-new` creates `0002`
