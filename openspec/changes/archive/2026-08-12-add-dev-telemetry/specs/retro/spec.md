## MODIFIED Requirements

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
