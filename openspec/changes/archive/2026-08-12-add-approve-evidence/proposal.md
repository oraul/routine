## Why

The approve phase is the only human checkpoint in the operational loop
and the least-enforced rule in the repo: nothing records it, the audit
never asks for it, and a run that skipped the human entirely audits
clean. Whatever the human says at approve — caveats, corrections,
scope notes — is written nowhere and is lost to every later analyst and
developer invocation.

## What Changes

- **`bin/routine-approve <ticket-dir> [note]`**: refuses unless a
  passing `gate.analyst` is on record (approval of ungated artifacts is
  meaningless), appends the optional human note to the ticket-level
  `approve.md` under a timestamp, and emits one `ticket.approve` line.
- **The audit demands it**: a passing `ticket.approve` joins the
  run-level checks — a concluded ticket now proves the human was in the
  loop.
- **The skill records the checkpoint**: after the human says proceed,
  phase 3 runs `routine-approve` with any remarks the human made —
  the remarks become ticket evidence instead of transcript exhaust.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `tickets`: approval joins the scripted lifecycle.
- `audit`: the run-level chain gains the approve check.
- `operation`: the skill's approve phase calls the script.

## Impact

- Added: `bin/routine-approve`, `test/approve.bats`.
- Modified: `bin/routine-audit`, `skills/routine/SKILL.md`,
  `test/audit.bats` + `test/conclude.bats` fixtures.
