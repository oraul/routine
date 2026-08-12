## Context

Council finding: the loop's guarantees are per-stage; nothing checks the
run as a whole. C1–C3 landed the prerequisites — typed contracts,
fail-closed gates, attributed evidence — so the audit can be a pure
reader of script-owned state.

## Goals / Non-Goals

- **Goals**: one script that says whether a ticket's evidence matches
  the protocol, all violations in one run; conclude fails closed on it.
- **Non-Goals**: judging content quality (the gates did); auditing
  app-level telemetry; retro-style aggregation.

## Decisions

- **The audit reads, never writes**: pure grep/awk over
  `telemetry.jsonl`, `index.tsv`, and task manifests. Its own telemetry
  line is emitted by conclude's refusal path, not by the audit — a
  reader that wrote would contaminate what it reads.
- **Fixed key order makes grep sufficient**: `"task":"X","exit":0` is a
  reliable pattern because emission order is a spec guarantee.
- **Red-before-green is per scenario per task**: a `tdd.green` counts
  only if an earlier `tdd.red` with the same scenario and task recorded
  a non-zero exit — ordering by line number, the file is append-only.
- **Manifest topics are re-read at audit time** from each done task's
  `task.md`: a `.sh` topic needs a green `gate.developer.script` line
  naming it; a doc-only topic needs its `gate.developer.doc` line.
- **Conclude's fixtures get honest telemetry** — the existing tests
  concluded tickets with no evidence at all, exactly the hole the
  council named.

## Risks / Trade-offs

- [Old tickets with pre-C3 telemetry cannot conclude] → correct: their
  evidence really is incomplete; the human can archive by hand if ever
  needed (a deliberate manual override, not a silent pass).
- [Audit grep patterns couple to the key order] → the order is a strict
  spec requirement with tests; a change there must touch the audit too.

## Migration Plan

New script plus a tightened conclude; no state format changes.
Rollback = revert the merge commit.
