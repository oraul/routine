# Design — add-release-record

## Two sections, because routine has two mechanisms

Caffeine is knowledge loaded into future work; a gate is a decision made
by an exit code. Everything routine does is one or the other, so a
finding is one or the other. That is why two is the right number rather
than a compromise — a third section would have to describe something the
system cannot act on, and a finding nobody will act on wants deleting,
not filing.

An earlier draft of this had three tiers, four destinations, promotion
rules and seven checks. It was cut by the human as pollution, correctly:
none of it was earned by evidence, and vocabulary costs every future
reader's attention even though it compiles into nothing.

## The one check that catches a lie

Form checks catch malformed records. Only one clause here catches a
false one: a Caffeine entry claiming `topic: ruby/minitest` fails until
that pair exists. So the record cannot claim knowledge was inherited
when nothing inherited it.

It reuses the resolver `routine-spec-lint` already applies to task
manifests rather than growing a second implementation — the derivation
guard in `test/derivation.bats` exists for exactly this class of
duplication.

## What the lint cannot decide

Whether a lesson is true. Whether the evidence supports it. Whether the
section is honest — a record listing only improvements is exactly the
unfalsifiable artifact this project refuses, and a lint that counts
entries cannot tell an empty Gate section from a dishonest one.

That ceiling is stated rather than papered over, matching
`grounding.md`, whose lint enforces line forms while "the claims' truth
is yours".

## Non-Goals, with what would earn each

- **Requiring the record before a tag.** `routine-release-check` could
  demand it; whether that helps is unknown until one release is written
  under this contract. Earned after a release's practice, refused now as
  the same speculation the earlier draft was cut for.
- **Computing the mechanical deltas.** Real and useful — corpus counts
  per tag, retro deltas, run outcomes — but that is a generator, not a
  validator, and mixing them makes a script that decides nothing
  cleanly.
- **A minimum entry count per section.** A release that genuinely
  improved nothing should be able to say so.
