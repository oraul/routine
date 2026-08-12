## Context

Council coverage audit: nine of ten deps-asserted topics were dead
strings; the highest-leverage additions are the testing topic per
ecosystem and the language-agnostic TDD judgment the loop already
enforces mechanically.

## Goals / Non-Goals

- **Goals**: a credible beachhead per ecosystem (app + test pairs), the
  loop's own discipline taught, secrets teaching beside its harness.
- **Non-Goals**: breadth (pg, puma, react, jest, flask… wait for the
  deepening queue's evidence); cross-file rules.

## Decisions

- **Testing topics carry the higher leverage half** of each ecosystem —
  vitest and pytest rules police the suites the developer gate runs.
- **Sidecar include globs are per-topic**: `sidecar_include` is set by
  each sidecar (`*.js *.mjs *.ts` / `*.py`), the library default stays
  `*.rb`.
- **Doc-only for the concern namespaces**: no grep judges TDD or a
  leaked credential's blast radius; both docs point at the scripts that
  do the mechanical half (`routine-tdd`, `routine-convention-check`).
- **Rules stay at 3–5 with the same near-miss discipline K2
  established**: each new rule ships a tripping and a passing fixture.

## Risks / Trade-offs

- [Four sidecars authored in one change] → all on the shared library;
  the lint enforces the contract; fixtures pin every rule.
- [Judgment docs for ecosystems the repo doesn't dogfood] → sources are
  the official guides, named in the metadata; the deepening queue will
  tell us where reality disagrees.

## Migration Plan

Purely additive. Rollback = revert the merge commit.
