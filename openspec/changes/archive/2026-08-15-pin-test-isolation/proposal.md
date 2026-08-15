# Proposal — pin-test-isolation

## Why

RSpec suites need `--order random --seed N` because examples share a
process: state leaks through `let` memoization, instance variables,
class-level caches and the database, so order dependence is the default
hazard and the seed is the tool for hunting it.

Bats does not work that way. Each test is a separate process with its own
`BATS_TEST_TMPDIR`, and this repository leans on that entirely: 38 suites
use the per-test directory, **none** uses `BATS_SUITE_TMPDIR` or
`BATS_FILE_TMPDIR` — the shared ones — and no test writes into
`$ROUTINE_REPO_ROOT`. Every write lands in a directory that exists for
exactly one test.

That is why two shuffled runs of the whole suite produced zero failures:
there is no channel for one test to affect another. The isolation is real
today and enforced by nothing.

This pins it. A shared tmpdir or a write into the repository would
reintroduce the hazard that seeded ordering exists to detect — and
removing a hazard beats detecting it.

## What Changes

- `bin/routine-test-lint` gains an isolation rule: a suite may not use
  `BATS_SUITE_TMPDIR` or `BATS_FILE_TMPDIR`, and a test may not write
  into `$ROUTINE_REPO_ROOT`.
- Both rules pass the corpus at 0 violations today, so this is a
  regression pin rather than a cleanup.

## Impact

- Affected specs: `selfcheck`
- Affected code: `bin/routine-test-lint`, `test/test_lint.bats`
- Reading the repository stays unrestricted: the content pins in
  `agents_content.bats` and `guidance_content.bats` read `$ROUTINE_REPO_ROOT`
  constantly, and must keep doing so. Only writes are refused.
