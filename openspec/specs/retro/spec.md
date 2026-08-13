# retro Specification

## Purpose

The feedback loop: turns raw telemetry lines from every app and ticket into
a plain-text report, computed on demand and never stored.

## Requirements

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
It SHALL write no files.

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


### Requirement: Retro reports time in blocked state
For each `ticket.block` line whose ticket and task match a later
`ticket.unblock` line **within the same app** (the app is derived from
the telemetry file's path), the retro SHALL report the elapsed seconds
between their timestamps, per app and task. Ticket ids SHALL never pair
across apps.

#### Scenario: One block/unblock pair
- **WHEN** a task was blocked at T and unblocked at T+3600s
- **THEN** the report shows 3600 seconds in blocked for that task

#### Scenario: Colliding ticket ids stay separate
- **WHEN** two apps both hold a ticket `0001` and only one of them has a
  block/unblock pair for task `01-02`
- **THEN** the report shows blocked seconds for that app's task only,
  never a cross-app pairing

### Requirement: Retro reports the re-specify cost
The report SHALL include a re-specify cost section keyed by app and
ticket (never pairing across apps): specify episodes as one plus the
ticket's `spec.defective` count, total and worst-episode failed
`spec.lint` runs counted with the analyst gate's exact semantics (the
per-episode counter resets on `spec.defective`), and the seconds from
each `spec.defective` to the next passing `spec.lint` — a defect with
no later passing lint SHALL print as unrecovered. Tickets with no
episodes beyond the first and no failed lints SHALL NOT appear. The
section is computed from existing telemetry on demand; the retro
writes nothing.

#### Scenario: A defect return's cost is visible
- **WHEN** a ticket records a failed lint, a `spec.defective`, and a
  later passing `spec.lint`
- **THEN** the section shows two episodes, the failed-lint counts, and
  the defect-to-recovery seconds for that app and ticket

#### Scenario: An unrecovered defect is named
- **WHEN** a ticket records `spec.defective` with no later passing
  `spec.lint`
- **THEN** the section prints that ticket as unrecovered

#### Scenario: Cost never crosses apps
- **WHEN** two apps hold tickets with the same id
- **THEN** each app's cost line reflects only its own telemetry
