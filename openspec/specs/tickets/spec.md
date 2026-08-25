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
ungated artifacts is meaningless), and SHALL emit one `ticket.approve`
telemetry line on every recorded proceed. When the ticket's
`grounding.md` carries non-floor `## Questions` bullets, the proceed
SHALL be earned per question: the note's lines of the form
`<n>: <answer>` are matched by position to the section's non-floor
bullets, and the gate SHALL refuse — recording nothing — while any
index lacks an answer, naming each open question, or while an answer
names an index no question holds; lines in no `<n>:` form remain free
remarks and bind to nothing. A single free-text note SHALL NOT
dissolve the section, because one word could previously pass every
question at once and only an exit code makes a question answered —
while whether an answer is good, whether a question is real, and
whether the human read before typing remain judgments no script here
makes. A `## Questions` section at its `- none — <why>` floor SHALL
NOT block a proceed, so asking stays a deliberate act rather than a
tax on every ticket. Every recorded proceed SHALL append an
`approve.md` entry under a timestamped heading — the
question-and-answer pairs verbatim as `Q<n>`/`A<n>` lines, any free
remarks, and an `Approved-at: <hash8>` fingerprint of the artifacts
the operator blessed (`requirement.md`, `grounding.md`, and every
`briefings/*/briefing.md`, hashed in sorted path order through the
same cksum derivation `routine-tdd` records) — a bare proceed
included, so a later reader can always tell what was approved and
whether it is still what concluded. Repeated approvals (after a
defect return) SHALL keep the full history, append-only. The
fingerprint SHALL have one implementation, shared with the audit.

#### Scenario: Approval leaves a line
- **WHEN** `routine-approve <ticket> "ship without the CSV export"`
  runs after a passing analyst gate
- **THEN** the telemetry gains one `ticket.approve` line and
  `approve.md` carries the remark and an `Approved-at:` fingerprint
  under a timestamp

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

#### Scenario: A free-text note no longer answers open questions
- **WHEN** two non-floor questions are open and the note carries prose
  with no `<n>:` lines
- **THEN** the gate exits non-zero naming both open questions, and no
  `ticket.approve` line is recorded

#### Scenario: Each answer pairs with its question in the record
- **WHEN** the note answers `1:` and `2:` for two open questions
- **THEN** `approve.md` gains one entry holding each question and its
  answer as `Q<n>`/`A<n>` lines

#### Scenario: An answer naming no question is refused
- **WHEN** one question is open and the note carries `2: <answer>`
- **THEN** the gate exits non-zero saying index 2 names no open
  question

#### Scenario: A bare proceed still writes its entry
- **WHEN** `routine-approve` records a proceed with no questions and no
  note
- **THEN** `approve.md` gains a timestamped entry carrying the
  `Approved-at:` fingerprint

### Requirement: A replay moves only the rails
`bin/routine-replay <archived-ticket-dir>` SHALL create a fresh ticket
whose `requirement.md` is byte-identical to the archived one, against a
detached target worktree checked out at the archived grounding's
`Grounded-at` anchor, because the claim "the rails improved" is
uncontrolled while the requirement's wording and the target's state
move with them — the replay holds both still so only the rails differ.
The worktree SHALL live under `runs/<app>/replays/<archived-id>-<sha8>/<app>`,
so the app key every gate derives from the target resolves to the same
state tree as the original run. The new ticket SHALL record its
provenance in `replay.md` — the archived ticket replayed, the anchor,
and the worktree path — and SHALL carry one `ticket.replay` telemetry
line after its `ticket.new`. The script SHALL print the archived run's
final event beside the new paths, so the operator knows what outcome
the replay is being compared against. It SHALL refuse, creating
nothing lasting: an archived ticket missing its `requirement.md` or a
well-formed anchor (runs that predate the anchor rule cannot be
replayed honestly and the refusal says so); an anchor the target
cannot resolve; a replay worktree that already exists; and a refused
ticket allocation — in that case the worktree it created is removed
before exiting, because a replay that failed to allocate must not
leave state a later run trips over. Allocation itself SHALL go through
`routine-ticket-new`, so WIP stays 1 and ids are never reused. The
comparison of outcomes SHALL remain the operator's judgment recorded
in retros and release records — the script holds variables still and
decides nothing about what the difference means.

#### Scenario: The question is held still
- **WHEN** `routine-replay` runs against an archived ticket with a
  reachable anchor
- **THEN** the new ticket's `requirement.md` is byte-identical to the
  archived one, the worktree's HEAD equals the anchor, `replay.md`
  names the archived ticket, the anchor, and the worktree, and the
  ticket's telemetry carries `ticket.replay`

#### Scenario: A run without an anchor cannot be replayed
- **WHEN** the archived grounding carries no well-formed
  `Grounded-at:` line
- **THEN** the script exits non-zero naming the missing anchor, and no
  worktree or ticket is created

#### Scenario: An unreachable anchor is refused
- **WHEN** the anchor is well-formed but the target cannot resolve it
- **THEN** the script exits non-zero naming the anchor

#### Scenario: A refused allocation leaves nothing behind
- **WHEN** a ticket is already live and `routine-ticket-new` refuses
- **THEN** the replay propagates the refusal and the worktree it
  created is removed

#### Scenario: The archived outcome is shown for comparison
- **WHEN** a replay ticket is created
- **THEN** the output names the archived run's final telemetry event
