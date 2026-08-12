## MODIFIED Requirements

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
