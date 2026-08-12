## MODIFIED Requirements

### Requirement: The release gate is scripted
`bin/routine-release-check <vX.Y.Z>` SHALL verify: the argument is a
well-formed semver tag; the worktree is clean and on `main`; `plugin.json`
declares the matching version; and `routine-selfcheck` exits 0. It SHALL
exit non-zero naming the first unmet condition, and tagging SHALL happen
only after it exits 0. Publication SHALL be scripted end to end: the
`release` workflow runs on manual dispatch with a tag input or on a
push of a `release/vX.Y.Z` branch (the tag deriving from the branch
name); either way it re-runs `routine-release-check` against the
checked-out `main`, composes the body with `bin/routine-release-notes`,
and only on the gate's exit 0 publishes — creating the annotated tag and
GitHub release when the tag is new, editing the existing release's title
and notes in place (never moving the tag) when it is not. A failed gate
publishes nothing; a successful branch-triggered publication deletes its
trigger branch.

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

#### Scenario: A release branch is a request, not a source
- **WHEN** `release/v0.1.0` is pushed
- **THEN** the workflow gates and publishes from `main` with tag
  `v0.1.0`, and only unrelated branch pushes trigger nothing

#### Scenario: Re-requesting a published tag repairs its notes
- **WHEN** the workflow runs for a tag whose release already exists
- **THEN** the release's title and notes are replaced from
  `routine-release-notes` and the tag itself is unchanged

## ADDED Requirements

### Requirement: Release notes are scripted and owner-free
`bin/routine-release-notes <vX.Y.Z> [repo-dir]` SHALL print release
notes composed from the first-parent merge subjects between the previous
tag and the release (all history when no previous tag exists; the
current HEAD while the tag is not yet created), one bullet per merge
with the `Merge pull request #N: ` prefix stripped. The output SHALL
contain no `@` mentions or account identifiers.

#### Scenario: Bullets from merge subjects
- **WHEN** the history holds a merge titled
  `Merge pull request #7: feat: add-x — outcome`
- **THEN** the notes contain the bullet `- feat: add-x — outcome`

#### Scenario: Range respects the previous tag
- **WHEN** a previous tag exists and a merge landed before it
- **THEN** that merge's subject is absent from the new release's notes

#### Scenario: Owner-free output
- **WHEN** notes are generated for any range
- **THEN** the output contains no `@` character
