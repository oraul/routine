# core Specification (delta)

## ADDED Requirements

### Requirement: The core builds from the checkout and carries its commit
The compiled core SHALL be a single binary built from the repository
checkout with the stdlib-only Go toolchain, and SHALL print, via its
`version` subcommand, the commit provenance injected at build time —
a binary that cannot name the commit that built it is not the core.
`bin/routine-selfcheck` SHALL build the core once at its head and
fail closed when the build fails, so the gate only ever judges a
binary built from the checkout under test. Test suites SHALL build
once per run — in `setup_suite` for bats — and never per test.

#### Scenario: The binary names its commit
- **WHEN** the core is built from a checkout and `routine version` runs
- **THEN** it prints the build-time commit provenance

#### Scenario: A failed build fails the gate
- **WHEN** the core does not compile
- **THEN** `routine-selfcheck` exits non-zero before running any suite

### Requirement: A ported script is proven by parity, not by claim
Every script ported to the core SHALL be proven by a parity test that
runs the existing bats scenarios' commands against both the bash
script and the core subcommand over the same fixtures, and SHALL
require byte-identical stdout and identical exit codes. The bash
implementation SHALL stay live and shipped until a separate change
flips its gateway. New Go-side tests MAY be added and SHALL NOT
replace the parity oracle.

#### Scenario: Parity is byte-for-byte
- **WHEN** the parity test runs a ported script's scenarios against
  both implementations
- **THEN** stdout matches byte-for-byte and exit codes match

#### Scenario: The bash implementation stays shipped
- **WHEN** a script is ported without its gateway change
- **THEN** `bin/` still carries the live bash implementation
