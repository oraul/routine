## Why

The council found the recovery paths are tarpits: the revise budget is
counted over the ticket's whole lifetime, so a defect return inherits
the first specify's spent attempts — the documented epic recovery path
collides with the counter — and a ticket past the limit can never pass
the analyst gate again while nothing moves it out of the active
directory, where the next `/routine` run adopts it and dead-ends
forever. `routine-defect` truncates prior reasons, destroying exactly
the history a re-specifying analyst needs. And the abort itself is
prose — SKILL.md line 40 steers a lifecycle transition with words, the
same Law 1 violation the defect return already fixed.

## What Changes

- **The revise budget is per episode**: the analyst gate counts only
  `spec.lint` failures recorded after the most recent `spec.defective`
  line — re-specified work is new work, exactly as the skill already
  says. Line order is time order; the counter needs no new state.
- **`routine-defect` appends**: each return adds a timestamped entry to
  `defect.md`; repeated returns keep the full history.
- **`bin/routine-abort <ticket-dir> <reason>`**: refuses without a
  reason (the defect precedent), writes ticket-level `abort.md`, emits
  one `ticket.abort` line, moves the ticket to `tickets/archive/<id>/`
  with every artifact intact, and prints the archived path. The skill's
  revise-exhausted branch calls the script instead of instructing an
  abort in prose. Archive (not a new `aborted/` root) keeps
  `routine-ticket-new`'s id scan collision-free.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `gates`: per-episode revise counting.
- `contract`: the counted limit resets at the defect return.
- `tickets`: abort joins the scripted lifecycle; defect history appends.
- `operation`: the skill's abort branch names the script.

## Impact

- Modified: `bin/routine-gate`, `bin/routine-defect`,
  `skills/routine/SKILL.md`, `test/gate.bats`, `test/defect.bats`.
- Added: `bin/routine-abort`, `test/abort.bats`.
