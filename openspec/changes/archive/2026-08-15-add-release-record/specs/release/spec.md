# release Specification (delta)

## ADDED Requirements

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
