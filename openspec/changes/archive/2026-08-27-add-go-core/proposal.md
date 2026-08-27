## Why

The amended Laws 1 and 5 sanction a compiled core but nothing exists:
no module, no binary, no proof that a ported script can match its
bash original. The riskiest unknowns are structural, not per-script —
can the build live inside the harness without breaking zero-setup for
target users, and can parity be proven mechanically rather than
claimed? Those two questions are answered cheapest on the smallest
possible slice, before any load-bearing script moves.

The slice is chosen by measurement, not preference:
`routine-release-notes` is 38 lines, sources no lib, calls no other
script, and carries six bats tests that become its parity oracle
unchanged.

## What Changes

- A Go module (`go.mod`, stdlib-only by ruling) with one binary,
  `cmd/routine`, exposing subcommands; its first is `version`,
  printing the commit provenance stamped at build time — the
  provenance Law 5 requires the binary to carry.
- `bin/routine-selfcheck` builds the core once at its head, so the
  gate always judges the binary built from the current checkout; the
  repository's own development now requires a Go toolchain, target
  projects still require nothing.
- `routine-release-notes` ported as the `release-notes` subcommand,
  proven by parity: the existing bats scenarios run against the
  binary and must hold byte-for-byte. The bash script stays live and
  untouched — flipping any gateway to the binary is a later change,
  earned only after local-build distribution exists.

## What is deliberately not built

- No gateway flips: every `bin/` script keeps its bash implementation.
- No second script ported: one slice proves the structure; scripts
  migrate one per task in later changes, each behind its own parity
  test.
- No distribution: how a target project obtains the binary (build on
  install) is its own change, and until it lands the bash
  implementations remain the shipped runtime.
- No sidecar-as-data work: recorded in the backlog with its format
  question open.

## Capabilities

### New Capabilities

- `core`: the compiled core — its build, its provenance, and the
  parity rule every ported script must satisfy.
