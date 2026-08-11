## Context

See proposal.md — Why. Change 3 introduces tickets and change 4+ the richer
baselines; this change must build the composition rail without them, on the
bash 3.2 runtime.

## Goals / Non-Goals

- **Goals**: one gate entrypoint with fixed stage order; the seam contract;
  the preflight baseline; a telemetry helper later scripts source unchanged.
- **Non-Goals**: analyst/developer baselines (structure checks, sidecars),
  ticket lifecycle, retro aggregation, any hook scaffolding in targets.

## Decisions

- **Gate names are a fixed list** (`preflight`, `analyst`, `developer`) —
  derivation, not configuration; unknown names fail loudly. No case fallthrough
  cleverness: a plain `case` statement.
- **Ticket context via `ROUTINE_TICKET_DIR`**: telemetry's destination is
  `$ROUTINE_TICKET_DIR/telemetry.jsonl` when set; unset means no emission.
  Rationale: §4.6 binds telemetry to a ticket, tickets arrive in change 3, and
  inventing a fallback file would create state the spec doesn't own. The
  environment variable keeps scripts fixture-testable (Law 6). Change 3's
  `routine-next` becomes the thing that sets it.
- **Target project via `TARGET`** (default: current directory) for the
  preflight worktree checks — same parameterization the caffeine sidecars
  will use, testable against fixture git repos.
- **Timestamps/durations from `date -u` and second precision** for the `ms`
  field's source; bash 3.2 has no `EPOCHREALTIME`, and BSD `date` has no `%N`,
  so `ms` is derived portably (seconds × 1000). Precision can be earned later
  from retro evidence.
- **JSON by `printf`, not a serializer**: values are controlled identifiers
  and integers; the emit function rejects embedded quotes/newlines rather than
  escaping them (boring by design).

## Risks / Trade-offs

- [Second-precision `ms` undercounts fast scripts] → acceptable; retro
  percentiles need relative magnitudes, and the field's contract, not its
  resolution, is what's frozen.
- [Hook scripts run arbitrary app code] → they already own the target; the
  gate only relays their exit code and output, never interprets them.

## Migration Plan

New files only. `routine-selfcheck` lints and tests them automatically.
Rollback = revert the merge commit.
