# Design — one-claim-is-always-re-run

## The selection is the mechanism

What makes a spot-check adversarial is not who re-runs it but who
picks it. An author curating a record can survive any number of
re-verifications they choose themselves; they cannot survive a sample
they do not control. So the load-bearing part is mechanical selection
— `cksum` of the file modulo the bullet count — and the re-running
stays human, exactly where the lint boundary leaves every judgment.

Deterministic beats random here: the same bytes always name the same
sample, so a CI re-run and a retro see what the author saw, and the
sample still moves with every edit. Gaming it would mean editing the
file to steer the index — an edit that changes the bytes that choose,
visible in the diff, and the incident that would earn randomness.

## Where the sample rides

Both lints already read the files and already print; the sample is
one more stdout line, never an exit-code change. The spec-lint sample
excludes nothing (every Evidence bullet is a claim); the record-lint
sample excludes the `- none — <why>` floors, which claim nothing
worth re-running. A grounding with no bullets or a record with only
floors names no sample — the empty case is silent, not an error.

## The trust rule keeps its shape

The analyst's anchor-current rule stays: trust every claim, do not
re-open the files, a full re-search is never the road. One clause is
added, not removed — the sampled bullet is always fair to re-verify
and never counts as a re-search. Trust as a default survives; trust
as a prohibition dies.

## Pins

Verified absent at HEAD before writing (measured — the greps ran):
`sampled`, `spot-check` absent from `agents/analyst.md`,
`bin/routine-spec-lint`, `bin/routine-record-lint`, both test files,
and every spec; `never counts` absent from `agents/analyst.md`.
`test/record_lint.bats` asserts output by substring `case` matches,
so the added line breaks no existing assertion (measured — the file's
output checks were read).
