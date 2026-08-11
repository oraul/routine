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
The preflight baseline SHALL require `routine-selfcheck` green before
anything else, then SHALL require the target project's git worktree to be
clean and checked out on a branch, and SHALL fail with the reason otherwise.

#### Scenario: Red harness blocks preflight
- **WHEN** `routine-selfcheck` exits non-zero
- **THEN** `routine-gate preflight` exits non-zero without checking the target

#### Scenario: Dirty target worktree
- **WHEN** selfcheck is green but the target worktree has uncommitted changes
- **THEN** `routine-gate preflight` exits non-zero naming the dirty state

#### Scenario: Detached HEAD in target
- **WHEN** selfcheck is green and the worktree is clean but HEAD is detached
- **THEN** `routine-gate preflight` exits non-zero asking for a branch

### Requirement: Analyst baseline lints the ticket and checks coherence
The analyst gate baseline SHALL resolve the ticket from
`ROUTINE_TICKET_DIR` (failing with a message when unset), SHALL run
`routine-spec-lint` over it, and SHALL verify the index is coherent with the
directory tree: every index row's task directory exists and every task
directory has an index row.

#### Scenario: No ticket context
- **WHEN** `routine-gate analyst` runs without `ROUTINE_TICKET_DIR`
- **THEN** it exits non-zero saying a ticket context is required

#### Scenario: Grammar failure fails the gate
- **WHEN** the ticket fails `routine-spec-lint`
- **THEN** `routine-gate analyst` exits non-zero surfacing the lint output

#### Scenario: Index row without a directory
- **WHEN** the index lists a task whose directory does not exist
- **THEN** the analyst baseline exits non-zero naming the row
