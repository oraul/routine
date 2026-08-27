# Go migration analysis — `bin/` to a compiled core

- **Status:** analysis, not spec. This document binds nothing. Any Law
  amendment lands only through `/opsx:propose`, validated strict, as the
  first change of the migration.
- **Anchor:** written against the repository state at merge #115
  (`bin/` = 29 scripts, ~3,600 lines; `lib/` = 8 sourced libraries).
- **Instrument:** a full read of `bin/`, `lib/`, `test/`, and
  `openspec/project.md`. Everything below is prediction unless marked
  measured; the evidence that settles each prediction is named in place.

## TL;DR

A Go migration is technically clean and fixes the one place the current
architecture can silently lie (positional `awk -F'"'` parsing of JSON
telemetry in the readers), but it collides with Laws 1 and 5 as written.
Go trades *source-is-the-artifact* simplicity for a compile step and a
release pipeline. The shape that works: one Go module, one multi-call
binary, `internal/` packages mirroring `lib/`, contracts as data instead
of comments, the bats suite kept as the migration safety net, prebuilt
checksummed binaries per release via CI. Migrate the core, never the
seams: app hooks and caffeine sidecars stay bash forever.

## Proposed Law amendment — drafted wording

The invariant behind Law 1 was never bash; it was determinism plus
exit-code semantics. The invariant behind Law 5 was never the
interpreter; it was zero setup in the target project and a seam any user
can edit in place. The amendment re-states both invariants without the
incidental implementation choice, and moves that choice into the seam
boundary where it belongs.

### Law 1 — Determinism boundary (one-phrase edit)

> **Determinism boundary.** Anything that matters — gates, state,
> sequencing, lifecycle — is a deterministic executable with exit-code
> semantics. An instruction to an LLM is never load-bearing.

Only "a bash script" becomes "a deterministic executable". Nothing else
in the law moves.

### Law 5 — replaced in full

> **Compiled core, scripted seams.** The operational core is a single
> statically linked binary: cross-compiled per release, depending on
> nothing but the host kernel, carrying its own commit provenance
> (`routine version` names the commit it was built from). Everything on
> the user's side of the seam — app hooks at
> `runs/<app>/hooks/<gate>.sh` and caffeine sidecars — stays bash 3.2 +
> BSD/GNU coreutils, editable in place without any toolchain. No
> interpreter runtime (Node/Ruby/Python) enters the operational path on
> either side of the seam. OpenSpec (Node) and the Go toolchain are dev
> dependencies of this repository only and never enter the plugin
> runtime.

### Consequential edits (same proposal, not separate changes)

- **Law 2 (TDD from birth):** "Every `bin/` script and every caffeine
  sidecar starts as a failing bats test" becomes "Every core command and
  every caffeine sidecar starts as a failing test: red → green →
  commit. The CLI contract is tested from outside by bats regardless of
  implementation language; core internals may add `go test`." The bats
  suite is retained deliberately: it cannot see the implementation
  language, which is what makes it the migration's independent
  instrument.
- **Stack section:** Runtime = single static binary + bash seams.
  Tests = bats (CLI contract) + `go test` (core internals). Lint =
  shellcheck (seams and hooks) + `gofmt` / `go vet` / `staticcheck`
  (core).
- **Unchanged and still binding:** Law 3 (script-owned state), Law 4
  (seam contract, byte-identical), Law 6 (`ROUTINE_ROOT` everywhere —
  binding on the binary exactly as on the scripts), Laws 7–10.

### What the amendment must preserve, stated as refutable claims

1. Every current caller invocation (`routine-gate developer`,
   `routine-tdd red … -- …`) works byte-identically after migration.
   Instrument: the existing bats suite, green before and after each
   ported script.
2. Zero setup in the target project still holds: install fetches one
   prebuilt checksummed binary; no toolchain touches the user machine.
   Instrument: a fresh-machine install test in CI.
3. Provenance improves, not degrades: the binary names its own commit
   via the toolchain's embedded VCS stamp. Instrument:
   `routine version` output compared against the release tag's commit.

## File organization — the Go way

```
routine/
  go.mod                      # like a Gemfile, but also the module identity
  cmd/routine/main.go         # entrypoint: dispatches subcommands
  internal/                   # compiler-enforced private packages
    telemetry/                # <- lib/telemetry.sh (+ _test.go beside it)
    index/                    # <- lib/index.sh   (TSV single-writer)
    episode/                  # <- lib/episode.sh (revise/fail counters)
    caffeine/                 # <- lib/caffeine.sh
    paths/                    # <- lib/paths.sh   (ROUTINE_ROOT resolution)
    cli/                      # one file per current bin script
  bin/                        # 2-line shims: exec "$dir/routine" gate "$@"
  test/                       # bats suite survives — it tests the contract
```

- 29 bin scripts become 29 subcommands of one multi-call binary (the
  `git`/`kubectl` shape): one build, one artifact, shared code links
  once. `bin/` shims keep every external name byte-identical.
- `internal/` is compiler-enforced privacy: nothing outside the module
  can import it. Script-owned state, enforced by the toolchain.
- No classes needed. Go thinks in packages of functions over small
  structs — the current bash is already that shape.
- Dependencies: stdlib `flag` only, zero external deps. Cobra buys help
  trees and autocomplete this CLI does not need, at the cost of a
  dependency ("boring by design" decides this).

## Frontmatter — from comments to data

The `routine-script:` / `routine-exit:` grammar is a comment contract
that `routine-script-lint` cross-checks against the body. In Go the
contract becomes a value the program itself serves:

```go
var gateSpec = Spec{
    Name:  "gate",
    Usage: "routine gate <preflight|analyst|developer>",
    Env:   []EnvDep{{Var: "ROUTINE_TICKET_DIR", Why: "the active ticket; preflight fails closed without it"}},
    Exits: []ExitCode{
        {0, "gate passed"},
        {1, "gate failed — the output is the reason"},
        {2, "usage — the gate name must be one of the three"},
    },
}
```

`routine describe gate --json` emits it, `--help` renders it, and a unit
test asserts every registered exit code is actually returned somewhere.
The frontmatter moves from testimony (a comment claiming things) to
telemetry (data the binary serves); script-lint becomes a test instead
of a grep.

## Documentation — godoc conventions

- Every exported name gets a comment starting with that name, in full
  sentences. The existing `lib/` comment style ports almost verbatim.
- Package-level rationale lives in a `doc.go` per package.
- `go doc internal/episode ReviseCount` reads docs from the terminal.
- Testable examples: a function named `ExampleReviseCount` with an
  `// Output:` comment is compiled and run by `go test`. Documentation
  that lies fails CI — documentation as executed evidence.

## Coming from Ruby — what changes

| Ruby habit | Go reality |
|---|---|
| Exceptions, `rescue` | No exceptions; every fallible call returns `(value, err)` and the caller checks — the bash `|| return 1` discipline, compiler-nagged |
| Duck typing | Implicit interfaces: any type with the right methods satisfies, no declaration — duck typing the compiler verifies |
| Monkey patching, metaprogramming | Do not exist; nothing modifies anything at a distance |
| RuboCop debates | `gofmt` has zero options |
| RSpec | Table-driven tests with stdlib `testing`; `testscript` (rogpeppe/go-internal) is bats-in-Go for CLI-level tests |
| `nil` surprises | Zero values are usable; only pointers can still be nil |

Ruby optimizes for the writer's expressiveness; Go optimizes for the
reader who did not write it — which is this repository's stated taste.

## Deep modules

A deep module hides a lot behind a small interface so the core can be
replaced without touching callers.

- `internal/telemetry` exports `Emit` / `GateEmit` / `HarnessEmit` /
  `Read`; behind them hide the JSONL key order, escaping, append-only
  discipline, and the ms-clock portability dance. Today that knowledge
  leaks: readers parse telemetry with `awk -F'"'` positional fields
  (`$8`, `$20`, `$23` in `routine-health` and `routine-audit`), so a
  reordered key silently corrupts every reader. Typed structs via
  `encoding/json` are the single highest-value win of the migration.
- Law 9 still governs: start with concrete structs everywhere; extract
  a 1–3 method interface only when a second implementation actually
  exists. Go makes late extraction cheap because interfaces are
  satisfied implicitly — the concrete type never needs editing.

## Compilation and releases

1. `go build ./cmd/routine` produces one static binary — no
   interpreter, no shared libraries; with `CGO_ENABLED=0`, no
   dependencies at all.
2. Binaries are per-OS-per-CPU; cross-compilation is built in
   (`GOOS=darwin GOARCH=arm64 go build` from a Linux CI box).
3. Yes — compile per release: tag → CI (goreleaser) → matrix build
   (linux/darwin × amd64/arm64) → checksummed artifacts on the release.
   `routine-release-check` gains a stage verifying artifacts and
   checksums.
4. Install story: the plugin fetches the prebuilt binary for the host
   and verifies its checksum. Never commit binaries to git; never
   require a user toolchain.
5. Provenance improves: the toolchain embeds the VCS commit in every
   binary (`runtime/debug.ReadBuildInfo`); build with `-trimpath` for
   reproducibility. The binary carries its own anchor.

The real cost: a gap opens between source and behavior. With bash, what
is in the repo is what runs; with Go, what runs is what was built, and
the embedded commit stamp is the answer to "which commit is this
binary?".

## Intervening on a bug

- During development there is effectively no compile step:
  `go run ./cmd/routine gate developer` is cached and sub-second — it
  feels like editing a script and rerunning it. The loop stays
  red → green; shellcheck's job passes to `go vet` + `staticcheck`.
- In the field it changes: a user on a released binary cannot edit the
  fix in. Patch → test → tag → CI builds → user updates. Mitigation:
  releases stay one-tag cheap, and the user-editable surface (hooks,
  sidecars) stays bash, so field intervention at the seam never needs a
  release.
- Debugging: `delve` exists, but this codebase's style — exit codes and
  stderr reasons — needs printf debugging at most.

## AI-friendliness and Routine-friendliness

- The compiler is a new refutation instrument: typos, wrong arities,
  and misused fields are refuted before any test runs, by a meter the
  claimant does not control.
- Explicit imports, no sourcing, no ambient globals: every dependency
  of a file is visible at its top.
- `go build ./... && go vet ./... && go test ./...` verifies the whole
  repository in seconds.
- The bats suite is the migration harness: it tests the CLI from
  outside and cannot see the implementation language. Port one script
  per change; the suite green before and after is the ported claim's
  evidence.

## Recommendation

The pain that justifies Go is narrow and real: positional-awk telemetry
readers, the bash 3.2 + BSD/GNU portability tax paid in every script,
and 400+ lines of bash parsing bash in `routine-test-lint`. The pain it
introduces is the distribution story.

If migrating: compile the core (`gate`, `tdd`, telemetry, index, the
lints); keep hooks and sidecars bash forever. Sequence: (1) the Law
amendment above via `/opsx:propose`; (2) `lib/` packages ported under
the existing bats suite; (3) one bin script per change, `bin/` names as
shims; (4) release pipeline + install hook; (5) retire shims only when
retro evidence says nothing calls the old names.

If not migrating: the cheapest 80% of the value is a bash-only change —
replace the positional-awk telemetry parsing in the readers with a
single shared parser in `lib/telemetry.sh`. That is an ordinary OpenSpec
change and needs no amendment at all.
