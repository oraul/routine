# release Specification

## Purpose

What a version tag asserts and how one is earned: releases are guarantees,
so their conditions are spec'd and their gate is a script.

## Requirements

### Requirement: A tag asserts an implemented, green spec set
An annotated tag `v<major>.<minor>.<patch>` on `main` SHALL assert that, at
the tagged commit, every capability under `openspec/specs/` is implemented,
`routine-selfcheck` passes, and `.claude-plugin/plugin.json` declares
exactly the tag's version.

#### Scenario: Tag and manifest agree
- **WHEN** `v0.2.0` is cut
- **THEN** `plugin.json` at that commit declares version `0.2.0`

### Requirement: Version components bump by rule
Relative to the previous tag: a **patch** bump SHALL contain only fixes and
chores (no capability added, removed, or modified); a **minor** bump SHALL
be used when any spec capability changed; the **major** bump to 1.0.0 SHALL
be reserved until retro evidence from real-project runs demonstrates the
operational loop end to end.

#### Scenario: Capability delta forces minor
- **WHEN** a release includes a change that modified `openspec/specs/`
- **THEN** the minor component bumps and the patch resets

### Requirement: The release gate is scripted
`bin/routine-release-check <vX.Y.Z>` SHALL verify: the argument is a
well-formed semver tag; the worktree is clean and on `main`; `plugin.json`
declares the matching version; and `routine-selfcheck` exits 0. It SHALL
exit non-zero naming the first unmet condition, and tagging SHALL happen
only after it exits 0. Publication SHALL be scripted end to end: a
manually dispatched `release` workflow takes the tag as input, re-runs
`routine-release-check` against the checked-out `main`, and only on its
exit 0 creates the annotated tag and the GitHub release from that
commit; a failed gate publishes nothing.

#### Scenario: Manifest mismatch blocks the release
- **WHEN** `routine-release-check v0.2.0` runs while `plugin.json` declares
  `0.1.0`
- **THEN** it exits non-zero naming the version mismatch

#### Scenario: All conditions met
- **WHEN** the tree is clean on `main`, versions agree, and selfcheck is
  green
- **THEN** `routine-release-check` exits 0

#### Scenario: The workflow is gate-first
- **WHEN** the `release` workflow is dispatched with a tag
- **THEN** `routine-release-check` runs before any tag or release
  creation step, and a non-zero gate stops the job before publication
