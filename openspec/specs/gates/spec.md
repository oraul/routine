# gates Specification

## Purpose

Deterministic phase gating: every transition in the operational loop is
decided by `routine-gate`'s exit code, composed from selfcheck, the gate's
baseline, and the target app's hook.

## Requirements

### Requirement: Gate runner composes stages in fixed order
`bin/routine-gate <gate>` SHALL run, in order: `routine-selfcheck` (preflight
gate only), then routine's baseline for the named gate when one exists, then
the app hook at `runs/<app>/hooks/<gate>.sh` when present. It SHALL exit 0
only when every stage run passes, SHALL stop at the first failing stage, and
SHALL surface that stage's output.

#### Scenario: All stages pass
- **WHEN** every applicable stage exits 0
- **THEN** `routine-gate` exits 0

#### Scenario: Baseline failure blocks the hook
- **WHEN** the gate's baseline exits non-zero
- **THEN** `routine-gate` exits non-zero without running the app hook

#### Scenario: Unknown gate
- **WHEN** `routine-gate` is called with a gate name it does not know
- **THEN** it exits non-zero naming the valid gates

### Requirement: Seam contract distinguishes optional and mandatory hooks
A missing optional hook (`preflight.sh`, `analyst.sh`) SHALL log one line and
pass. The developer hook `runs/<app>/hooks/developer.sh` SHALL be mandatory:
when missing, `routine-gate developer` SHALL exit non-zero with a message
naming the exact file to create and a one-line example that delegates to the
app's own tooling.

#### Scenario: Missing optional hook passes
- **WHEN** `routine-gate preflight` runs and no preflight hook exists
- **THEN** the gate logs one line about the absent hook and the stage passes

#### Scenario: Missing developer hook aborts with instruction
- **WHEN** `routine-gate developer` runs and `hooks/developer.sh` is absent
- **THEN** the gate exits non-zero, names `runs/<app>/hooks/developer.sh`,
  and shows a one-line example delegating to the app's own CI entrypoint

### Requirement: Preflight baseline proves harness and target readiness
The preflight gate SHALL require a ticket context (`ROUTINE_TICKET_DIR`),
failing and naming the missing condition otherwise — the audit demands
preflight evidence, so an unrecordable preflight is a protocol error at
the moment it happens. The baseline SHALL require `routine-selfcheck`
green before anything else, then SHALL require the target project's git
worktree to be clean and checked out on a branch, and SHALL fail with
the reason otherwise.

#### Scenario: Red harness blocks preflight
- **WHEN** `routine-selfcheck` exits non-zero
- **THEN** `routine-gate preflight` exits non-zero without checking the target

#### Scenario: Dirty target worktree
- **WHEN** selfcheck is green but the target worktree has uncommitted changes
- **THEN** `routine-gate preflight` exits non-zero naming the dirty state

#### Scenario: Detached HEAD in target
- **WHEN** selfcheck is green and the worktree is clean but HEAD is detached
- **THEN** `routine-gate preflight` exits non-zero asking for a branch

#### Scenario: No ticket context fails closed
- **WHEN** `routine-gate preflight` runs without `ROUTINE_TICKET_DIR`
- **THEN** it exits non-zero naming the missing context before any
  target check


### Requirement: Analyst baseline lints the ticket and checks coherence
The analyst gate baseline SHALL resolve the ticket from
`ROUTINE_TICKET_DIR` (failing with a message when unset), SHALL fail
naming the exhausted revise limit when the ticket's telemetry records
more than 3 failed `spec.lint` runs **in the current specify episode** —
failures at or before the most recent `spec.defective` line do not
count, because re-specified work is new work — SHALL run
`routine-spec-lint` over it, SHALL then append any index rows missing
for existing task directories (the same append-only, file-ordered sync
`routine-next` performs), and SHALL verify the index is coherent with
the directory tree: every index row's task directory exists and every
task directory has an index row.

#### Scenario: No ticket context
- **WHEN** `routine-gate analyst` runs without `ROUTINE_TICKET_DIR`
- **THEN** it exits non-zero naming the missing variable

#### Scenario: Revise limit exhausted
- **WHEN** the ticket's telemetry holds 4 failed `spec.lint` events
  with no later `spec.defective` line
- **THEN** the analyst gate exits non-zero naming the revise limit

#### Scenario: Grammar failure fails the gate
- **WHEN** the ticket violates the spec grammar
- **THEN** the analyst gate exits non-zero surfacing the lint output

#### Scenario: Fresh ticket is coherent by construction
- **WHEN** a well-formed ticket has task directories but an empty index
- **THEN** the analyst baseline appends the rows as `pending` and passes

#### Scenario: Index row without a directory
- **WHEN** the index lists a task whose directory does not exist
- **THEN** the analyst baseline exits non-zero naming the row

#### Scenario: A defect return opens a fresh budget
- **WHEN** the telemetry holds 4 failed `spec.lint` events, then a
  `spec.defective` line, then 1 failed `spec.lint`
- **THEN** the analyst gate does not name the revise limit


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
