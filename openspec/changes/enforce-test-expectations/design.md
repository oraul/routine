# Design — enforce-test-expectations

## Detecting an expectation without parsing bash

The rule is deliberately a token scan, not an analysis. A body counts as
asserting when it contains any of: a `[ ` or `[[` condition, the words
`status` or `output` (bats' own result handles), a `grep` or `diff`
comparison, an `assert`/`refute` helper, `-eq`/`-ne`, or a leading `!`
negation.

A scan admits false negatives — a body could assert in a way this list
does not name — and the answer is to widen the list when that happens,
never to start parsing bash. The alternative is a lint whose own
correctness needs a lint.

Measured against the corpus: 350 of 350 bodies match at least one token,
so the list is not merely plausible, it is complete for everything this
repository has written so far.

## The heredoc trap, already paid for once

The naming rule's suite hit this: a fixture written with a heredoc puts a
literal `@test "..."` at column 0, and the lint reads the fixture as if
it were a real test. `script_lint.bats` had already solved it with
`printf`, and `test_lint.bats` follows.

The same trap applies here in reverse — a body that *quotes* an
assertion inside a heredoc fixture would be counted as asserting. That is
acceptable: such a body is building a corpus for another lint, which is
itself the assertion-bearing work, and every real case in this repository
also asserts on the result afterwards.

## Two rule families, reported apart

A name failure and a body failure are different repairs: one rewrites a
sentence, the other adds an expectation. The lint already prints file,
test and rule; this change keeps the rule text explicit about which
family failed so the message tells you what to do rather than only what
is wrong.

## Non-Goals, with what would earn each

- **One expectation per test.** The betterspecs rule this came from.
  Deliberately not adopted: this corpus routinely asserts an exit code
  and then the output that explains it, and splitting those would double
  the fixture cost for no added guarantee. Earned if a test is ever found
  whose multiple expectations hide which one failed.
- **Parsing bash to find assertions.** See above; a lint needing a lint
  is not an improvement.
- **Counting assertions, or a minimum above one.** Nothing to learn from
  the number; the guarantee is that there is any.
- **Checking that an assertion is reachable.** Genuinely valuable and
  genuinely undecidable from a token scan; earned only with a real
  parser, which the first non-goal already refuses.
