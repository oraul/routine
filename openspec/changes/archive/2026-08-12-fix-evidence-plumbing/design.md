## Context

Three council auditors independently converged on the same hole: the
skill exports `ROUTINE_TICKET_DIR` in the driver's shell, subagent
shells never inherit it, and the emission layer treats the absence as a
clean no-op. Every downstream audit check is unsatisfiable and nothing
says so until conclude.

## Goals / Non-Goals

- **Goals**: no evidence path can fail silently; the red/green pair
  proves command identity.
- **Non-Goals**: prompt-side plumbing (G5 hands the variable to the
  developer); per-scenario coverage counting (G6).

## Decisions

- **Preflight joins the fail-closed family** rather than pinning
  ordering in prose — the C2 argument verbatim: the asymmetry was the
  defect. The telemetry wrapper's no-op stays for genuinely optional
  emitters (harness scripts); the *gates* now all refuse to run
  unrecorded.
- **The command hash rides the scenario string** (`<scenario> [<hash>]`,
  cksum-derived, 8 chars) instead of a new telemetry key — the fixed key
  order is a spec guarantee with positional parsers (retro); the audit
  already pairs by byte equality, so identity enforcement falls out
  free. `routine-tdd` prints the recorded form so the developer sees
  what the evidence says.
- **Emission failures relay**: `routine-tdd` checks the emit's return
  and exits 3 naming the rejected value — distinct from the command's
  own exit and from usage (2).

## Risks / Trade-offs

- [Preflight now needs a ticket first] → that is the skill's existing
  phase order; the gate error names the fix in one line.
- [Hash suffix changes the display string] → the audit compares bytes
  either way; hand-written fixtures without hashes remain valid.

## Migration Plan

Tests that ran preflight without ticket context gain fixture tickets.
Rollback = revert the merge commit.
