# Design — enforce-test-naming

## Rules calibrated from the corpus, not invented

Every threshold here was measured before it was written, and the
measurement is the justification:

| Rule | Corpus today | Headroom |
|---|---|---|
| no mechanism opener | 0 of 336 violate | none needed |
| ≥ 3 words | shortest is 3 | at the floor |
| ≤ 100 characters | longest is 83 | 17 chars |
| unique within a suite | no suite repeats a name | none needed |

A lint whose thresholds come from somewhere else would either fail on
arrival or permit what it claims to forbid. The word floor sits exactly
at the observed minimum because "clean target passes" is a fine name and
anything shorter is a label.

The character cap is the one rule with slack, and it is deliberate: the
cap exists to stop a name from absorbing provenance, not to police
phrasing. A name approaching 100 characters is trying to explain *why*
the claim holds, and that belongs in a comment beside the assertion.

## Uniqueness is per suite, because bats is per suite

Two names repeat across the corpus — "all violations are reported in one
run" appears in both `audit.bats` and `script_lint.bats`, and "clean
target passes" in two caffeine suites. Those are not collisions: the same
claim legitimately holds of two different subjects, and each suite runs
and reports independently. Within a single file a repeat would make a
failing line ambiguous, and no suite has one. So the rule is scoped to
the file, and the cross-file repeats stay.

## The denylist matches an opener plus a space

The first draft matched word-boundary openers and immediately produced a
false positive: `testing/tdd teaches the loop's own discipline` is a
caffeine topic path, not the word "testing". Requiring a literal
following space fixes it, and it also keeps the pattern free of `\b`,
which BSD grep does not support — the portability constraint this
repository already lives under.

That false positive is the argument for calibrating against the corpus
rather than reasoning about what a bad name looks like.

## What a lint cannot do here

It cannot tell whether a name is *obvious* — only whether it is shaped
like a claim. "the widget frobnicates correctly" would pass every rule
above and still say nothing. Obviousness stays human judgment, exactly
like the truth of a grounding claim, which the spec lint also checks the
form of and never the content.

What the mechanical rules buy is that the shape cannot rot silently. The
naming discipline stops depending on whoever writes test 337 having read
tests 1 through 336.

## Non-Goals, with what would earn each

- **A `# why:` line on negative assertions.** Real, and next — the 21
  `! grep` assertions defend against specific prior wordings whose
  provenance lives nowhere. Kept out of this change because it requires
  recovering intent from archived proposals, and mixing "passes 336/336
  today" with "needs 21 retrofits" would hide which half is free.
- **Frontmatter on test files.** The bidirectional edge against
  `routine-test:` deserves its own change; this one adds no fields.
- **Enforcing name quality beyond shape.** Not implementable; see above.
- **Renaming any existing test.** A rule that required one would be
  evidence the rule is wrong for this corpus.
