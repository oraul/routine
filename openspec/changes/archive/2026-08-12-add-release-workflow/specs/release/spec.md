## MODIFIED Requirements

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
