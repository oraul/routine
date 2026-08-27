## Purpose

The historical reader: every ticket the corpus holds, in the order it ran,
with what it cost and how it ended — so a reader judges whether the loop is
improving instead of reading an all-time total that looks identical on day
one and day fifteen.

## ADDED Requirements

### Requirement: The run corpus has a chronological reader
`bin/routine-timeline [runs-dir]` (default: the routine root's `runs/`)
SHALL read exactly the corpus the retro reads — active
(`<runs-dir>/<app>/tickets/<id>/telemetry.jsonl`) and archived
(`<runs-dir>/<app>/tickets/archive/<id>/telemetry.jsonl`) — and no other
file, so its counts and the retro's are drawn from the same lines and can
never disagree by reading different evidence. App-level harness telemetry
at `<runs-dir>/<app>/telemetry.jsonl` belongs to no ticket and SHALL be
excluded, as it already is from the retro. It SHALL print one row per
ticket ordered by the ticket's first recorded event,
oldest first, across every app. Ties SHALL break on app then ticket id, so
two runs recorded in the same second print in a stable order and a second
invocation over an unchanged corpus prints byte-identical output. Each row
SHALL name the ticket as `<app>/<ticket>`, since ticket ids collide across
apps and a history that merges two apps' `0001` is a history of neither. It
SHALL write no file — the audit judges a run, the health reads a living one,
and this one only reports what already happened.

#### Scenario: The corpus prints in time order
- **WHEN** two apps hold tickets whose first events are interleaved in time
- **THEN** the rows print oldest first, interleaved by that time, each named
  `<app>/<ticket>`

#### Scenario: The reader writes nothing
- **WHEN** `routine-timeline` runs twice over an unchanged corpus
- **THEN** no file under the runs directory changes and both runs print
  identical output

#### Scenario: Colliding ticket ids stay separate rows
- **WHEN** two apps each hold a ticket `0001`
- **THEN** the report prints two rows, each carrying its own app

### Requirement: Each row's outcome and cost are derived from script-owned state
Every row SHALL carry, derived from telemetry line order and `index.tsv`
alone: the first event's timestamp; the outcome — `concluded` on a passing
`ticket.conclude`, `aborted` on a passing `ticket.abort`, and `live` when
neither is recorded, first match winning in that order; the count of `done`
index rows over total rows; the specify episodes spent, as one plus the
ticket's `spec.defective` count; the failure count; and the elapsed seconds
from the first recorded event to the last. Failures SHALL be classified per
event with the retro's exact semantics — a non-zero `tdd.red` is the expected
outcome and never a failure, `ticket.next` exits 3 and 4 are protocol
outcomes, every other event counts a non-zero exit as a failure — through the
one shared implementation the retro capability requires, because a row whose
failure count disagrees with the retro's total for the same corpus is worse
than no row at all.

#### Scenario: A concluded run reports its outcome and cost
- **WHEN** a ticket records `ticket.new`, four `done` index rows of four, and
  a passing `ticket.conclude`
- **THEN** its row reads `concluded` with `4/4` tasks and the elapsed seconds
  between its first and last recorded events

#### Scenario: An aborted run is named, not omitted
- **WHEN** a ticket records a passing `ticket.abort` and no `ticket.conclude`
- **THEN** its row reads `aborted` and still carries its tasks and elapsed

#### Scenario: A run still in flight is named live
- **WHEN** a ticket records neither a passing `ticket.conclude` nor a passing
  `ticket.abort`
- **THEN** its row reads `live`

#### Scenario: A re-specified run shows the episodes it spent
- **WHEN** a ticket records two `spec.defective` lines
- **THEN** its row reports three episodes

#### Scenario: The failure count agrees with the retro
- **WHEN** a corpus records failing `tdd.red` lines, a `ticket.next` exit 3,
  and one failing `gate.developer`
- **THEN** the row counts exactly one failure, the same line the retro counts

### Requirement: Missing evidence is a refusal, not an empty history
`bin/routine-timeline` SHALL exit 0 when it printed a report, 2 on a usage
error or a missing runs directory, and SHALL never print an empty report in
place of a missing corpus — an absent directory and a directory holding no
tickets are different facts, and a reader that renders both as "no history"
teaches the wrong one. A runs directory that exists and holds no
`telemetry.jsonl` SHALL print a line saying so and exit 0.

#### Scenario: A missing runs directory is refused
- **WHEN** the named runs directory does not exist
- **THEN** the script exits 2 naming the missing path and prints no report

#### Scenario: An empty corpus is a report, not a refusal
- **WHEN** the runs directory exists and holds no `telemetry.jsonl`
- **THEN** the script says so and exits 0

#### Scenario: A printed report exits zero
- **WHEN** the corpus holds at least one ticket
- **THEN** the script prints its rows and exits 0
