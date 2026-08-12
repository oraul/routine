## MODIFIED Requirements

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
tasks) unless every index row is `done`, emitting one `ticket.conclude`
line with its non-zero exit before refusing; on success it SHALL write
`report.md` summarizing the run from the index, emit one `ticket.conclude`
telemetry line, and move the ticket directory to `tickets/archive/<id>/`.

#### Scenario: Refuses with work remaining
- **WHEN** any index row is not `done`
- **THEN** `routine-conclude` exits non-zero naming the unfinished tasks,
  moves nothing, and the ticket's `telemetry.jsonl` gains one
  `ticket.conclude` line with a non-zero `exit`

#### Scenario: Concludes a finished ticket
- **WHEN** every index row is `done`
- **THEN** `report.md` exists in the archived ticket at
  `tickets/archive/<id>/`, the active directory is gone, and the archived
  `telemetry.jsonl` ends with a `ticket.conclude` line

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
