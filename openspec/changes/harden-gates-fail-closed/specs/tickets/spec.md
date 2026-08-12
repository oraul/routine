## MODIFIED Requirements

### Requirement: Status transitions are scripted and evidence-gated
`bin/routine-done` SHALL mark the current `in_progress` task `done`.
`bin/routine-block` SHALL mark it `blocked` only when the task directory
contains `block.md`. `bin/routine-unblock [task-id]` SHALL return a
`blocked` task to `pending` only when `unblock.md` exists: given a task-id
it SHALL release exactly that task or refuse naming its actual status;
without one it SHALL release the first blocked task. Each refusal SHALL
name the missing file or condition. Every transition SHALL update the
row's `updated_at`. `bin/routine-conclude` SHALL print the archived
ticket's path on success.

#### Scenario: Block requires block.md
- **WHEN** `routine-block` runs for a task without `block.md`
- **THEN** it exits non-zero naming `block.md` and the status is unchanged

#### Scenario: Unblock releases the line
- **WHEN** `unblock.md` exists and `routine-unblock` runs for a blocked task
- **THEN** the task becomes `pending` and `routine-next` can return it again

#### Scenario: Unblock addresses a named task
- **WHEN** two tasks are blocked and `routine-unblock 01-02` runs with
  `unblock.md` present for `01-02`
- **THEN** exactly `01-02` returns to `pending`

#### Scenario: Conclude names the archive
- **WHEN** a finished ticket concludes
- **THEN** the output contains the archived ticket's path
