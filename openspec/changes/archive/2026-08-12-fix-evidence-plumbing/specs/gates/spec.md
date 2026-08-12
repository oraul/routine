## MODIFIED Requirements

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
