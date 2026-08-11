## Purpose

The feedback loop: turns raw telemetry lines from every app and ticket into
a plain-text report, computed on demand and never stored.

## ADDED Requirements

### Requirement: Retro aggregates all telemetry on demand
`bin/routine-retro` SHALL read every
`runs/*/tickets/telemetry.jsonl`-bearing ticket, active and archived, under
the routine root, and SHALL print a plain-text report containing: runs and
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
`ticket.unblock` line, the retro SHALL report the elapsed seconds between
their timestamps, per task.

#### Scenario: One block/unblock pair
- **WHEN** a task was blocked at T and unblocked at T+3600s
- **THEN** the report shows 3600 seconds in blocked for that task
