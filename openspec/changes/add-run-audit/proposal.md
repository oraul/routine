## Why

C3 made every loop script leave attributed evidence, but nothing reads
it back. The protocol — ticket born by script, analyst gate passed, each
task started, red shown before green, developer gate run per manifest
topic, task done, blocks balanced — is enforced stage by stage, yet a
run that skipped a stage still concludes cleanly. The council asked for
a harness that checks whether all expected scripts really ran.

## What Changes

- **`bin/routine-audit <ticket-dir>`**: replays the ticket's telemetry
  against the protocol and reports every violation in one run: first
  event is `ticket.new`; a passing `gate.analyst` is on record; every
  `done` task has a passing `ticket.next`, at least one `tdd.green`
  preceded by a same-scenario failing `tdd.red`, a passing
  `gate.developer`, evidence per manifest topic
  (`gate.developer.script` ran green or `gate.developer.doc`), and a
  passing `ticket.done`; block/unblock events balance per task.
- **`routine-conclude` refuses unless the audit passes**, emitting its
  refusal like any other.

## Capabilities

### New Capabilities

- `audit`: the run audit replays evidence against the protocol.

### Modified Capabilities

- `tickets`: conclude is gated on the audit.

## Impact

- Added: `bin/routine-audit`, `test/audit.bats`.
- Modified: `bin/routine-conclude`, `test/conclude.bats` (fixtures gain
  honest protocol telemetry).
