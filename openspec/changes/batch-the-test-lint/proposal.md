# Proposal — batch-the-test-lint

## Why — the lint pays per test for work that is per file

Every figure below was measured this session, on this machine, against
this corpus; none is recalled or extrapolated.

- `test/test_lint.bats` costs 15,769 ms — about a quarter of the whole
  62 s suite (47 files, 446 tests).
- One test inside it, *the repository's own suite satisfies the lint*,
  is 13,398 ms of that. It is two lines: run `routine-test-lint` over
  the real `test/`.
- The lint itself over that corpus: 13.1 s wall, 12.0 s user.
- `strace -f -c` over that run: **15,046 clone, 6,902 execve** — about
  33 clones and 15 program launches per test.
- Launch cost measured directly: 500 `printf | grep` pipelines take
  839 ms, 1.68 ms each. 6,902 × 1.68 ms ≈ 11.6 s, which matches the
  12.0 s user time. The greps are not working; they are starting.
- The same 500 checks inside one awk process: 3 ms.

The structure explains it. The script already makes one awk pass per
file to *extract* test names and bodies — and then judges them in
shell, where every judgement is a pipeline: two launches per name,
one per body for the expectation token, four per body for isolation,
and for the pairing rule an O(lines²) scan whose inner comparison is
itself five pipelines. The cost of a per-file question is being paid
per test, and it compounds: `routine-selfcheck` runs this lint, and
selfcheck runs on every preflight, whose measured cost has grown
16 s → 95 s across six proving runs while the target stayed at 38
lines.

## What changes

The judging moves into the pass that already reads the file: one awk
program per suite performs every rule — naming, length, duplicates,
expectation tokens, continuation joining, negated-grep detection,
subject extraction (already awk today), pairing, isolation — and emits
the same violation lines the shell emits now. The shell keeps the
walk, the tally and the exits.

**Observable behaviour is frozen.** Same violation message strings,
same per-file ordering, same summary lines, same exit codes 0/1/2,
same usage string. The 28 existing tests in `test/test_lint.bats` pin
that contract and must pass unchanged.

What the spec gains is the cost property those tests cannot see: tool
launches SHALL be bounded per suite file, not per test. Pinned by a
portable counting harness — PATH shims that tally each launch before
handing off to the real tool — because `strace` does not exist on the
macOS CI runner and wall-clock is noise in CI.

## Prediction, labelled as one, with what settles it

Forecast: 13.1 s → under 1 s for the corpus run, launches from 6,902
to under 400 (47 files × a small constant). **This is not a
measurement.** It is settled by re-running the same three instruments
after the change: `strace -f -c` where available, the shim count in
CI, and the wall clock of `bats test/test_lint.bats`. The numbers land
in the PR and the next release record, whichever way they fall.

## Also in scope — the same fault one level up

Two tests in `test_lint.bats` loop over items, invoking the whole lint
per item: *every mechanism opener in the denylist is caught* runs it
17 times (618 ms), *every expectation token form the corpus uses is
accepted* has the same shape (220 ms). Verified before proposing: a
fixture holding four bad openers, linted once, reports all four by
name — the lint already batch-reports, and one of this file's own
tests pins that. Each loop collapses to one fixture and one run
asserting every item appears in the output. Green today and green
after — a characterization of batch reporting, not TDD evidence, and
the tasks say so.

## What was measured and ruled out, so nobody generalises this fix

- `gate.bats` (6,854 ms, #2 by total) has no `setup()`; its cost is
  each test spawning `routine-gate`, a different layer this change
  does not touch.
- `git init` here costs 6 ms at ~10 call sites — the shared-fixture
  hypothesis does not apply to this repository.
- `release_notes.bats` is the worst per-test suite (573 ms × 6) and is
  likewise out of scope.

## Not built, with what would earn it

- **Batching any other lint.** `spec_lint` and `record_lint` are an
  order of magnitude cheaper; earned when one of them heads the
  measured table.
- **A performance budget on selfcheck.** No requirement states one;
  the release record already says it becomes a gate the day a budget
  is stated. This change reduces the cost; it does not invent the
  budget.
