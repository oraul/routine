## Context

Council prompt-quality audit: "the only human checkpoint should not be
the least enforced rule in the repo." The loss-surface audit added the
second half: the human's approve-phase remarks are the highest-value
context in the run and nothing persists them.

## Goals / Non-Goals

- **Goals**: approval is evidence; the human's words survive.
- **Non-Goals**: verifying a human (vs the driver) ran the script — no
  mechanical check can; the script makes skipping *visible*, which is
  what the audit can honestly enforce.

## Decisions

- **Refuse without a passing `gate.analyst`**: approval orders after
  the gate by construction, the same derived-not-claimed discipline as
  attribution.
- **Notes append to `approve.md`** with timestamps (the defect.md
  precedent) — re-approvals after a defect return keep the history.
- **The audit checks presence, not position beyond the gate**: the
  script's own refusal already guarantees gate-then-approve ordering.

## Risks / Trade-offs

- [A driver could run routine-approve without asking the human] → true
  of every prose checkpoint; now the violation leaves a line the human
  can see, instead of nothing.

## Migration Plan

Audit and conclude fixtures gain the approve line. Rollback = revert
the merge commit.
