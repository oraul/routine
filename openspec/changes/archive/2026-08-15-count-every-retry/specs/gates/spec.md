# gates Specification (delta)

## MODIFIED Requirements

### Requirement: Developer baseline runs the task's manifest sidecars
The developer gate baseline SHALL require a ticket context
(`ROUTINE_TICKET_DIR`) and an `in_progress` index row, failing and naming
the missing condition otherwise. It SHALL read the current task's manifest
(the `## Caffeine` list in its `task.md`) and resolve each named topic
from the routine root: when `caffeine/<topic>.sh` exists it SHALL run it
against `TARGET` and emit one `gate.developer.script` telemetry line
recording its exit code and duration; when only `caffeine/<topic>.md`
exists it SHALL emit one `gate.developer.doc` line and pass the topic;
when neither exists it SHALL fail naming both paths. A failing sidecar
SHALL fail the baseline surfacing its output.
 The developer gate SHALL also spend a failure budget counted by one shared implementation in `lib/episode.sh`: consecutive failing `gate.developer` lines for the task since its last passing one, reset by a pass because a developer that fails, fixes, and later fails again has not ground the same wall. Past 3 consecutive failures the gate SHALL refuse and name the roads — `routine-defect` for a defective spec, `routine-block` for a blockage — rather than letting the loop grind, since a floor stated only in an agent's prose is not load-bearing.
#### Scenario: No ticket context
- **WHEN** `routine-gate developer` runs without `ROUTINE_TICKET_DIR`
- **THEN** it exits non-zero naming the missing context

#### Scenario: No task in progress fails closed
- **WHEN** the ticket's index has no `in_progress` row
- **THEN** the developer baseline exits non-zero naming the condition

#### Scenario: Manifest sidecar failure fails the gate
- **WHEN** the task manifest names `ruby/rails` and the target trips a
  rails rule
- **THEN** `routine-gate developer` exits non-zero surfacing the sidecar
  output, and a `gate.developer.script` line records the non-zero exit

#### Scenario: Doc-only topic passes
- **WHEN** the task manifest names a topic that has a `.md` but no `.sh`
- **THEN** the baseline emits one `gate.developer.doc` line and proceeds

#### Scenario: Unknown manifest topic
- **WHEN** the manifest names a topic with neither `caffeine/<topic>.sh`
  nor `caffeine/<topic>.md`
- **THEN** the baseline exits non-zero naming both missing paths


#### Scenario: A ground-down developer gate refuses and names the road
- **WHEN** a task records a fourth consecutive failing `gate.developer`
- **THEN** the gate refuses, naming `routine-defect` and `routine-block`

#### Scenario: A passing gate resets the failure budget
- **WHEN** a task fails twice, passes, then fails again
- **THEN** the count is 1, not 3
