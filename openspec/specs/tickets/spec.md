# tickets Specification

## Purpose

Script-owned ticket state: where an app's run lives, how tickets are laid
out, and the strictly ordered task line the developer consumes one task at a
time.

## Requirements

### Requirement: App state is scaffolded by script
`bin/routine-scaffold` SHALL derive the app key from the target repository's
directory name, SHALL create `runs/<app>/hooks` and `runs/<app>/tickets`
under the routine root when absent, SHALL be idempotent, and SHALL exit
non-zero with the mandatory-hook instruction while
`runs/<app>/hooks/developer.sh` is missing.

#### Scenario: First scaffold halts on the missing developer hook
- **WHEN** `routine-scaffold` runs for an app with no prior state
- **THEN** the hooks and tickets directories exist afterwards and the script
  exits non-zero naming `runs/<app>/hooks/developer.sh`

#### Scenario: Scaffold is idempotent and passes once the hook exists
- **WHEN** `routine-scaffold` runs again after `developer.sh` was created
- **THEN** it exits 0 and the existing state is unchanged

### Requirement: Ticket ids are allocated sequentially by script
`bin/routine-ticket-new` SHALL allocate the next sequential zero-padded
4-digit ticket id under `runs/<app>/tickets/`, SHALL create the ticket
directory with an empty `index.tsv`, and SHALL print the ticket path.

#### Scenario: First ticket
- **WHEN** no tickets exist and `routine-ticket-new` runs
- **THEN** `tickets/0001/` exists with an empty `index.tsv` and its path is
  printed

#### Scenario: Sequential allocation skips archived ids
- **WHEN** tickets `0001` and `archive/0002` exist
- **THEN** `routine-ticket-new` creates `0003`

### Requirement: Index rows derive from the briefings tree
`index.tsv` SHALL be tab-separated with columns
`task_id briefing task status updated_at`, one task per line in strict file
order. `bin/routine-next` SHALL append rows (`pending`, current UTC
timestamp) for tasks present in `briefings/*/tasks/*` but absent from the
index, in file order, and SHALL never reorder or rewrite existing rows'
identity columns. The LLM never writes the index.

#### Scenario: Missing tasks appended in file order
- **WHEN** the tree has tasks `01-a/tasks/01-x`, `01-a/tasks/02-y` and the
  index is empty
- **THEN** after `routine-next` the index lists `01-01` then `01-02` with
  status columns reflecting the run

### Requirement: The task line is strictly ordered and blockable
`bin/routine-next` SHALL return the path of the first task whose status is
not `done`, marking it `in_progress`, only when no earlier task is
`blocked`; a blocked task SHALL block the line (distinct non-zero exit), and
a fully `done` index SHALL exit with its own distinct code and message.

#### Scenario: Next runnable task
- **WHEN** the first index row is `done` and the second is `pending`
- **THEN** `routine-next` prints the second task's path and marks it
  `in_progress`

#### Scenario: Blocked task blocks the line
- **WHEN** an earlier task is `blocked` and later tasks are `pending`
- **THEN** `routine-next` exits non-zero naming the blocked task and marks
  nothing

### Requirement: Status transitions are scripted and evidence-gated
`bin/routine-done` SHALL mark the current `in_progress` task `done`.
`bin/routine-block` SHALL mark it `blocked` only when the task directory
contains `block.md`, and `bin/routine-unblock` SHALL return a `blocked` task
to `pending` only when `unblock.md` exists; each refusal SHALL name the
missing file. Every transition SHALL update the row's `updated_at`.

#### Scenario: Block requires block.md
- **WHEN** `routine-block` runs for a task without `block.md`
- **THEN** it exits non-zero naming `block.md` and the status is unchanged

#### Scenario: Unblock releases the line
- **WHEN** `unblock.md` exists and `routine-unblock` runs for a blocked task
- **THEN** the task becomes `pending` and `routine-next` can return it again

### Requirement: Lifecycle events are recorded
Each lifecycle script SHALL emit exactly one telemetry event
(`ticket.next`, `ticket.done`, `ticket.block`, `ticket.unblock`) into the
ticket's `telemetry.jsonl` via `lib/telemetry.sh`.

#### Scenario: next emits ticket.next
- **WHEN** `routine-next` returns a task
- **THEN** the ticket's `telemetry.jsonl` gains one `ticket.next` line
