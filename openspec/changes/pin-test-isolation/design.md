# Design — pin-test-isolation

## Removing a hazard beats detecting it

This change and a seeded shuffle answer the same worry from opposite
ends. A seed detects order dependence after it exists; forbidding shared
state prevents it from existing. Prevention wins here because bats makes
it nearly free: the per-test process boundary already does the work, and
all this rule does is stop someone from opting out of it.

Recorded plainly because the ranking is counter-intuitive for anyone
arriving from RSpec, where the seed is the primary tool and there is no
equivalent prevention to reach for.

## Reads are unrestricted, writes are not

A large part of this suite exists to read the repository:
`agents_content.bats`, `caffeine_content.bats` and
`guidance_content.bats` grep `$ROUTINE_REPO_ROOT` on almost every line,
and the pairing rule added in `pair-negative-assertions` depends on them
continuing to.

So the rule is about writes only — a redirect, `cp`, `mv`, `rm`, `mkdir`,
`sed -i` or `touch` whose target is under `$ROUTINE_REPO_ROOT`. A read
cannot make one test depend on another.

## Why the shared tmpdirs are refused outright rather than restricted

`BATS_SUITE_TMPDIR` and `BATS_FILE_TMPDIR` have legitimate uses — an
expensive fixture built once for a whole file, say. This corpus has no
such case, and admitting one would open the exact channel the rule
exists to close, in exchange for saving milliseconds on a suite that
already runs in under a minute.

If a genuinely expensive shared fixture ever appears, the rule should be
revisited with that case in hand rather than pre-weakened for a case
nobody has.

## Non-Goals, with what would earn each

- **A seeded file-order shuffle.** Detects what this prevents. Earned if
  an order dependence is ever observed despite this rule — which would
  itself be evidence the rule has a hole worth finding.
- **Forbidding reads of `$ROUTINE_REPO_ROOT`.** Would delete the content
  pins, which are load-bearing.
- **Checking that `BATS_TEST_TMPDIR` is actually used.** A test needing
  no scratch space is fine; the rule is about what is shared, not about
  mandating a directory.
- **Parallel execution with `--jobs`.** Would exercise isolation harder,
  and this rule is the precondition for it being safe. Earned when suite
  runtime justifies it.

## The fixture-data exemption, and the hole it leaves

This suite writes fixture corpora containing the very tokens the rule
forbids — that is how it proves the rule fires. Scanned naively, the rule
refuses its own tests.

The discriminator is narrow and principled: a line redirecting into a
`.bats` file is building a corpus for another lint run, so its tokens are
data rather than this test's behaviour. Only `test_lint.bats` does that.

It leaves one false negative on record: a genuine
`printf x > "$BATS_SUITE_TMPDIR/f.bats"` would be skipped. Nothing in
this corpus does that, and narrowing further would cost more complexity
than the hole is worth — but it is a hole, not an oversight, and it is
written here rather than discovered later.
