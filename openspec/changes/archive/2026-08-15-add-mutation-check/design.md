# Design — add-mutation-check

## A lint proves shape; only mutation proves binding

Every rule added tonight passed the corpus on arrival. That was the
argument for adopting each of them — free, no cleanup, decay prevented.
It is also the ceiling: a rule everything already satisfies cannot find
anything.

The one real defect found in this corpus was not found by a lint. It came
from breaking a path and watching what stayed green. This change makes
that method a script instead of a lucky afternoon.

## One mutation, not a mutation suite

Real mutation testing perturbs operators, boundaries and returns, and
scores what survives. That is the wrong tool here. The question is not
*how thoroughly* does this suite constrain its script — it is *does it
constrain it at all*. A decorative suite fails the crudest possible
mutation, and a single stub answers it in one run per script instead of
dozens.

So the mutation is total: the script's body is replaced with a stub that
exits 0 silently. If the suite still passes, the suite was never reading
the script's behaviour.

The stub keeps the shebang and exits 0 rather than 1. Exiting 1 would
fail suites for the trivial reason that everything errors; exiting 0 is
the harsher test, because a suite that only ever asserts success will
survive it and deserves to be named.

## Restoring is the dangerous part

This is the first script here that modifies `bin/` at all, and a crash
mid-run would leave a gutted script on disk. Restoration therefore does
not depend on reaching the end of the loop: the original is copied aside
first, and a trap on `EXIT INT TERM` puts it back.

Verified restoration matters more than the finding. A check that reports
correctly and leaves the repository broken is worse than no check.

## Why it never joins selfcheck

`routine-selfcheck` runs on every commit and in CI. This runs one bats
suite per script — 27 suite invocations — and would turn a fast gate into
a slow one. Law 1 says the gate decides; a gate people avoid running
decides nothing.

It belongs beside `routine-release-check`: on demand, and before a tag.

## What a green suite against a gutted script means

Not necessarily that the suite is worthless. It may cover a script that
mostly delegates, or assert only on inputs it constructs itself. What it
does mean is that **the suite would not notice if the script stopped
working**, and that is worth a human deciding about.

So the report names the pair — script and suite — and stops. It does not
guess which is at fault.

## Non-Goals, with what would earn each

- **Operator-level mutation or a survival score.** Answering "how well"
  before "at all" is premature; earned once every suite notices a total
  stub.
- **Mutating `lib/` or the caffeine sidecars.** `lib/` has no
  `routine-test:` edge to follow, and sidecars are already covered by
  fixture corpora. Earned when either grows a coverage declaration.
- **Running inside `routine-selfcheck`.** See above; earned if the cost
  ever drops to the ordinary gate's budget.
- **Failing a release automatically on a survivor.** The report needs a
  human first. Earned once the findings are understood and a policy
  exists to encode.
