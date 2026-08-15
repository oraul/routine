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

### Requirement: A release record compares this release to the last
A release record SHALL carry exactly two sections, named for routine's two mechanisms: `## Caffeine` — what improved, each entry naming the lesson, the evidence it is real, and where it now lives — and `## Gate` — what the rails do not catch, including what got worse, each entry naming the claim, the evidence, and the script that would decide it. Something that got worse with nothing stopping it SHALL be recorded as a missing gate rather than as a lament. `bin/routine-record-lint <file>` SHALL refuse a record missing either section, a section left silently empty (the `- none — <why nothing qualifies>` floor applies, so a release that improved nothing can say so), an entry carrying no `evidence:` line, and a `## Caffeine` entry whose `topic: <namespace>/<name>` destination resolves to no `caffeine/<namespace>/<name>.{sh,md}` pair — reusing the resolver `routine-spec-lint` applies to task manifests rather than growing a second implementation. It SHALL report every violation in one run naming the file and the rule, and SHALL exit 0 when the record is well-formed, 1 when any rule is violated, and 2 on usage. The lint SHALL decide form and destination existence only: whether a lesson is true, whether its evidence supports it, and whether a section is honest are judgments no script here can make, exactly as the grounding lint enforces line forms while the claims' truth stays the author's.

#### Scenario: A well-formed record passes
- **WHEN** a record carries both sections, every entry has an evidence
  line, and every named topic resolves
- **THEN** `routine-record-lint` exits 0

#### Scenario: A missing section is refused
- **WHEN** a record omits `## Caffeine` or `## Gate`
- **THEN** the lint exits non-zero naming the missing section

#### Scenario: A silently empty section is refused
- **WHEN** a section carries no entry and no `- none — <why>` floor
- **THEN** the lint exits non-zero naming that section

#### Scenario: An entry without evidence is refused
- **WHEN** an entry states a lesson or claim and carries no `evidence:`
  line
- **THEN** the lint exits non-zero naming that entry

#### Scenario: A topic destination that resolves to nothing is refused
- **WHEN** a Caffeine entry names `topic: <ns>/<name>` and no
  `caffeine/<ns>/<name>.{sh,md}` pair exists
- **THEN** the lint exits non-zero, because the record claims knowledge
  was inherited when nothing inherited it

#### Scenario: Every violation surfaces in one run
- **WHEN** a record breaks several rules
- **THEN** the lint reports all of them before exiting non-zero
