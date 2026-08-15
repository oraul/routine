# Proposal — narrow-output-exemption

## Why

`pair-negative-assertions` exempted negations on `$output` with this
reasoning, recorded in its own design: *"bats always defines it once
`run` has executed, so a negation against it can never be vacuous the way
a file or glob subject can."*

That is wrong, and the error is the same class the rule was built to
catch. `$output` is always **defined**; it is not always **non-empty**.
When the command under test crashes, `run` sets `$output` to the empty
string, and a negated grep over an empty string passes. The test then
reports that the forbidden thing is absent, when what actually happened
is that nothing ran.

Demonstrated with `$output` empty:

```sh
! printf '%s\n' "$output" | awk '/^script failures:/{a=1;next} ... ' \
  | grep -q 'bad password'   # passes
```

The repository holds exactly one such test — `script failures name
scripts, never scenario labels` in `retro.bats`. It would pass if
`routine-retro` exited non-zero and printed nothing.

Three sibling tests in the same file survive a crash, because their
assertions are **positive**: an empty `$output` fails a `case` match and
fails a `grep -n` lookup. Only the negation is fooled, which is precisely
the asymmetry `pair-negative-assertions` exists to police — it was simply
not applied to `$output` itself.

## What Changes

- The `$output` exemption narrows: a negation on `$output` is exempt from
  subject pairing **only when the body also asserts `$status`**. The
  status assertion is what proves the command ran and the output being
  examined is real.
- The one violating test gains its `$status` assertion.
- The design's claim that a negation on `$output` "can never be vacuous"
  is corrected in the spec rather than left standing.

## Impact

- Affected specs: `selfcheck`
- Affected code: `bin/routine-test-lint`, `test/test_lint.bats`,
  `test/retro.bats`
- 5 of the 6 negations on `$output` already assert `$status` and are
  untouched.
