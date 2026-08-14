# panel Specification (delta)

## ADDED Requirements

### Requirement: The panel is computed from script-owned state
`bin/routine-panel` SHALL print one self-contained HTML page to stdout,
derived entirely from script-owned state — telemetry, index files,
ticket logs and the caffeine corpus — and SHALL write no file of its
own. The page SHALL reference no external asset, so it renders from a
local file with no network and no server. A corpus with no runs SHALL
render an honest empty page rather than a fabricated one.

#### Scenario: The page stands alone
- **WHEN** `routine-panel` runs over a corpus
- **THEN** it prints HTML that names no external script, stylesheet or
  image, and no file under the corpus changes

#### Scenario: Nothing to show says so
- **WHEN** no run has recorded telemetry
- **THEN** the page renders and says there is nothing in flight

### Requirement: Every gauge names the state behind it
The page SHALL carry only signals the state can back: the run's phase,
in-flight task, blocked line and next command as `routine-health`
derives them; gate and TDD latency from telemetry's duration field;
event traffic per script; errors as failing gate and lint records,
defect returns, and the revise budget against its ceiling; saturation
as blocked seconds and in-flight versus done counts; and the caffeine
topics ranked by sidecar failure rate. A signal without a state source
SHALL NOT be rendered.

#### Scenario: The live run is the headline
- **WHEN** a ticket is mid-develop with a task in flight
- **THEN** the page names that task, its phase, and the command that
  resumes the run

#### Scenario: Failures surface as failures
- **WHEN** telemetry records failing gate runs
- **THEN** the page shows them in its errors panel with their counts

#### Scenario: The caffeine queue is ranked, not listed
- **WHEN** sidecar runs recorded both passes and failures
- **THEN** the topics appear ordered by failure rate
