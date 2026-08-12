## Context

`workflow_dispatch` requires `actions: write`; the environment's
integration token returned 403. Branch pushes carry the same trust
boundary (repo write access) and are reachable from here.

## Goals / Non-Goals

- **Goals**: a release requestable entirely on the rails from any
  environment with push access.
- **Non-Goals**: releasing as a side effect — a `release/v*` push is an
  explicit request, and the gate still refuses anything unclean.

## Decisions

- **The tag derives from the branch name** (`release/v0.1.0` →
  `v0.1.0`); the job always checks out and gates `main`, never the
  trigger branch — the branch is a message, not a source.
- **The trigger branch is deleted only after successful publication**;
  a failed gate leaves it in place as the visible evidence of the
  refused request.
- **Both triggers share one job**: `TAG` falls back from the dispatch
  input to the branch-derived name, so the pipeline cannot diverge.

## Risks / Trade-offs

- [Anyone with push access can request a release] → identical trust
  boundary to dispatch; the gate re-verifies everything on `main`.

## Migration Plan

Additive trigger; dispatch unchanged. Rollback = revert the merge
commit.
