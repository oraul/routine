# Proposal — record-citations-in-range

## Why

PR #88 listed checking a record against its range as deliberately not
built, with an explicit earning condition:

> earned if a record is ever found making a claim the range contradicts

It fired on the first record written. The v0.8.0 draft credited
`routine-mutation-check`, which shipped in v0.6.0, and the
`## Characterization:` heading, which shipped in v0.7.0 — a third of its
claimed improvements belonged to earlier releases.

`routine-record-lint` returned `ok` on that draft, correctly: it checks
form and destination existence, and neither says anything about whether
a claim belongs to the release being recorded.

The failure mode matters more than the instance. A release record exists
so a human can judge one release against the last. A record silently
absorbing earlier work does not merely contain an error — it inflates
the exact quantity the reader is there to assess, and it does so in the
direction nobody checks.

## What changes

`bin/routine-record-lint` gains one rule: every `#NNN` cited anywhere in
a record SHALL resolve to a merge in that release's range.

The rule needs the previous tag to know the range, so the check applies
only when the record's own tag can be derived and a previous tag exists.
A record whose range cannot be established is not refused — the first
release has no predecessor, and Law 7's posture toward absent layers
applies to absent history too.

## The rule was measured, not chosen

Against the bad draft: `#73`, `#76` and `#80` are all outside
`v0.7.0..HEAD` and all three would have been refused.

Against the published v0.8.0 record: `#82` through `#88`, every one in
range, no false positive.

## What this does not catch, stated plainly

Verifying the published record turned up a **second, distinct fault**
that this rule does not address, and the proposal would be dishonest not
to name it.

Two claims in the published v0.8.0 record are true while their citations
no longer reproduce from the tagged tree:

- one says reverting the Law 6 fix leaves `415 green`; on the released
  tree it leaves 418, because the suite grew by 3 after that entry was
  written
- one cites a `routine-release-check v0.7.0` message that a later
  manifest bump displaced with a different one

Both cite PRs squarely in range, so the rule proposed here passes them.
The fault is an evidence line written against a tree that then moved,
with nothing recording which tree it applied to.

No rule for it is proposed. Inventing grammar to pin every count to a
commit would be speculation, and this repository earns abstractions from
evidence rather than anticipating them. It is recorded as a Gate entry
in the v0.9.0 record instead, where the next occurrence can earn it.

## Impact

- `bin/routine-record-lint` — one new rule, one new failure message
- `openspec/specs/release/spec.md` — the record requirement gains the
  range condition and states what it does not decide
- `evidence/v0.8.0.md` is **not** rewritten. Editing a published record
  would make the tag and `main` disagree about what v0.8.0 said, which
  is worse than a stale count, and both claims are true.
