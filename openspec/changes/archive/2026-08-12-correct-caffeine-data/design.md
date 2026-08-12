## Context

Council content audit: rspec rich, sidekiq/active_record/rails adequate
with factual errors, both architecture docs shallow. The lint (K1)
enforces structure and provenance; it cannot enforce truth. Truth is
pinned the mechanical way this repo pins everything: bats assertions on
load-bearing strings and on the absence of the known-wrong claims.

## Goals / Non-Goals

- **Goals**: no guide teaches a falsehood the council verified; every
  guide teaches with worked material; conflicts between co-loadable
  topics carry an arbitration rule.
- **Non-Goals**: new topics (K5); catalog wiring (K4); covering every
  gap the audit listed — the top-five content repairs land, the
  deepening queue (retro) decides the rest from evidence.

## Decisions

- **Content tests assert strings, not prose quality**: presence of
  `strict_args!`, `perform_bulk`, `unique: true`, `instance_double`,
  `let!`, `when NOT to` etc., and absence of "corrupt silently",
  "guarantees at-least-once", the `...` elided body, and the Timecop
  recommendation. Crude, honest, and exactly what grep can see.
- **Arbitration lives in both conflicting docs**: rails.md and
  hexagonal.md each carry one paragraph stating how to resolve when a
  manifest loads both (the target's existing architecture wins; in a
  vanilla Rails app the model layer is the domain and hexagonal applies
  at the app-service seam).
- **Version-sensitive claims carry their version inline** (e.g. "Rails
  7.2's `enqueue_after_transaction_commit`"), consistent with the
  `caffeine-applies` header K1 added.
- **Guides keep the lint green**: verbatim rule lists and metadata are
  untouched invariants; the reviewed date bumps.

## Risks / Trade-offs

- [String assertions could pin wording too tightly] → they pin terms of
  art (API names), not sentences; renaming an API is exactly when a
  test should fail.
- [Longer guides cost context tokens] → the council found a third of
  sidekiq/active_record was self-duplication; the rewrite spends that
  budget on the missing content instead.

## Migration Plan

Docs only; sidecars and the gate untouched. Rollback = revert the
merge commit.
