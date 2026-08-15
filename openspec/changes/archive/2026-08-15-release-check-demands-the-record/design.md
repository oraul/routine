# Design — release-check-demands-the-record

## The gap is absence, not malformation

Every check routine has around the release record fires only when the
record exists. `routine-record-lint` takes a file argument and exits 2
without one; `routine-selfcheck` iterates `evidence/*.md` and a glob that
matches nothing iterates zero times — correctly, because Law 7 says an
absent optional layer is absent, not failed.

So the record's entire enforcement surface is conditional on the record.
That is not a bug in either script. It is a missing condition in the one
place that knows a release is happening.

## Why the tag names the file

`evidence/<tag>.md`, not `evidence/latest.md` or a marker line inside a
general file. Two reasons, and the second is the load-bearing one:

1. It reads obviously — `evidence/v0.8.0.md` is the v0.8.0 record.
2. **A stale record cannot satisfy a new tag.** If the gate accepted any
   well-formed record, the cheapest way past it would be to leave last
   release's file in place, and the gate would bless it. Naming the file
   after the tag makes the previous record structurally incapable of
   passing the next release.

This mirrors the join key the audit already uses: the developer's TDD
evidence binds to the scenario label verbatim, so a renamed label leaves
a scenario uncovered rather than silently covered by a neighbour.

## Delegation over reimplementation

`routine-release-check` calls `routine-record-lint` and relays its exit,
the way `routine-selfcheck` calls its sibling lints rather than inlining
them. Sibling resolution (`dirname "$0"`), not `routine_root()`, for the
invocation itself — the same idiom selfcheck uses, so a fixture root
needs no copy of the lint.

Two implementations of one grammar can disagree with nothing to catch
the disagreement. The record lint makes exactly this argument about
reusing `lib/caffeine.sh` instead of growing a second resolver; the same
reasoning applies one level up.

## What the gate still cannot decide

Whether the record is *true*. `routine-record-lint` checks form and
destination existence — both sections present, no section silently
empty, every entry evidenced, every named topic resolving to a real
caffeine pair. Whether a lesson is real, whether its evidence supports
it, and whether the Gate section is honest about what got worse are
judgments no script here can make.

The gate therefore guarantees a release carries a *well-formed* record,
never a *good* one. That distinction belongs in the record's own text
rather than in an inflated claim about the gate — the same boundary the
grounding lint draws when it enforces line forms and leaves the claims'
truth to the author.

## Non-Goals, with what would earn each

- **Checking the record against the actual diff since the last tag.** A
  record claiming an improvement no commit made would pass. Earned if a
  record is ever found making a claim the range contradicts — and it
  needs a real notion of "the claim's subject", which nothing here has.
- **Requiring a minimum number of entries.** The `- none — <why>` floor
  already forces an explicit statement rather than silence, and a count
  threshold would buy padding, not honesty.
- **Generating the record.** `routine-evidence` produces `retro.txt`
  from telemetry; a record is a human judgment about a release, and
  generating it would defeat the point of asking for one.
