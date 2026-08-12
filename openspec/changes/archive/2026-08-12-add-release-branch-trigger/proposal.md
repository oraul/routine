## Why

The release workflow shipped dispatch-only, but `workflow_dispatch`
needs an `actions: write` token and the development environment's
integration has none — the release still dies one step from done.
Branch pushes are the one transport that works end to end, and a push
of `release/vX.Y.Z` is as deliberate an act as a dispatch click.

## What Changes

- **The release workflow also triggers on a `release/v*` branch push**:
  the tag derives from the branch name, the job checks out `main` and
  runs the same gate-first pipeline, and the trigger branch is deleted
  after a successful publication. Dispatch keeps working; plain branch
  pushes still trigger nothing.
- **The structural lint tightens accordingly**: push triggers are legal
  only for `release/v*`.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `release`: publication is requestable by dispatch or by pushing a
  `release/vX.Y.Z` branch; the gate stays the only authority.

## Impact

- Modified: `.github/workflows/release.yml`,
  `test/release_workflow.bats`.
