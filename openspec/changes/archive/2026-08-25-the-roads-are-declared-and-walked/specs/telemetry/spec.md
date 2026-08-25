# telemetry Specification (delta)

## ADDED Requirements

### Requirement: The repository ships its own harness destination
`runs/routine/` SHALL exist in a fresh clone, carried by a tracked
marker (`runs/routine/README.md`) and ignore rules that re-include only
the marker, so a harness script gating routine itself always finds its
destination and its verdict is recorded instead of silently skipped;
every other path under `runs/` SHALL remain untracked, because run
evidence is session-local, script-owned state and the durable record
travels through `evidence/` and the specs. The no-invented-destination
rule SHALL stand unchanged: nothing is invented when the destination is
shipped.

#### Scenario: The marker survives a clone
- **WHEN** the repository is cloned fresh
- **THEN** `runs/routine/` exists and git tracks exactly one path under
  `runs/` — the marker

#### Scenario: Session state stays ignored
- **WHEN** telemetry lands in `runs/routine/telemetry.jsonl` or any
  other `runs/<app>/` path
- **THEN** git ignores it

#### Scenario: A repo-context gate records
- **WHEN** `routine-release-check` or `routine-convention-check` runs
  from the repository with no `TARGET`
- **THEN** `runs/routine/telemetry.jsonl` gains the harness line,
  because the destination the emit rule requires is now always there

### Requirement: Declared roads are walked or waivered
`lib/roads.txt` SHALL declare every telemetry event name the contracts
can emit — one event per line, `#` comments and blank lines ignored, a
road not yet exercised carrying the waiver form
`<event> — never walked: <why>`. `bin/routine-road-check [runs-dir]`
(default: the routine root's `runs/`) SHALL judge the declared list
against every `telemetry.jsonl` under that directory, at any depth, and
SHALL report in one run: an observed event that is not declared; a
declared, unwaivered event that no line ever recorded; and a waivered
event that was in fact walked, because a stale waiver misstates
coverage exactly the way a stale count misstates a suite. It SHALL exit
0 when every declared road is walked or honestly waivered and nothing
undeclared was observed, 1 when any violation is reported, and 2 on a
usage error, a missing roads file, or a missing runs directory. The
check SHALL read evidence and write none of it; its own invocation
SHALL be a declared road (`harness.roads`), recorded through the
harness wrapper like any other verdict, so the road the check opens is
walked by walking it. It SHALL remain a session and release-record
instrument rather than a clone-time gate, because run evidence is
session-local and a fresh clone holds nothing to judge.

#### Scenario: A clean tree passes
- **WHEN** every declared, unwaivered road appears in some telemetry
  line under the runs directory and no waivered road does
- **THEN** the check exits 0

#### Scenario: An undeclared road fails
- **WHEN** a telemetry line carries an event name absent from
  `lib/roads.txt`
- **THEN** the check exits 1 naming the event as undeclared

#### Scenario: An unwalked road fails
- **WHEN** a declared, unwaivered event appears in no telemetry line
- **THEN** the check exits 1 naming the event and the waiver form that
  would record the why

#### Scenario: A stale waiver fails
- **WHEN** a waivered event appears in a telemetry line
- **THEN** the check exits 1 naming the waiver as stale

#### Scenario: Every violation surfaces in one run
- **WHEN** several rules are broken at once
- **THEN** all violations are reported before the single non-zero exit

#### Scenario: Nested ticket evidence counts as walked
- **WHEN** an event appears only in a ticket's or an archived ticket's
  `telemetry.jsonl` under the runs directory
- **THEN** that road counts as walked

#### Scenario: Missing evidence is a refusal, not a verdict
- **WHEN** the runs directory or the roads file does not exist
- **THEN** the check exits 2 naming the missing path
