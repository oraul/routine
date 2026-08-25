# release Specification (delta)

## MODIFIED Requirements

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
