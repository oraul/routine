## Why

The gate rail exists but nothing yet owns state: there is no app scaffold, no
ticket, no index, and `ROUTINE_TICKET_DIR` has no script that sets it. This
change builds the ticket lifecycle so the operational loop has something to
run — with every state mutation owned by a script, never the LLM.

## What Changes

- Add `bin/routine-scaffold`: creates `runs/<app>/{hooks,tickets}` for the
  target app (key derived from the target repo's directory name), then halts
  with the mandatory `developer.sh` instruction when the hook is missing.
  Idempotent.
- Add `bin/routine-ticket-new`: allocates the next sequential 4-digit ticket
  id under `runs/<app>/tickets/`, creating the ticket directory and an empty
  script-owned `index.tsv`.
- Add `bin/routine-next`: refreshes the index from the briefings tree
  (appending missing tasks as `pending`, strict file order), then returns the
  first runnable task path and marks it `in_progress`. A blocked task blocks
  the line; all-done and blocked outcomes get distinct exit codes.
- Add `bin/routine-done`: marks the current task `done`.
- Add `bin/routine-block` / `bin/routine-unblock`: flip `blocked` state,
  refusing unless `block.md` / `unblock.md` exists in the task directory.
- Every lifecycle script emits its `ticket.*` telemetry event via
  `lib/telemetry.sh`.
- The founding roster names no ticket-creation or scaffold script; this
  change adds `routine-scaffold` and `routine-ticket-new` to fill that gap
  (flagged for review in design.md).

## Capabilities

### New Capabilities

- `tickets`: app scaffolding, ticket layout and id allocation, the
  `index.tsv` format and its script-only ownership, task lifecycle statuses
  and ordering rules, and the lifecycle telemetry events.

### Modified Capabilities

<!-- none -->

## Impact

- New files: five `bin/` scripts, their bats suites and fixture trees.
- `runs/` stays gitignored; target projects still receive no files.
- Change 4's analyst gate will consume the index this change defines.
