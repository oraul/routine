## Context

See proposal.md — Why. CLAUDE.md competes for context in every session;
brevity is a feature, and everything it says must already be true
elsewhere (specs, CONTRIBUTING) — it points, it does not fork.

## Goals / Non-Goals

- **Goals**: one screen a session can absorb; no rule stated only here.
- **Non-Goals**: duplicating CONTRIBUTING or the specs; per-directory
  CLAUDE.md files; tool configuration.

## Decisions

- **Pointers over prose**: the laws and conventions live where they live;
  CLAUDE.md carries only the rules a session must know *before* reading
  further (spec-first, hard rules, commands), then points.
- **The hard rules are restated verbatim-in-spirit** despite the
  no-duplication stance — they are the one class of mistake that cannot be
  fixed by a follow-up commit, so they earn the redundancy.

## Risks / Trade-offs

- [Drift between CLAUDE.md and the sources it points to] → the guidance
  spec pins the required content; changes to it go through the loop like
  everything else.

## Migration Plan

Additive. Rollback = revert the merge commit.
