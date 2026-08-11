## Context

See proposal.md — Why. First run of the `/caffeinate` generation protocol;
the pair must be indistinguishable from the hand-written seeds.

## Goals / Non-Goals

- **Goals**: four honestly mechanical rules from sidekiq's documented
  footguns; the existing sidecar contract verbatim.
- **Non-Goals**: semantic checks (idempotency, uniqueness strategies) —
  those live in the `.md`.

## Decisions

- **`sleep` scoped to job directories** (`app/workers`, `app/jobs`,
  `app/sidekiq`) — a sleeping job pins a Sidekiq thread; elsewhere it is
  not this topic's business.
- **`retry: false` flagged unconditionally**: the rule is mechanical; the
  `.md` explains the legitimate escape (a stated dead-set or cleanup plan)
  and the reviewer judges it.

## Risks / Trade-offs

- [Keyword-argument grep can hit hash-literal positional args] → accepted;
  symbol keys in perform_* arguments round-trip badly through JSON either
  way, which is exactly the footgun.

## Migration Plan

Additive. Rollback = revert the merge commit.
