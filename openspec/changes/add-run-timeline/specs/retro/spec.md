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
It SHALL write no files. The derivations it defines — the timestamp conversion and the caffeine failure ranking — SHALL have exactly one implementation: a second script that recomputes either of them is a defect, because two implementations of one number can disagree with nothing to catch it. A failure SHALL be classified per event, never by a blanket non-zero test: a non-zero `tdd.red` is the expected outcome and a zero one is the anomaly the report SHALL name; `ticket.next` exits 3 and 4 are protocol outcomes, not failures; every other event treats a non-zero exit as a failure. Script failures SHALL count only records whose script field is a path, so the section names scripts rather than scenario labels. The caffeine deepening queue SHALL rank by failure count with the rate and run count shown beside it, so a single unlucky run cannot head the queue. The per-event failure classification this requirement defines is a third such derivation, bound by this same rule. Each of these implementations SHALL live under `lib/`, sourced by every consumer, rather than inside whichever reader needed it first: a derivation that lives in one script's body can only be shared by copying it, which is the defect this rule already names, and a second reader is now a matter of record rather than of hypothesis.

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

#### Scenario: A correct red is not a failure
- **WHEN** a ticket records failing `tdd.red` lines and no other failure
- **THEN** the report shows no failures for `tdd.red`

#### Scenario: A blocked or exhausted line is not a failure
- **WHEN** `ticket.next` records exits 3 and 4
- **THEN** neither counts as a failure

#### Scenario: The queue ranks by accumulated failures
- **WHEN** one topic failed once in one run and another failed many
  times across many runs
- **THEN** the topic with more failures ranks first

#### Scenario: A shared derivation has one home under lib
- **WHEN** the suite checks where the timestamp conversion and the failure
  classification are defined
- **THEN** each is found exactly once, under `lib/`, and no `bin/` script
  carries its own copy

#### Scenario: The extraction leaves the report unchanged
- **WHEN** the retro runs over a corpus before and after a shared
  derivation moves under `lib/`
- **THEN** its output is byte-identical
