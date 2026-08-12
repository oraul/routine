## Context

Tag pushes from the development environment are transport-blocked; the
GitHub API surface available here has no tag/release creation either.
CI is the one place with both the authority and the reachability to
publish, and the release gate is already a pure script that can run
anywhere.

## Goals / Non-Goals

- **Goals**: releases publishable end to end on the rails; the gate
  remains the only decider.
- **Non-Goals**: automatic releases on merge or tag-shaped triggers —
  dispatch is deliberate and human-initiated, matching the release
  spec's "tagging happens only after the gate exits 0".

## Decisions

- **`workflow_dispatch` with a `tag` input**, not a push trigger: the
  human (or an authorized session) decides when; nothing releases as a
  side effect.
- **The workflow re-runs the gate in CI** rather than trusting the
  dispatcher's local green: the gate's conditions (clean main, version
  match, selfcheck) are re-established where the tag is actually cut.
- **`gh release create` with the workflow token** creates tag and
  release in one step from the verified commit; `permissions:
  contents: write` is the only grant.
- **The workflow is linted structurally by bats** (dispatchable,
  gate before publish, no publish path without the gate) — the yml is
  config, but its ordering is a guarantee, so the harness pins it.

## Risks / Trade-offs

- [The workflow token can create releases] → scoped to
  `contents: write`, dispatch-only, and the gate refuses anything
  malformed or unclean.
- [Structural lint is not execution] → the gate itself is fully tested;
  the lint pins the one property the workflow adds (gate-first order).

## Migration Plan

Additive; the manual UI path keeps working. Rollback = revert the merge
commit (the workflow file disappears with it).
