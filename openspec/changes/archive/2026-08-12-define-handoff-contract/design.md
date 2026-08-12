## Context

See proposal.md — Why. Council audit findings 3.3 and 3.5 (drift auditor):
manifest validity checked on the wrong side of approve; the defect return
carried by prose.

## Goals / Non-Goals

- **Goals**: one capability owning the seam; every contract clause either
  enforced by a script or explicitly labeled prose-with-retro-feedback.
- **Non-Goals**: enforcing what cannot be observed (what the developer
  read, red-first ordering — that lands with the TDD telemetry change);
  contract topics beyond the four types.

## Decisions

- **Topics live in `requirement.md`**, one `## <Topic>` section per type,
  because the type is ticket-scoped and the requirement is the analyst's
  root artifact — the same place `## Reproduction` already lives.
- **Resolvability at lint** reuses the same repo-relative resolution the
  gate uses (`dirname $0/..`), so lint and gate can never disagree about
  what exists.
- **`defect.md` mirrors `block.md`**: evidence file + script + telemetry
  event, the pattern the blockage path proved. The script writes the file
  from its argument (unlike block.md) because the reason IS the argument.
- **Revise limit reads telemetry, not a counter file**: the events are
  already the ledger; `grep -c` over `spec.lint` failures needs no new
  state (Law 3: no second writer).

## Risks / Trade-offs

- [Lint now needs the caffeine tree] → it already runs from the repo that
  ships it; fixture tickets in tests reference real repo topics
  (`ruby/rails`) exactly as gate tests do today.
- [Legacy tickets without typed topics fail new lint] → none exist beyond
  local demo state.

## Migration Plan

Additive script + stricter lint. Rollback = revert the merge commit.
