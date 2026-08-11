## Context

See proposal.md — Why. The gate must be testable against fixture trees
(Law 6) while judging real release conditions.

## Goals / Non-Goals

- **Goals**: a tag whose meaning is written down; a gate a script enforces.
- **Non-Goals**: changelog generation, GitHub Release automation (the
  environment cannot push tags anyway — the human tags through the UI after
  the gate passes), release branches.

## Decisions

- **The gate checks conditions, not history**: patch-vs-minor correctness
  is judged by the human against the rule (a spec diff since the last tag
  is judgment about intent); the script checks what is mechanically
  checkable — format, manifest match, branch, cleanliness, selfcheck.
- **`ROUTINE_ROOT` resolution as everywhere**, so fixtures with their own
  git repo, manifest, and fake selfcheck exercise every branch of the gate.
- **Branch name `main` is asserted literally** — derivation, not
  configuration; this repository has exactly one long-lived branch.

## Risks / Trade-offs

- [Human mislabels patch vs minor] → the rule is one sentence in the spec
  and CONTRIBUTING; PR review of the tag commit is the check.

## Migration Plan

Additive. Rollback = revert the merge commit.
