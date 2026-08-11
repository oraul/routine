## Context

See proposal.md — Why. This is change 1: nothing exists yet, so the design
fixes the harness conventions every later script inherits. The runtime target
is bash 3.2 + BSD/GNU coreutils (Law 5); CI must therefore prove the suite on
macOS as well as Linux.

## Goals / Non-Goals

- **Goals**: a selfcheck any contributor can run locally with only bats and
  shellcheck installed; CI that mirrors it exactly; conventions (root
  resolution, test layout) that later `bin/` scripts copy unchanged.
- **Non-Goals**: telemetry (change 2), gates beyond selfcheck, selfcheck
  caching, any target-app awareness.

## Decisions

- **Root resolution order** `ROUTINE_ROOT` → `$CLAUDE_PLUGIN_ROOT` → the
  script's own repo root, computed from `$0` with `cd/pwd` (no `realpath`,
  absent on stock macOS). Rationale: Law 6 testability against fixtures;
  alternatives (git rev-parse) fail inside non-git fixture trees.
- **Shellcheck target discovery** via `find` over `bin/`, `lib/`, and
  `caffeine/*/`, filtered to executable scripts and `.sh`/extension-less
  files — no shell globs, because bash 3.2 has no `globstar` and empty globs
  expand to themselves.
- **Selfcheck stages are ordered, not parallel**: lint fully, then test. A
  lint failure aborts before bats runs, because a non-parseable script makes
  test results meaningless.
- **CI installs pinned tooling per job**: `shellcheck` from the runner's
  package manager, `bats-core` via checkout of its release tag (works
  identically on both matrix legs; npm bats is a wrapper we don't want in CI).
- **`openspec-validate` is a separate CI job**, not part of selfcheck:
  selfcheck guards operational integrity; a malformed in-flight proposal must
  not block work on a target app.

## Risks / Trade-offs

- [Dev machine runs bash 5, runtime target is 3.2] → the macOS CI leg runs the
  suite under the system bash 3.2; portability bugs surface there.
- [shellcheck versions differ across platforms] → treat any finding as
  failure; no version-specific pragmas unless CI forces one.

## Migration Plan

New files only; first merge through the ruleset. Rollback = revert the merge
commit.
