# retro Specification (delta)

## MODIFIED Requirements

### Requirement: Retro aggregates all telemetry on demand
`bin/routine-retro` SHALL read every ticket `telemetry.jsonl` under the
routine root — active (`runs/<app>/tickets/<id>/`) and archived
(`runs/<app>/tickets/archive/<id>/`) — and SHALL print a plain-text
report containing: runs and failure counts per event, duration
min/p50/p95/max per event (ms), failure counts per script, and a
`caffeine topics:` section listing every `caffeine/`-prefixed script's
runs, failures, and failure rate — doc-only topics included via their
`gate.developer.doc` lines — ranked by failure rate descending (the
deepening queue). Report sections SHALL print in a deterministic order.
It SHALL write no files. The derivations it defines — the timestamp conversion and the caffeine failure ranking — SHALL have exactly one implementation: a second script that recomputes either of them is a defect, because two implementations of one number can disagree with nothing to catch it.

#### Scenario: Aggregation across tickets and apps
- **WHEN** two tickets in different apps hold telemetry lines
- **THEN** one retro run reports totals across both

#### Scenario: Nothing stored
- **WHEN** `routine-retro` runs
- **THEN** the report goes to stdout and no file under `runs/` changes

#### Scenario: The deepening queue is computed
- **WHEN** one topic fails in half its runs and another never fails
- **THEN** the `caffeine topics:` section lists the failing topic first
  with its rate, and the doc-only topics appear with their run counts

#### Scenario: A forked derivation fails the suite
- **WHEN** a second script reimplements the timestamp conversion or the
  caffeine failure ranking
- **THEN** the suite fails naming that script
