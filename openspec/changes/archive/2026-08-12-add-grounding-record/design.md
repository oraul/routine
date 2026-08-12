## Context

Council loss-surface map: every transition that loses the analyst's
context (revise, abort-retry, defect return) re-derives from artifacts
that carry conclusions without evidence. The recovery design evaluated
five mechanisms; this change ships the two that are mechanical and
defers the speculative ones.

## Goals / Non-Goals

- **Goals**: grounding persisted where gates can demand it; staleness
  impossible past a defect return; recovery instructions that work with
  zero conversation continuity.
- **Non-Goals** (Law 9 flags): per-work-type grounding sections (wait
  for retro evidence); cross-ticket inheritance (no parent relationship
  exists; `ticket.abort` is the counter that would earn it);
  path-existence validation of Evidence lines (would make the linter a
  target-reader); `spec.grounding` telemetry (no script invocation to
  attribute; the gate-checked artifact is the evidence); grounding in
  the developer's context (the closed list is the point).

## Decisions

- **Ticket level, not per task**: grounding backs the requirement and
  the decomposition — task-level fragments would duplicate the shared
  ground per task.
- **Structural checks only**, the linter's whole register: headers
  exist, Evidence has ≥1 bullet, Reconciliation names each defective
  task id (derived by globbing `briefings/*/tasks/*/defect.md`).
- **The re-specify keeps existing task directories** (prompt rule): the
  index is append-only and orphan rows are gate-fatal; a restructure is
  an abort plus a fresh ticket, never a rename.
- **Developer never reads grounding**: its closed context is spec'd;
  the manifest exists to prevent exactly this bloat.

## Risks / Trade-offs

- [One more lint rule burns revise attempts] → G2 made the budget
  per-episode first, deliberately in that order.
- [Grounding could be padded to satisfy grep] → true of every
  structural check; the human sees grounding.md at approve alongside
  the artifacts it justifies.

## Migration Plan

Fixtures gain minimal grounding files. Rollback = revert the merge
commit.
