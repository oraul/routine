## Context

See proposal.md — Why. Parsing three manifest formats with bash 3.2 + BSD
tools, and drawing the determinism boundary through "generate best
practices".

## Goals / Non-Goals

- **Goals**: scripted discovery; a generation protocol that produces pairs
  indistinguishable from hand-written ones.
- **Non-Goals**: lockfile parsing (direct deps express intent; lockfiles
  add transitive noise), version-specific advice, auto-committing generated
  pairs, ecosystems beyond the three manifests until asked for.

## Decisions

- **The boundary**: discovery is a script (`routine-deps`); drafting is the
  LLM inside `/caffeinate`; acceptance is `routine-selfcheck` — a generated
  sidecar passes the same shellcheck + bats bar as a hand-written one, so
  "magic" never becomes load-bearing (Law 1).
- **package.json without jq**: an awk pass that enters the
  `"dependencies"`/`"devDependencies"` objects and takes each key until the
  closing brace. Heuristic but fixture-tested; a package name with a brace
  in it does not exist in practice.
- **Gemfile extraction** matches `gem "name"`/`gem 'name'` at line starts —
  group blocks and options are irrelevant to the name.
- **Topic naming is derivation** (Law 7): `<ecosystem>/<package>` verbatim
  from the manifest, lowercased as published; no curation in the script.
- **The skill selects with the human**, not automatically: a Gemfile can
  name dozens of gems and most deserve no sidecar; choosing is judgment.

## Risks / Trade-offs

- [Heuristic JSON parse misses exotic formatting] → fixtures pin the
  supported shapes; unsupported shapes fail visibly, not silently.
- [LLM drafts weak rules] → per-rule fixtures force each rule to
  demonstrate a real catch, and the retro measures sidecar usefulness over
  time.

## Migration Plan

Additive only. Rollback = revert the merge commit.
