## Context

Two council auditors traced the same collision: the epic calibration
designs for repeated defect returns; the lifetime counter bricks the
ticket on the way. The abort has no script, so the bricked directory
stays active with no forensic residue.

## Goals / Non-Goals

- **Goals**: recovery paths that terminate instead of trapping; abort as
  a real lifecycle transition with evidence.
- **Non-Goals**: cross-ticket grounding inheritance (Law 9 — zero aborts
  on record; `ticket.abort` is the instrument that would earn it);
  un-doing `done` rows (a defective done task is a new requirement, not
  a rewind).

## Decisions

- **Count after the last `spec.defective`**: awk finds the last defect
  line's number; failures at or before it don't count. Append-only file,
  line order is time order — the same guarantee the audit already leans
  on. No new state, no reset command to misuse.
- **Append with a timestamp header** in `defect.md`
  (`## <ISO timestamp>` + reason) — history reads chronologically, the
  newest entry is the operative one.
- **Abort archives to `tickets/archive/<id>/`** marked by `abort.md`,
  never a new state location: `routine-ticket-new` scans active and
  archive for id allocation, so a third root would let ids be reused and
  collide in telemetry. No `report.md` — that file asserts completion.
- **`ticket.abort` emits before the move** so the line lands in the
  ticket's own telemetry and rides into the archive.

## Risks / Trade-offs

- [An abort could hide a salvageable ticket] → the artifacts survive
  intact in the archive and the printed path names them; nothing is
  deleted.
- [Per-episode counting weakens the limit] → it restores the limit's
  stated meaning ("3 revise attempts" per specify episode); the lifetime
  reading was the bug.

## Migration Plan

Additive script plus two behavioral corrections where the old behavior
was the defect. Rollback = revert the merge commit.
