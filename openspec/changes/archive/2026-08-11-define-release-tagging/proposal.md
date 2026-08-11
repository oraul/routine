## Why

The repository is about to cut its first tag with no definition of what a
tag asserts, when a version component bumps, or what must be true before
tagging. A release is a guarantee, and guarantees here live in specs and
scripts — not in whoever happens to be tagging.

## What Changes

- Define the release contract as a new `release` capability: a tag
  `v<major>.<minor>.<patch>` asserts that every capability in
  `openspec/specs/` is implemented and green at the tagged commit; the
  manifest version and the tag agree; version components bump by rule
  (patch = fixes/chores only, minor = capability delta, major reserved
  until real-use evidence earns 1.0).
- Add `bin/routine-release-check <vX.Y.Z>`: the mechanical gate — semver
  format, `plugin.json` version match, clean worktree on `main`, and a
  green `routine-selfcheck`. Tagging is permitted only after it exits 0.
- Record the tag definition in CONTRIBUTING.md alongside the other
  conventions.

## Capabilities

### New Capabilities

- `release`: what a tag asserts, the version-bump rules, and the scripted
  release gate.

### Modified Capabilities

<!-- none -->

## Impact

- New: `bin/routine-release-check`, its bats suite; CONTRIBUTING.md gains a
  Releases section. No existing behavior changes.
