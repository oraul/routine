## Why

Every lifecycle event leaves a telemetry line except the one that starts it
all: ticket creation. `routine-ticket-new` creates the ticket's own
`telemetry.jsonl` destination in the same breath, so its silence is a gap,
not a design choice — and the retro cannot count tickets without it.

## What Changes

- `bin/routine-ticket-new` emits one `ticket.new` line into the ticket it
  just created.
- `routine-scaffold` and `routine-deps` stay silent by design: they run
  outside any ticket context, and the telemetry spec already says scripts
  never invent a destination.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `tickets`: the allocation requirement gains the `ticket.new` evidence
  line.

## Impact

- Modified: `bin/routine-ticket-new`, `test/ticket_new.bats`.
