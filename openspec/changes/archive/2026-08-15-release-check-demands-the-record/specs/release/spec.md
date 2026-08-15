# release Specification (delta)

## MODIFIED Requirements

### Requirement: The release gate is scripted
`bin/routine-release-check <vX.Y.Z>` SHALL verify: the argument is a
well-formed semver tag; the worktree is clean and on `main`; `plugin.json`
declares the matching version; `routine-selfcheck` exits 0; and a release
record exists at `evidence/<tag>.md` and passes `bin/routine-record-lint`.
The record condition SHALL bind the record to its tag — the tag names the
file, so a well-formed record written for a previous release cannot
satisfy the current one — and SHALL be enforced by invoking
`routine-record-lint` and relaying its verdict and output rather than
restating the record grammar, because two implementations of one grammar
can disagree with nothing to catch the disagreement. The gate SHALL
thereby guarantee a release carries a well-formed record and SHALL NOT be
read as deciding whether that record is true: form and destination
existence are mechanical, while whether a lesson is real and whether the
Gate section is honest remain the author's. It SHALL
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
- **WHEN** the tree is clean on `main`, versions agree, selfcheck is
  green, and `evidence/<tag>.md` is a well-formed record
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

#### Scenario: A missing record blocks the release
- **WHEN** every other condition holds and `evidence/<tag>.md` does not
  exist
- **THEN** the gate exits non-zero naming the expected path, because a
  release that can ship without a record has an opinion about records
  rather than a gate

#### Scenario: A malformed record blocks the release
- **WHEN** `evidence/<tag>.md` exists and `routine-record-lint` rejects
  it
- **THEN** the gate exits non-zero and its output carries the lint's own
  violation lines, so the reason names the violated grammar

#### Scenario: The previous release's record does not satisfy this one
- **WHEN** `evidence/v0.1.0.md` is well-formed and the gate is asked for
  `v0.2.0`
- **THEN** the gate exits non-zero, because the tag names the file and a
  stale record is structurally incapable of passing
