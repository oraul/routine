## 1. The binary exists and knows its commit

- [ ] 1.1 Red→green: `go.mod` (stdlib-only) and `cmd/routine` build a
      binary whose `version` subcommand prints the build-time commit
      provenance; a new `test/core.bats` builds once in `setup_suite`
      and asserts the output shape — red first on the missing module —
      `test/core.bats`
- [ ] 1.2 Red→green: `bin/routine-selfcheck` builds the core at its
      head and fails closed when the build fails; its bats coverage
      pins the build step — `test/selfcheck.bats`

## 2. The first script proves parity

- [ ] 2.1 Red→green: `routine release-notes <tag>` reproduces
      `bin/routine-release-notes` byte-for-byte across the existing
      scenarios; the parity test runs both against the same fixture
      repo and diffs their stdout and exit codes — red first with the
      subcommand absent — `test/core_parity.bats`

## 3. The law says local build, honestly

- [ ] 3.1 Red→green: Law 5's destination clause becomes "built locally
      from the checkout" with the setup claim narrowed to "zero setup
      beyond the Go toolchain that builds it" — amended in
      `openspec/project.md`, pinned by new words in
      `test/guidance_content.bats` verified absent first
