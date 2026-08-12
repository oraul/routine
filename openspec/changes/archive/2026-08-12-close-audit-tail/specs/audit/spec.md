## MODIFIED Requirements

### Requirement: The run audit replays evidence against the protocol
`bin/routine-audit <ticket-dir>` SHALL read the ticket's
`telemetry.jsonl`, `index.tsv`, and task manifests — writing nothing —
and SHALL exit 0 only when the recorded run matches the protocol:
the first event is `ticket.new`; a `gate.preflight` line with exit 0
exists; a `gate.analyst` line with exit 0 exists; every `done` index
row has a passing `ticket.next`, at least one passing `tdd.green` whose
scenario shows an earlier failing `tdd.red` for the same task, a passing
`gate.developer`, and a passing `ticket.done`; every `.sh` topic in a
done task's manifest has a `gate.developer.script` line naming it with
exit 0 and every doc-only topic has its `gate.developer.doc` line; and
per task, passing `ticket.block` and `ticket.unblock` counts balance.
It SHALL report every violation in one run, naming the task and the
missing or out-of-order evidence.

#### Scenario: A complete run passes
- **WHEN** the ticket's telemetry records the full protocol for every
  done task
- **THEN** `routine-audit` exits 0

#### Scenario: Green without red is a violation
- **WHEN** a done task has a `tdd.green` whose scenario never recorded
  a failing `tdd.red` before it
- **THEN** the audit exits non-zero naming the task and scenario

#### Scenario: A skipped stage is a violation
- **WHEN** a done task has no passing `gate.developer` line
- **THEN** the audit exits non-zero naming the task and the gate

#### Scenario: Manifest topic without evidence
- **WHEN** a done task's manifest names a `.sh` topic with no green
  `gate.developer.script` line for it
- **THEN** the audit exits non-zero naming the task and topic

#### Scenario: Unbalanced block
- **WHEN** a task records more passing `ticket.block` lines than
  `ticket.unblock` lines
- **THEN** the audit exits non-zero naming the task

#### Scenario: All violations in one run
- **WHEN** a ticket holds two independent violations
- **THEN** one audit run reports both

#### Scenario: Missing preflight is a violation
- **WHEN** the ticket's telemetry holds no `gate.preflight` line with
  exit 0
- **THEN** the audit exits non-zero naming the missing gate
