# telemetry Specification (delta)

## MODIFIED Requirements

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
Where the machine holds no run corpus, the check SHALL report that it
decided nothing, naming the absent corpus, and SHALL exit 0 without
asserting coverage: it cannot distinguish an unwalked road from an
unobserved one, so reporting every declared road as unwalked states a
judgment it never made. A run corpus SHALL mean ticket telemetry — the
same file set `bin/routine-retro` aggregates and `bin/routine-evidence`
counts — and SHALL NOT mean telemetry of any kind, because the harness
tier records the harness's own footprint rather than evidence that any
road was walked by a run. On the undecided path the check SHALL NOT
emit its own road: a check that writes into the corpus it judges makes
itself decidable on its next invocation, which is how one gate's
footprint became another's evidence. That is the posture the render
check already takes toward an absent corpus, and it is what lets a
release instrument run where the corpus may or may not be.

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

#### Scenario: An empty corpus decides nothing
- **WHEN** the check runs against a runs directory that exists and holds
  no telemetry line at all
- **THEN** it prints that no road was decided and exits 0, naming
  neither an undeclared nor an unwalked road

#### Scenario: A corpus that exists still decides
- **WHEN** the runs directory holds at least one telemetry line
- **THEN** both the undeclared-road and unwalked-road rules decide as
  before

#### Scenario: A harness footprint is not a run corpus
- **WHEN** the runs directory holds harness telemetry but no ticket
  telemetry
- **THEN** the check reports that it decided nothing and exits 0

#### Scenario: The undecided path leaves the corpus unchanged
- **WHEN** the check runs twice in a row where no run corpus exists
- **THEN** the second run decides exactly what the first did, because
  the first wrote no telemetry

## Removed Lines

- Where the runs directory holds no telemetry at all, the check SHALL
- report that it decided nothing, naming the absent corpus, and SHALL
- exit 0 without asserting coverage: a corpus-less checkout cannot
- distinguish an unwalked road from an unobserved one, so reporting
- every declared road as unwalked states a judgment it never made. That
- is the posture the render check already takes toward an absent corpus,
- and it is what lets a release instrument run where the corpus may or
- may not be.
