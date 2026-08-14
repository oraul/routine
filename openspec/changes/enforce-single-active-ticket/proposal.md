## Why

WIP is 1 by Law, but nothing enforces it where it can actually break:
`routine-ticket-new` allocates unconditionally. After a session dies
mid-run, a fresh session that opens a new ticket instead of adopting
the live one leaves the dying run's ticket stranded — it can never
conclude (unfinished tasks), nothing adopts it, and the run's evidence
becomes orphaned state. The council found this from two lenses and
`routine-health` now makes the incumbent discoverable; this closes the
other half by making the allocator refuse.

## What Changes

- **`routine-ticket-new` refuses while a ticket is live**: exit 3
  naming the incumbent's path and the two roads — adopt it (export
  `ROUTINE_TICKET_DIR` to it; `routine-health` says where it stopped)
  or end it (`routine-abort`, or `routine-conclude` when its work is
  done). Archived tickets never block allocation, so the sequential
  id rule is untouched.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `tickets`: allocation refuses to break WIP=1.

## Impact

- Modified: `bin/routine-ticket-new`, `test/ticket_new.bats`.
