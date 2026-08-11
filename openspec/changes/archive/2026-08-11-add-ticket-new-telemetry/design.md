## Context

See proposal.md — Why. One-line gap closure; no new machinery.

## Goals / Non-Goals

- **Goals**: every ticket's telemetry starts at birth.
- **Non-Goals**: telemetry for scaffold/deps (no ticket context exists;
  the telemetry spec forbids invented destinations).

## Decisions

- **Event name `ticket.new`** joins the dot-notation family; ticket and
  file are the ones just created, task empty.

## Risks / Trade-offs

- None of note; append to a file the script itself just created.

## Migration Plan

Additive. Rollback = revert the merge commit.
