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

### Requirement: Gate stages resolve from one root
`routine-gate` SHALL resolve selfcheck, hooks, spec-lint, and caffeine
sidecars from the same routine root, so `ROUTINE_ROOT` redirects the whole
gate or none of it.

#### Scenario: Fixture root redirects sidecars
- **WHEN** `ROUTINE_ROOT` points at a fixture tree carrying its own
  caffeine sidecar
- **THEN** the developer baseline runs the fixture's sidecar, not the
  installation's

### Requirement: Hook outcomes are evidence
Every hook stage SHALL emit one telemetry line: `gate.hook` with the hook
path and its exit code when the hook ran, `gate.hook.absent` when an
optional hook was missing — a gate that passed because its hook ran green
SHALL be distinguishable from one that passed because no hook existed.

#### Scenario: Absent optional hook recorded
- **WHEN** `routine-gate analyst` passes with no analyst hook present
- **THEN** the ticket's telemetry gains one `gate.hook.absent` line
