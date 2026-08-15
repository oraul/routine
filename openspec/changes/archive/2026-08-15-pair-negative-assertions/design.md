# Design — pair-negative-assertions

## What the rules so far could and could not catch

The naming rule and the body rule both passed the corpus 100% on
arrival, which was the argument for adopting them: they cost nothing and
prevent decay. That is also their ceiling. A rule everything already
satisfies cannot find anything.

The one real defect found in this corpus was not found by a lint. It was
found by an experiment — breaking a path and watching what stayed green.
That is the difference between a linter, which proves a test is
well-formed, and a harness, which proves a test would notice.

This change is the first rule that starts red on real code.

## Same subject, not merely some positive

A weaker rule — "a test containing a negative must contain some positive"
— would pass this corpus too, since the violating test contains no
positive at all. It is the wrong rule anyway: a negative on `$doc`
beside a positive on `$other` is exactly as vacuous as a negative alone.
The pairing that means something is on the subject the negative names.

So the check extracts the subject from the negative line — the quoted
path, variable, or glob it greps — and requires a non-negated assertion
in the same body mentioning that same subject.

## The exemption, and why it is narrow

`$output` is exempt. After `run`, bats always defines it; a negative
against `$output` cannot pass for want of a subject, and every such test
in this corpus also asserts `$status`. Six of the 21 negatives are of
this kind.

The exemption is written as a subject test, not as a filename or suite
exclusion, so it stays true if those tests move.

## What this still cannot catch

A paired positive proves the subject exists. It does not prove the
negative is meaningful: `[ -f "$doc" ]` beside
`! grep -q 'nonexistent-string-nobody-would-write' "$doc"` passes and
guarantees nothing. That is the same class as the tautology limit
recorded in `enforce-test-expectations` — a scan sees shape, not intent.

The rule that would catch it is mutation: change the subject so the
forbidden thing IS present, and require the test to go red. That is a
harness, not a lint, and it is recorded as the next step rather than
attempted here.

## Non-Goals, with what would earn each

- **Mutation testing of negative assertions.** The real answer, and the
  reason this design names its own ceiling. Its own change: it needs to
  write to a subject and restore it, which no lint should do.
- **Banning negative assertions.** They pin council findings that
  specific harmful wordings never return; the corpus would be poorer
  without them.
- **Requiring a `# why:` line on every negative.** Still queued
  separately. Provenance and vacuity are different problems and a reader
  should not have to satisfy one to fix the other.
- **Extending the subject check to `run` commands.** A negative on a
  command's exit is not vacuous in this way; the command either ran or
  the test errored.
