# retro Specification

## Purpose

The feedback loop: turns raw telemetry lines from every app and ticket into
a plain-text report, computed on demand and never stored.

## Requirements

### Requirement: Retro aggregates all telemetry on demand
`bin/routine-retro` SHALL read every ticket `telemetry.jsonl` under the
routine root — active (`runs/<app>/tickets/<id>/`) and archived
(`runs/<app>/tickets/archive/<id>/`) — and SHALL print a plain-text report containing: runs and
failure counts per event, duration min/p50/p95/max per event (ms), and
failure counts per script. It SHALL write no files.

#### Scenario: Aggregation across tickets and apps
- **WHEN** two tickets in different apps hold telemetry lines
- **THEN** one retro run reports totals across both

#### Scenario: Nothing stored
- **WHEN** `routine-retro` runs
- **THEN** the report goes to stdout and no file under `runs/` changes

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
