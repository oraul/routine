## Why

The analyst's output is only trustworthy if a deterministic script can reject
malformed tickets before any development starts. The spec grammar needs its
linter, and the analyst gate needs its baseline — both pure grep/awk
structure checks, no semantic judgment.

## What Changes

- Add `bin/routine-spec-lint <ticket-dir>`: structural grammar checks over a
  ticket — `requirement.md` exists with a requirement header and RFC 2119
  keywords; every briefing has `briefing.md` with a caffeine manifest section
  and at least one task; every `task.md` carries at least one
  Given/When/Then scenario and a non-empty enumerated acceptance list. Every
  failure names the file and the rule; emits one `spec.lint` telemetry line.
- Implement the analyst gate baseline in `bin/routine-gate`: resolve the
  ticket from `ROUTINE_TICKET_DIR`, run `routine-spec-lint`, then check the
  index is coherent with the directory tree (every row has its directory,
  every task directory has its row).

## Capabilities

### New Capabilities

- `spec-grammar`: the ticket artifact grammar and the lint contract that
  enforces it structurally.

### Modified Capabilities

- `gates`: the analyst gate gains its baseline (spec-lint plus index/tree
  coherence, addressed via `ROUTINE_TICKET_DIR`).

## Impact

- New: `bin/routine-spec-lint`, its bats suite and fixture tickets.
- Modified: `bin/routine-gate` (analyst baseline only; other gates
  untouched), `test/gate.bats`.
