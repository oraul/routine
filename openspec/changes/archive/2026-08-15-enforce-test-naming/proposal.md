# Proposal — enforce-test-naming

## Why

A test name is the only part of a suite most readers ever read. Here it
carries the claim the test defends: "green without a prior red for the
scenario is a violation" tells you what is true, while a name like
"test audit green" would tell you only what ran.

That discipline is currently perfect and entirely unenforced. All 336
tests state a claim; none opens with a mechanism word. Nothing prevents
the 337th from being "should work". A convention held only by attention
is the shape this repository has already been bitten by twice this week —
PR body headings drifted for four consecutive PRs, and the guidance docs
were spec'd with no test reading them.

The moment to pin a convention is while it is unbroken. Every rule below
passes 336/336 today, so this change adds no cleanup and no exceptions
list — it is a regression pin, nothing more.

## What Changes

- `bin/routine-test-lint`: every `@test` name states a claim.
  - No mechanism-flavored opener (`test `, `check `, `verify `,
    `should `, `it `, `ensure `, `does `, `works `, `handles `,
    `correctly `, and their plurals).
  - At least three words — a name shorter than that is a label.
  - At most 100 characters — beyond that it is provenance, which belongs
    in a comment, not in the name a failure prints.
  - Unique within its own suite, since a repeated name makes a failing
    line ambiguous.
- `bin/routine-selfcheck` runs it, so CI enforces it on every push.
- The lint declares its contract in the frontmatter grammar
  `routine-script-lint` already enforces.

## Impact

- Affected specs: `selfcheck`
- Affected code: `bin/routine-test-lint` (new), `bin/routine-selfcheck`,
  `test/test_lint.bats` (new)
- No existing test is renamed. If any rule required a rename, that rule
  would be wrong for this corpus and would not ship.
