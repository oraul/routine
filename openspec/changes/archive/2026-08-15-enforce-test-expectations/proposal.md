# Proposal — enforce-test-expectations

## Why

A bats test passes when the last command in its body exits 0. A body that
sets up fixtures and never asserts anything therefore passes forever — it
cannot fail, so it defends no claim. The name promises one and the body
delivers none.

That is the worst failure mode a suite has, because it is invisible: the
test is green, the count goes up, and the guarantee is absent. This
repository's own naming rule makes it sharper — every name here states a
claim, so a test with no assertion is a written claim with nothing behind
it.

All 350 tests already carry a visible assertion. Like the naming rule
this pins a convention while it is unbroken, adding no cleanup.

## What Changes

- `bin/routine-test-lint` gains a second rule: every `@test` body carries
  at least one visible expectation — a `[`/`[[` condition, a `status` or
  `output` check, a `grep`/`diff` comparison, a `refute`/`assert` helper,
  or an explicit negation.
- The lint reports the two rule families distinctly, so a failure says
  whether a name or a body is at fault.

## Impact

- Affected specs: `selfcheck`
- Affected code: `bin/routine-test-lint`, `test/test_lint.bats`
- No existing test is edited. A rule requiring an edit would be evidence
  the rule is wrong for this corpus.
