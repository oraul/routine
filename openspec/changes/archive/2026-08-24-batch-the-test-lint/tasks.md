## 1. The lint pays per suite, and a counter proves it

- [x] 1.1 Red→green: a fixture corpus of two suites of thirty clean
      tests runs under a PATH-shim tally, and `routine-test-lint`
      finishes it in at most thirty tool launches — red today (per-test
      judging spends ~900), green once every rule family judges inside
      the per-file awk pass. Every one of the 28 existing tests in
      `test/test_lint.bats` passes unmodified — the behavioural
      contract (messages, ordering, exits) is frozen.

## 2. The suite stops invoking the lint per item

- [x] 2.1 Characterization (green at birth, no TDD evidence): the
      17-opener loop becomes one fixture linted once, asserting every
      opener is named in that single run's output. The token-form half
      of this task was refuted during apply — that test was already
      single-fixture single-run from its birth commit, and the 220 ms
      the proposal attributed to a loop was the old lint's per-test
      cost on one run. Nothing to collapse; the premise is corrected
      in proposal.md and design.md rather than a false box ticked.
