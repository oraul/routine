## Context

See proposal.md — Why. Same stance as CLAUDE.md: the README presents and
points; it never forks a rule stated elsewhere.

## Goals / Non-Goals

- **Goals**: a reader understands in one pass what routine is, how a run
  flows, and how to start.
- **Non-Goals**: duplicating specs or CONTRIBUTING; screenshots; marketing.

## Decisions

- **Capability map over feature list**: the map names each spec'd
  capability in one line, making `openspec/specs/` the obvious next read.
- **The loop shown as the phase line**, not paragraphs — the five phases
  and who acts in each is the whole mental model.

## Risks / Trade-offs

- [README drift as capabilities grow] → the guidance spec now pins the
  required sections; capability additions touch the map through the loop.

## Migration Plan

Docs only. Rollback = revert the merge commit.
