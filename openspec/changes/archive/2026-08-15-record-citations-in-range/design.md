# Design — record-citations-in-range

## Why the PR number and not the path

The obvious rule is the wrong one, and measurement is what separates
them.

**Rejected: every path in a `lives in:` line must appear in the range
diff.** It fails in both directions:

- **False positive on a correct entry.** The published v0.8.0 record
  cites `lib/paths.sh` as a destination for the Law 6 lesson.
  `lib/paths.sh` was not touched in `v0.7.0..HEAD` — `routine_root()`
  already lived there. The rule would refuse a true entry, because a
  destination is *where knowledge lives*, not *what changed*.
- **False negative on the actual error.** The bad draft's entry cited
  `bin/routine-mutation-check` (out of range) alongside an archived
  design note added this release (in range). Any "at least one path in
  range" relaxation passes it.

**The PR number works** because it is a claim about provenance rather
than about location. `#86` asserts "this release did that", and whether
a merge is in `v<prev>..HEAD` is exactly decidable.

Measured both ways: all three of the draft's out-of-range citations
(`#73`, `#76`, `#80`) are refused, and all seven of the published
record's (`#82`–`#88`) pass.

## Deriving the range

The record's filename names its tag — `evidence/v0.8.0.md` is v0.8.0's
record, a property #88 already relies on. The previous tag is the
nearest reachable tag before it.

Three cases, and only one is a failure:

1. **A previous tag exists** → check every cited `#NNN` against
   `git log <prev>..HEAD --merges --first-parent`.
2. **No previous tag** (the first release) → the range is all history;
   nothing can be out of it, so the rule is vacuous rather than
   violated.
3. **The file is not named for a tag**, or git is unavailable → skip the
   rule and check the rest. The lint is run by `selfcheck` over every
   `evidence/*.md` and by fixtures with no git history at all; a rule
   that cannot resolve its own precondition must not manufacture a
   failure. This mirrors Law 7's posture toward an absent layer.

Case 3 is the one worth stating in the spec, because a reader will
otherwise assume the rule always fires.

## What the check costs, and what it buys

It reads git history the lint previously never touched. That is a real
widening of the script's dependencies: `routine-record-lint` was pure
text-and-filesystem, and every fixture in `test/record_lint.bats` builds
a directory with no repository.

The mitigation is case 3 — absence of history skips the rule — which
keeps every existing fixture valid without rewriting them, and keeps
the lint usable on a draft record before anything is committed.

## Non-Goals, with what would earn each

- **Pinning evidence to the tree it was measured against.** The second
  fault found this release: a count and a command output that no longer
  reproduce. Real, uncaught, and deliberately not solved here — a
  grammar requiring every number to name a commit is speculation until a
  second occurrence shows which form the evidence actually takes.
  Earned when a record is found whose stale evidence misleads a reader,
  as opposed to one where the claim survives and only the reproduction
  drifted.
- **Checking that a cited PR's subject matches the claim.** Requires
  understanding the claim; no script here can.
- **Rewriting `evidence/v0.8.0.md`.** Out of scope by decision, not by
  oversight: the tag and `main` would disagree about what v0.8.0 said.
