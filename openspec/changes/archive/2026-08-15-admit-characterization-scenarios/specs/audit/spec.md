# audit Specification (delta)

## MODIFIED Requirements

### Requirement: The run audit replays evidence against the protocol
`bin/routine-audit <ticket-dir>` SHALL read the ticket's
`telemetry.jsonl`, `index.tsv`, and task files — writing nothing —
and SHALL exit 0 only when the recorded run matches the protocol:
the first event is `ticket.new`; a `gate.preflight` line with exit 0
exists; a `gate.analyst` line with exit 0 exists; a `ticket.approve`
line with exit 0 exists — the human checkpoint leaves evidence; every
`done` index row has a passing `ticket.next`, a passing
`gate.developer`, and a passing `ticket.done`, plus at least one
passing `tdd.green` whose scenario shows an earlier failing `tdd.red`
for the same task — except a task whose `task.md` carries only
`## Characterization: <label>` headings and no `## Scenario:` heading,
which needs no tdd evidence at all: a characterization pin is green at
birth, `routine-tdd red` would refuse it as a red that isn't red, and
its coverage is the task's passing developer gate, which this
requirement already demands and which the record attributes to the
task;
every `## Scenario: <label>` heading in a done task's `task.md` has a
passing `tdd.green` recorded under that label — exactly the label, or
the label followed by ` [<hash>]` (the command binding `routine-tdd`
appends) — so coverage is per scenario, not per task; every `.sh`
topic in a done task's manifest has a `gate.developer.script` line
naming it with exit 0 and every doc-only topic has its
`gate.developer.doc` line; and per task, passing `ticket.block` and
`ticket.unblock` counts balance. It SHALL report every violation in
one run, naming the task and the missing or out-of-order evidence.

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

#### Scenario: A skipped human checkpoint is a violation
- **WHEN** the ticket's telemetry holds no passing `ticket.approve` line
- **THEN** the audit exits non-zero naming the missing approval

#### Scenario: An uncovered labeled scenario is a violation
- **WHEN** a done task's `task.md` carries `## Scenario: exports are
  streamed` and no passing `tdd.green` is recorded under that label
- **THEN** the audit exits non-zero naming the task and the label

#### Scenario: A characterization-only task concludes on its gate
- **WHEN** a done task's `task.md` carries only `## Characterization:`
  headings and the record holds its passing `gate.developer`
- **THEN** the audit demands no `tdd.green` for that task and reports
  no violation

#### Scenario: A tdd label beside a characterization label still demands its green
- **WHEN** a done task carries both heading forms and the
  `## Scenario:` label has no covering `tdd.green`
- **THEN** the audit reports that label as a violation, unchanged
