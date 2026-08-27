## Context

Laws 1 and 5 (amended in #116) sanction a compiled core; the backlog
carries the operator's rulings: local build from the checkout,
stdlib-only, build once per suite, hooks stay scripts. This change is
the smallest slice that makes those rulings testable.

## Decisions

- **One binary, subcommands** — Law 5 says "a single statically
  linked binary"; `cmd/routine` with subcommands is that, and a
  per-script binary farm is rejected.
- **Parity by the existing suite, not new tests** — the bats
  scenarios for `release-notes` already state the contract; the
  parity test runs the same scenarios against `routine release-notes`
  and diffs against the bash script's output byte-for-byte. New
  Go-side unit tests are welcome additions, never substitutes: the
  oracle is the suite that watched the bash version being born.
- **The build lives in setup, never per test** — `setup_suite` builds
  into the bats tempdir; selfcheck builds at its head. Go's build
  cache makes an unchanged rebuild a no-op, measured at effectively
  zero against the first build's ~5 seconds.
- **Provenance via -ldflags** — `git describe --always --dirty`
  injected at build time; `routine version` prints it. A binary that
  cannot say which commit built it fails Law 5's provenance clause.
- **CI needs no new job** — GitHub runners ship Go; the existing test
  jobs inherit the build step through selfcheck.

## Risks

- The repository's dev loop gains a hard Go dependency. Accepted by
  ruling; CI runners and this container already carry it.
- Byte-for-byte parity includes error messages and usage strings —
  the port must reproduce them exactly, which is the point.
