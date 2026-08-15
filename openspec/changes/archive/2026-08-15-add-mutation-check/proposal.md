# Proposal — add-mutation-check

## Why

Every rule this repository has added to `routine-test-lint` proves a test
is *well-formed*: it names a claim, it carries an expectation, its
negations are paired. None of them proves a test would **notice**.

A suite can satisfy every rule and still be decorative. Its assertions
can be shaped correctly and never bind to the behaviour they name, and
nothing in a static scan can tell the difference — the tautology limit
and the token-scan limit are both already recorded as unfixable without a
parser, and even a parser would not answer this question.

The question is answered by breaking the code: **if the script were
gutted, would its suite go red?** A suite that stays green while the
script it covers is emptied is testing nothing, and that is precisely a
spec that supposedly works but never works.

This is cheap here only because of an edge built for another reason.
`routine-script-lint` already requires every script in `bin/` to declare
`routine-test:` naming its covering suite, and already fails a dead
pointer. Those 27 declarations turn an open-ended research problem into a
27-iteration loop.

## What Changes

- `bin/routine-mutation-check`: for each script in `bin/`, replace its
  body with a stub, run the suite that script declares, and require that
  suite to **fail**. Restore the script, always, including on interrupt.
- A suite that stays green against a gutted script is reported as an
  untested script, naming both.
- The check reports a summary — how many scripts were mutated, how many
  suites noticed — and exits non-zero when any suite did not.
- It runs on demand and before a release, never inside `routine-selfcheck`:
  it runs a suite per script and would make the ordinary gate unusably
  slow.

## Impact

- Affected specs: `selfcheck`
- Affected code: `bin/routine-mutation-check` (new),
  `test/mutation_check.bats` (new)
- Expect real findings. Any script whose suite does not notice is
  evidence to act on, not a number to explain away.
