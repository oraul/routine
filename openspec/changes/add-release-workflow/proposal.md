## Why

The release gate blesses v0.1.0, but the tag cannot leave this
environment: direct tag pushes are blocked at the transport, so the
release dies one step from done and falls back to a manual UI click —
an unscripted step in a repo whose law is that anything that matters is
a script with exit-code semantics.

## What Changes

- **A `release` workflow (`workflow_dispatch`)** takes a `tag` input,
  re-runs `bin/routine-release-check <tag>` on the checked-out `main`
  inside CI, and only on its exit 0 creates the annotated tag and the
  GitHub release from that commit using the workflow token. A failed
  gate publishes nothing.
- **The release spec names the publication path**: tagging happens
  through the workflow after the gate passes — the gate stays the only
  authority; the workflow is its transport.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `release`: the gate's verdict is executed by a dispatchable workflow;
  publication is scripted end to end.

## Impact

- Added: `.github/workflows/release.yml`, `test/release_workflow.bats`
  (structural lint of the workflow: dispatchable, gate-first, no
  publication step without the gate).
