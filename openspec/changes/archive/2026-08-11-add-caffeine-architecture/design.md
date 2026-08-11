## Context

See proposal.md — Why. The caffeine mechanism already separates mechanics
(`.sh`) from judgment (`.md`); architecture is the case where judgment is
the entire payload, in any language.

## Goals / Non-Goals

- **Goals**: doc-only topics as first-class manifest citizens; two
  architecture seeds worth loading.
- **Non-Goals**: pretending architecture is grep-able (no fake sidecars);
  a taxonomy of every style up front — more docs are earned when the
  analyst actually reaches for them; per-language architecture variants.

## Decisions

- **Resolution order at the gate**: `.sh` wins when both exist (a topic may
  later *earn* mechanical rules and keep its doc); `.md` alone passes with
  a log line; neither fails loudly. One rule, three branches, all tested.
- **`architecture/` is a namespace, not a language** — the same
  `<namespace>/<topic>` shape as `ruby/`, so manifests, `/caffeinate`, and
  the gate need no new syntax.
- **Seeds are `oop` and `hexagonal`**: the two the user reached for;
  event-driven, layered, and friends arrive when a real task manifests
  them.

## Risks / Trade-offs

- [A typo'd topic name now passes if a stray .md matches] → unchanged risk
  from before (a typo'd .sh name also had to exist to run); neither-file
  still fails, which catches real typos.

## Migration Plan

Additive plus one gate branch; existing manifests behave identically.
Rollback = revert the merge commit.
