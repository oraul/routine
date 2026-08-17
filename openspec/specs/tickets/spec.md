# tickets Specification

## Purpose

Script-owned ticket state: where an app's run lives, how tickets are laid
out, and the strictly ordered task line the developer consumes one task at a
time.

## Requirements

### Requirement: App state is scaffolded by script
`bin/routine-scaffold` SHALL derive the app key from the target repository's
directory name, SHALL create `runs/<app>/hooks` and `runs/<app>/tickets`
under the routine root when absent, SHALL be idempotent, SHALL exit
non-zero with the mandatory-hook instruction while
`runs/<app>/hooks/developer.sh` is missing, and SHALL emit one
`app.scaffold` line with its exit code to `runs/<app>/telemetry.jsonl`.

#### Scenario: First scaffold halts on the missing developer hook
- **WHEN** `routine-scaffold` runs for an app with no prior state
- **THEN** the hooks and tickets directories exist afterwards, the script
  exits non-zero naming `runs/<app>/hooks/developer.sh`, and
  `runs/<app>/telemetry.jsonl` gains one `app.scaffold` line with a
  non-zero `exit`

#### Scenario: Scaffold is idempotent and passes once the hook exists
- **WHEN** `routine-scaffold` runs again after `developer.sh` was created
- **THEN** it exits 0, the existing state is unchanged apart from one new
  `app.scaffold` telemetry line recording the pass


### Requirement: Ticket ids are allocated sequentially by script
`bin/routine-ticket-new` SHALL allocate the next sequential zero-padded
4-digit ticket id under `runs/<app>/tickets/`, SHALL create the ticket
directory with an empty `index.tsv`, SHALL emit one `ticket.new` telemetry
line into the created ticket's `telemetry.jsonl`, and SHALL print the
ticket path. It SHALL refuse — a distinct exit naming the incumbent ticket and both roads out, adopting it or ending it — while any non-archived ticket directory exists for the app: WIP is 1, and a run that died mid-flight must be adopted or ended, never orphaned by a second allocation. Archived tickets SHALL NOT block allocation.

#### Scenario: First ticket
- **WHEN** no tickets exist and `routine-ticket-new` runs
- **THEN** `tickets/0001/` exists with an empty `index.tsv`, its
  `telemetry.jsonl` holds one `ticket.new` line, and its path is printed

#### Scenario: Sequential allocation skips archived ids
- **WHEN** tickets `0001` and `archive/0002` exist
- **THEN** `routine-ticket-new` creates `0003`

#### Scenario: A live ticket blocks a second allocation
- **WHEN** `tickets/0001` exists and `routine-ticket-new` runs
- **THEN** it exits non-zero naming `0001`, creates nothing, and names
  adopting or ending it as the roads out

#### Scenario: Archived tickets never block
- **WHEN** only `archive/0001` exists
- **THEN** `routine-ticket-new` creates `0002`

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


### Requirement: Lifecycle events are recorded
Each lifecycle script SHALL emit exactly one telemetry event
(`ticket.next`, `ticket.done`, `ticket.block`, `ticket.unblock`) into the
ticket's `telemetry.jsonl` via `lib/telemetry.sh` on every invocation
against a valid ticket — refusals and protocol outcomes included, with
the script's real exit code in the `exit` field. Only usage errors
(no valid ticket directory) SHALL exit without a line.

#### Scenario: next emits ticket.next
- **WHEN** `routine-next` returns a task
- **THEN** the ticket's `telemetry.jsonl` gains one `ticket.next` line

#### Scenario: Refusal leaves evidence
- **WHEN** `routine-done` refuses because no task is `in_progress`
- **THEN** the ticket's `telemetry.jsonl` gains one `ticket.done` line
  with a non-zero `exit`

#### Scenario: Blocked line outcome is recorded
- **WHEN** `routine-next` exits 3 on a blocked line or 4 with all tasks
  done
- **THEN** the ticket's `telemetry.jsonl` gains one `ticket.next` line
  carrying that exit code


### Requirement: Conclude is evidence-checked and archives the ticket
`bin/routine-conclude <ticket-dir>` SHALL refuse (naming the offending
tasks) unless every index row is `done`, and SHALL refuse unless
`bin/routine-audit` passes over the ticket — surfacing the audit's
violations. Each refusal SHALL emit one `ticket.conclude` line with its
non-zero exit. On success it SHALL write `report.md` summarizing the run
from the index, emit one `ticket.conclude` telemetry line, and move the
ticket directory to `tickets/archive/<id>/`, printing the archived path.

#### Scenario: Refuses with work remaining
- **WHEN** any index row is not `done`
- **THEN** `routine-conclude` exits non-zero naming the unfinished tasks,
  moves nothing, and the ticket's `telemetry.jsonl` gains one
  `ticket.conclude` line with a non-zero `exit`

#### Scenario: Refuses a run that fails the audit
- **WHEN** every index row is `done` but the audit finds a violation
- **THEN** `routine-conclude` exits non-zero surfacing the violation and
  moves nothing

#### Scenario: Concludes a finished ticket
- **WHEN** every index row is `done` and the audit passes
- **THEN** `report.md` exists in the archived ticket at
  `tickets/archive/<id>/`, the active directory is gone, and the archived
  `telemetry.jsonl` ends with a `ticket.conclude` line


### Requirement: The defect return is a lifecycle transition
`bin/routine-defect <ticket-dir> <reason>` SHALL return the `in_progress`
task to `pending` with the stated reason **appended** to the task's
`defect.md` under a timestamped heading — repeated returns keep the full
history, newest last — refusing without a reason or without an
`in_progress` task, and SHALL emit one `spec.defective` telemetry event.

#### Scenario: Defective task returned to the line
- **WHEN** `routine-defect` runs with an in_progress task and a reason
- **THEN** the task is `pending`, `defect.md` carries the reason, and one
  `spec.defective` event is recorded

#### Scenario: History survives a second return
- **WHEN** the same task takes two defect returns with different reasons
- **THEN** `defect.md` holds both, each under its own timestamp

### Requirement: Abort is a scripted lifecycle transition
`bin/routine-abort <ticket-dir> <reason>` SHALL refuse without a
non-empty reason, SHALL write the reason to the ticket-level `abort.md`,
SHALL emit one `ticket.abort` telemetry line before moving anything,
SHALL move the ticket directory to `tickets/archive/<id>/` with every
artifact intact (no `report.md` — that file asserts completion), and
SHALL print the archived path. An aborted ticket SHALL never linger in
the active directory.

#### Scenario: Abort archives with evidence
- **WHEN** `routine-abort <ticket> "revise limit exhausted on grammar"`
  runs
- **THEN** the ticket lands in `tickets/archive/<id>/` containing
  `abort.md` with the reason, its telemetry ends with a `ticket.abort`
  line, and the output names the archived path

#### Scenario: Abort without a reason is refused
- **WHEN** `routine-abort` runs with no reason
- **THEN** it exits non-zero naming the missing reason and moves nothing

### Requirement: Approval is recorded evidence
`bin/routine-approve <ticket-dir> [note]` SHALL refuse unless the
ticket's telemetry holds a passing `gate.analyst` line (approval of
ungated artifacts is meaningless), SHALL append any note to the
ticket-level `approve.md` under a timestamped heading, and SHALL emit
one `ticket.approve` telemetry line. Repeated approvals (after a defect
return) SHALL keep the full note history. It SHALL additionally refuse a proceed while the ticket's `grounding.md` carries a non-floor `## Questions` section and no note is given, because a question only the operator can answer is cheap to overturn before implementation and a caller-visible break after it — showing the questions makes them visible, and only an exit code makes them answered. A `## Questions` section at its `- none — <why>` floor SHALL NOT block a proceed, so asking is a deliberate act rather than a tax on every ticket. The gate SHALL decide presence and floor only: whether a question is real, whether the answer is good, and whether the human read it rather than typing a word to pass are judgments no script here makes.
#### Scenario: Approval leaves a line
- **WHEN** `routine-approve <ticket> "ship without the CSV export"`
  runs after a passing analyst gate
- **THEN** the telemetry gains one `ticket.approve` line and
  `approve.md` carries the note under a timestamp

#### Scenario: Ungated artifacts cannot be approved
- **WHEN** `routine-approve` runs with no passing `gate.analyst` on
  record
- **THEN** it exits non-zero naming the missing gate
#### Scenario: An unanswered operator question blocks the proceed
- **WHEN** `grounding.md` carries a non-floor `## Questions` section and
  `routine-approve` is called with no note
- **THEN** it exits non-zero naming the unanswered questions, and no
  `ticket.approve` line is recorded

#### Scenario: Nothing to ask never blocks
- **WHEN** `## Questions` is at its `- none — <why>` floor
- **THEN** `routine-approve` records the proceed exactly as it does today
