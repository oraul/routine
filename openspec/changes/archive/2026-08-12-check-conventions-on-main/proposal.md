## Why

The `conventions` CI job is gated to pull-request events, so every push
to main — which is what a merge is — skips it. That gap is aimed at
exactly the wrong commit: the merge commit's message is written by
GitHub at merge time, after the last PR-side check ran, so it is the
one commit CI never scans. The checker itself already handles merges
(sensitive-pattern scan applies to every message; only the grammar
exempts merges) — the workflow gate is the only thing keeping it off
main. A full-history scan today shows the hard rule was never violated;
the fix closes a latent hole, not an active leak.

## What Changes

- **The `conventions` job runs on push to main too.** The event gate
  goes; a base-resolution step picks the diff base per event —
  `origin/$base_ref` on pull requests, `github.event.before` (the
  previous main tip) on pushes, falling back to the parent commit when
  `before` is the zero hash or unreachable (first push, force push).
  Pushed history is scanned exactly once; old history is never
  rescanned, so pre-harness commits stay out of scope.
- **`test/ci_workflow.bats`** pins the job shape the way
  `release_workflow.bats` pins the release workflow: no event gate on
  the job, both bases named, a fallback present.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `conventions`: the CI requirement covers pushes to main, closing the
  merge-commit gap.

## Impact

- Modified: `.github/workflows/ci.yml`.
- Added: `test/ci_workflow.bats`.
