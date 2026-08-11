## MODIFIED Requirements

### Requirement: Developer baseline runs the task's manifest sidecars
The developer gate baseline SHALL, when a ticket context exists, read the
current in-progress **task's** manifest (the `## Caffeine` list in its
`task.md`) and resolve each named topic: when `caffeine/<topic>.sh` exists
it SHALL run it against `TARGET` and emit one `gate.developer.script`
telemetry line recording its exit code and duration; when only
`caffeine/<topic>.md` exists it SHALL log one line and pass (a doc-only
topic); when neither file exists it SHALL fail the baseline naming both
paths. A failing sidecar SHALL fail the baseline surfacing its output.
Without a ticket context the baseline SHALL log one line and pass.

#### Scenario: Manifest sidecar failure fails the gate
- **WHEN** the task manifest names `ruby/rails` and the target trips a
  rails rule
- **THEN** `routine-gate developer` exits non-zero surfacing the sidecar
  output, and a `gate.developer.script` line records the non-zero exit

#### Scenario: Doc-only topic passes
- **WHEN** the task manifest names a topic that has a `.md` but no `.sh`
- **THEN** the baseline logs the doc-only resolution and proceeds

#### Scenario: Unknown manifest topic
- **WHEN** the manifest names a topic with neither `caffeine/<topic>.sh`
  nor `caffeine/<topic>.md`
- **THEN** the baseline exits non-zero naming both missing paths

#### Scenario: No ticket context
- **WHEN** `routine-gate developer` runs without `ROUTINE_TICKET_DIR`
- **THEN** the baseline logs one line and the gate proceeds to the hook
