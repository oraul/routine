## Context

See proposal.md — Why. Constraints: bash 3.2 + BSD/GNU coreutils (TSV and
awk, no jq), Law 3 (script-owned state), Law 6 (`ROUTINE_ROOT` everywhere),
Law 7 (names derived, never invented).

## Goals / Non-Goals

- **Goals**: the full ticket lifecycle change 4+ builds on; every mutation a
  script; every script fixture-testable.
- **Non-Goals**: spec-lint (change 4), conclude/archive and retro (change 5),
  the `/routine` skill that orchestrates these calls (change 6), parallel
  tickets (rejected).

## Decisions

- **Roster gap**: the founding roster names no scaffold or ticket-creation
  script, but §4.7 requires both to exist as scripts (the LLM never chooses
  the folder). Added `routine-scaffold` and `routine-ticket-new` — smallest
  possible additions, same conventions. ⚠ Review point.
- **Index sync lives in `routine-next`**: the analyst creates task
  *directories*; a script must own the index (Law 3). Rebuilding rows at
  `routine-next` time — append-only, strict file order — keeps a single
  writer and no extra roster entry. Alternative (a separate index-sync
  script) adds a call site the skill could forget. ⚠ Review point.
- **Current task addressing**: `routine-done`/`block`/`unblock` operate on
  the single `in_progress` (resp. first `blocked`) row rather than taking a
  task argument — WIP = 1 makes the target unambiguous, and derivation beats
  arguments.
- **Ticket ids scan both `tickets/` and `tickets/archive/`** for the maximum
  existing id, so concluded tickets never cause id reuse.
- **Index rewrite mechanics**: status changes rewrite the whole file via
  `awk` to a temp file + `mv` — atomic enough for a single-writer file, and
  portable to BSD.

## Risks / Trade-offs

- [Tree renamed after rows exist → duplicate rows] → out of scope: the
  analyst gate (change 4) checks index/tree coherence; until then the index
  is append-only and renames are operator error surfaced by that gate.
- [Two concurrent `routine-next` calls could race the rewrite] → WIP = 1 at
  every layer makes concurrent operation a rule violation, not a supported
  mode.

## Migration Plan

New files only; `runs/` is gitignored so no repo state changes shape.
Rollback = revert the merge commit.
