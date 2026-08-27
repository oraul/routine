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
A release record SHALL carry exactly two sections, named for routine's two mechanisms: `## Caffeine` — what improved, each entry naming the lesson, the evidence it is real, and where it now lives — and `## Gate` — what the rails do not catch, including what got worse, each entry naming the claim, the evidence, and the script that would decide it. Something that got worse with nothing stopping it SHALL be recorded as a missing gate rather than as a lament. `bin/routine-record-lint <file>` SHALL refuse a record missing either section, a section left silently empty (the `- none — <why nothing qualifies>` floor applies, so a release that improved nothing can say so), an entry carrying no `evidence:` line, and a `## Caffeine` entry whose `topic: <namespace>/<name>` destination resolves to no `caffeine/<namespace>/<name>.{sh,md}` pair — reusing the resolver `routine-spec-lint` applies to task manifests rather than growing a second implementation. It SHALL additionally refuse a record citing a pull request number that is not a merge in the release's own range, because a record silently absorbing an earlier release's work inflates the exact quantity its reader is there to judge; the range SHALL derive from the record's filename tag and the previous tag, and the rule SHALL be skipped rather than violated when that range cannot be established — no previous tag, a filename naming no tag, or no git history — so a draft record and a fixture without a repository stay lintable. It SHALL report every violation in one run naming the file and the rule, and SHALL exit 0 when the record is well-formed, 1 when any rule is violated, and 2 on usage. The lint SHALL decide form, destination existence and citation provenance only: whether a lesson is true, whether its evidence supports it, whether a section is honest, and whether a cited measurement still reproduces from the tagged tree are judgments no script here makes, exactly as the grounding lint enforces line forms while the claims' truth stays the author's. On a record carrying at least one non-floor entry it SHALL likewise name one sampled entry — from `## Caffeine` and `## Gate` together, the `- none — <why>` floors exempt — as the spot-check whose evidence is re-run before publishing, selected deterministically from the record's own bytes and reported without gating, because a curated record survives only where nothing is ever re-run and the author must never pick which claim gets checked.

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

#### Scenario: A citation from an earlier release is refused
- **WHEN** a record for `v0.8.0` cites a pull request that merged before
  `v0.7.0`
- **THEN** the lint exits non-zero naming the entry and the number,
  because the record claims an earlier release's work as this one's

#### Scenario: A record whose citations are all in range passes
- **WHEN** every pull request a record cites merged inside its own range
- **THEN** the citation rule adds no violation

#### Scenario: An underivable range skips rather than fails
- **WHEN** the record's tag has no previous tag, the filename names no
  tag, or there is no git history to read
- **THEN** the citation rule is skipped and the remaining rules still
  decide the record

#### Scenario: A record's spot-check sample is named without gating
- **WHEN** the lint runs over a record carrying at least one non-floor
  entry
- **THEN** it names exactly one entry as the sampled spot-check to
  re-run before publishing, and the exit code is unchanged

### Requirement: A committed render must agree with the corpus it claims
A render committed to this repository — a file declaring its origin in
a `# generated by <command> at <timestamp>` header — SHALL agree with
what that same generator produces from the machine's current corpus,
and `bin/routine-render-check [file...]` SHALL decide it: renders are
found by their header rather than by name, the declared generator is
re-run and its output compared to the committed bytes with the
generator's own timestamp line excluded — it differs by construction
and would otherwise refuse everything — and a disagreement SHALL exit
non-zero naming both the render and the command that refreshes it. A
generator the header names that is not a repo-local `bin/routine-*`
script SHALL be refused rather than executed, because a file that can
name any command is a file that can run any command. The check SHALL
NOT regenerate what it judges, since a gate that repairs its subject
has judged nothing. `bin/routine-release-check` SHALL invoke it and
relay its verdict and output rather than restating the comparison, for
the same reason it relays `routine-record-lint`: two implementations of
one rule can disagree with nothing to catch the disagreement.

#### Scenario: A stale render refuses the release
- **WHEN** a committed render's body differs from what its declared
  generator produces now
- **THEN** the check exits non-zero naming the render and its refresh
  command, and `routine-release-check` fails carrying that output

#### Scenario: A fresh render passes
- **WHEN** a committed render matches its generator's current output
  apart from the generation timestamp
- **THEN** the check exits 0

#### Scenario: A foreign generator is refused, not run
- **WHEN** a render's header names a command that is not a repo-local
  `bin/routine-*` script
- **THEN** the check exits non-zero without executing it

### Requirement: A render whose corpus is absent is undecided, not blessed
A generator SHALL declare, in the header of what it renders, the corpus
that render derives from — and SHALL declare it absent when there is
nothing to render from. Run evidence is machine-local and gitignored,
so a clean checkout can regenerate nothing, and `routine-release-check`
runs in CI on exactly such a checkout. Where regeneration declares an
absent corpus, the check SHALL print that it could not decide, naming
the render, and SHALL exit 0 without asserting freshness: refusing
would block every published release, and passing silently would report
a judgment it never made. The declaration SHALL be read from the
regenerated output rather than from the committed render, because the
question is whether this machine has a corpus now, not whether some
machine had one when the render was made. Freshness SHALL therefore be
guaranteed only for a release cut on a machine holding the corpus,
which is the machine where a stale render is committed in the first
place.

#### Scenario: A corpus-less checkout decides nothing
- **WHEN** the check regenerates a render and that regeneration
  declares an absent corpus
- **THEN** it prints that the render was not decided and exits 0

#### Scenario: The undecided case is visible, not silent
- **WHEN** the check cannot decide a render
- **THEN** its output names that render, so a reader of the release log
  can see which renders were judged and which were not

### Requirement: The release gate judges the road registry
`bin/routine-release-check` SHALL invoke `bin/routine-road-check` and
relay its verdict and output rather than restating the road rules, for
the same reason it relays `routine-record-lint` and
`routine-render-check`: two implementations of one rule can disagree
with nothing to catch the disagreement. A reported road violation SHALL
refuse the release. Where the releasing machine holds no corpus the
relayed check decides nothing and the release SHALL NOT be blocked by
it, so the guarantee binds a release cut on a machine holding the run
evidence — which is the machine where an undeclared road is walked in
the first place.

#### Scenario: A road violation blocks the release
- **WHEN** a telemetry line carries an event absent from `lib/roads.txt`
  and the release gate runs on that machine
- **THEN** the gate exits non-zero carrying the road check's own output

#### Scenario: A corpus-less release is not blocked by the road check
- **WHEN** the release gate runs where the runs directory holds no
  telemetry
- **THEN** the road check reports that it decided nothing and the gate
  is not refused on its account
