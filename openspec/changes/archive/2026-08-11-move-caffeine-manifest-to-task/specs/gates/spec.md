## RENAMED Requirements

- FROM: `### Requirement: Developer baseline runs the briefing's manifest sidecars`
- TO: `### Requirement: Developer baseline runs the task's manifest sidecars`

## MODIFIED Requirements

### Requirement: Developer baseline runs the task's manifest sidecars
The developer gate baseline SHALL, when a ticket context exists, read the
current in-progress **task's** manifest (the `## Caffeine` list in its
`task.md`), run each named sidecar (`caffeine/<topic>.sh`) against
`TARGET`, and emit one `gate.developer.script` telemetry line per sidecar
run recording its exit code and duration. A manifest entry with no sidecar
file SHALL fail the baseline naming it; a failing sidecar SHALL fail the
baseline surfacing its output. Without a ticket context the baseline SHALL
log one line and pass.

#### Scenario: Manifest sidecar failure fails the gate
- **WHEN** the task manifest names `ruby/rails` and the target trips a
  rails rule
- **THEN** `routine-gate developer` exits non-zero surfacing the sidecar
  output, and a `gate.developer.script` line records the non-zero exit

#### Scenario: Unknown manifest topic
- **WHEN** the task manifest names a topic with no `caffeine/<topic>.sh`
- **THEN** the baseline exits non-zero naming the missing sidecar

#### Scenario: No ticket context
- **WHEN** `routine-gate developer` runs without `ROUTINE_TICKET_DIR`
- **THEN** the baseline logs one line and the gate proceeds to the hook
