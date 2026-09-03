# Go migration analysis — `bin/` to a compiled core

- **Status:** analysis, not spec. This document binds nothing on its
  own; every rule it discusses is binding only because it is already in
  `openspec/project.md`, not because it is repeated here.
- **Anchor:** every number below is measured against this worktree
  directly — the command is named next to the number. No merge number,
  commit hash, or session identifier is used as the anchor; a reader who
  wants a fresher count re-runs the named command.
- **Correction notice:** this document supersedes an earlier draft that
  treated the migration as a future proposal. It is not: the archived
  change `openspec/changes/archive/2026-08-27-add-go-core/` already
  shipped a first slice, and Laws 1 and 5 already carry the amended
  text. Every claim below was re-measured against the live tree rather
  than carried over from that draft; several of the draft's central
  predictions turned out to already be settled, and settled
  differently than the draft assumed. Where that happened it is called
  out explicitly rather than quietly corrected.

## What already exists — measured

- `go.mod` and `cmd/routine/` exist at the repository root.
  Measured: `cat go.mod` → `module routine`, `go 1.24.7`.
- `cmd/routine/` holds two files, `main.go` (41 lines) and
  `releasenotes.go` (117 lines). Measured: `wc -l cmd/routine/*.go`.
- The binary exposes exactly two subcommands: `version` (prints the
  build-time commit provenance; has no bash original) and
  `release-notes` (a port of `bin/routine-release-notes`). Measured:
  reading `cmd/routine/main.go`'s `run()` dispatch, a two-case switch.
- `bin/` holds 34 scripts today, so exactly **one of 34** is ported.
  Measured: `ls bin | wc -l` → 34; `bin/routine-release-notes` is still
  a full 38-line bash script, not a shim — measured by reading it: it
  still contains the whole `git log --merges` implementation, not an
  `exec` to the binary.
- Parity is proven, not asserted: `test/core_parity.bats` builds the
  binary once per file and runs the same fixture history that
  `test/release_notes.bats` uses against both implementations, diffing
  stdout and exit codes. Measured: reading `test/core_parity.bats` and
  `test/release_notes.bats`.
- `bin/routine-selfcheck` builds the core once at its head
  (`go build -ldflags "-X main.commit=$built_commit" -o "$build_dir/routine" ./cmd/routine`)
  and fails closed if the build fails, but never execs a subcommand —
  the binary is discarded (`rm -rf "$build_dir"`) on every path out of
  that stage. Measured: reading `bin/routine-selfcheck` lines 30–52,
  and `grep -rn "cmd/routine" bin lib skills agents` returning only the
  `routine-selfcheck` build line — no other script invokes the binary.
  So the compiled core is not yet on the operational path anywhere
  except the test suite and the selfcheck gate that builds (never
  runs) it.
- A target project's root has no `go.mod`; `routine-selfcheck` treats
  that as the zero-setup case, not a failure, and skips the build
  stage entirely. Measured: reading the same block — the `if [ -f
  "$root/go.mod" ]` guard and its `else` branch.

## Laws 1 and 5 — already amended, not proposed

The prior draft framed a Law 1 rewording and a full Law 5 replacement
as something to propose via `/opsx:propose`. Both have already
happened. Diffed word-for-word against `openspec/project.md` as it
reads in this worktree (line-wrap only differs; wording does not):

**Law 1, current text:**

> **Determinism boundary.** Anything that matters — gates, state,
> sequencing, lifecycle — is a deterministic executable with exit-code
> semantics. An instruction to an LLM is never load-bearing.

This is the exact wording the earlier draft proposed for Law 1 — the
"bash script" → "deterministic executable" edit is already live.
Instrument: `diff` between the draft's proposed paragraph and
`openspec/project.md`'s Law 1, normalized for line-wrap, is empty.

**Law 5, current text:**

> **Zero-setup core, scripted seams.** The operational core runs with
> zero setup in the target project beyond the Go toolchain that builds
> it. Today that core is bash 3.2 + BSD/GNU coreutils scripts — no
> associative arrays, no `mapfile`, no jq; its sanctioned destination is
> a single statically linked binary, built locally from the checkout so
> every user runs code they can read, carrying its own commit
> provenance. The seam stays scripts forever: app hooks at
> `runs/<app>/hooks/<gate>.sh` and caffeine sidecars are bash 3.2 +
> BSD/GNU coreutils, editable in place without a toolchain. No
> interpreter runtime (Node/Ruby/Python) enters the operational path on
> either side of the seam. OpenSpec (Node) is a dev dependency of this
> repo only and never enters the plugin runtime. A file's side of the
> seam is decided by where it lives, never by which language it happens
> to be written in today: everything under `bin/` and `lib/` is core
> and destined for the binary. The seam is exactly the app hooks at
> `runs/<app>/hooks/<gate>.sh` and the caffeine sidecars. A core script
> written in bash today records how far the migration has got, never a
> claim about which side of the seam it sits on, since both sides are
> bash scripts and language identifies neither.

This is **not** what the earlier draft proposed, and the difference is
substantive, not cosmetic:

- The draft proposed distribution by release artifact: "cross-compiled
  per release, depending on nothing but the host kernel" — install
  fetches a prebuilt checksummed binary, no toolchain touches the user
  machine. The Law that actually landed says the opposite: **"built
  locally from the checkout so every user runs code they can read"**,
  and zero-setup is qualified as "beyond the Go toolchain that builds
  it" — the toolchain is not confined to this repository's own
  development the way the draft assumed for OpenSpec. This is a ruling
  already on record, not an open question this document can settle by
  argument.
- The draft's file organization section still describes a future
  `internal/` package tree and `bin/` shims (`exec "$dir/routine" gate
  "$@"`). That structure does not exist yet — measured: no `internal/`
  directory exists in this worktree (`find . -maxdepth 1 -iname
  internal` finds nothing), and `bin/routine-release-notes` is a full
  script, not a shim. It remains a reasonable prediction for later
  slices; it is not a description of the current tree.
- Law 5 explicitly rules that seam-vs-core is decided by **location**
  (`bin/` and `lib/` are core; `runs/<app>/hooks/` and the caffeine
  sidecars are seam), never by which language a file happens to be
  written in today. This sentence exists because the distinction was
  already gotten wrong once on record, against a different bash script
  in this same core (`routine-render-check`, called out in
  `evidence/v0.15.0.md` and `evidence/v0.16.0.md` as misclassified
  under the seam rule when it is core, just not yet ported). This
  document does not repeat that shape of claim: nothing here says any
  `bin/` or `lib/` script "stays bash forever" — only the app hooks and
  the caffeine sidecars carry that claim, and only because Law 5 makes
  it explicitly, not because of the language they are written in.

## The rest of the tree, measured

- `lib/` holds 9 `.sh` files (`approve.sh`, `caffeine.sh`, `corpus.sh`,
  `episode.sh`, `index.sh`, `paths.sh`, `sensitive.sh`, `sidecar.sh`,
  `telemetry.sh`) totalling 292 lines, plus one non-shell data file,
  `roads.txt`. Measured: `ls lib/*.sh | wc -l` → 9; `wc -l lib/*.sh` →
  292 total; `ls lib` → 10 entries including `roads.txt`.
- `bin/` totals 3,839 lines across its 34 scripts. Measured: `wc -l
  bin/*` (verified by an independent per-file sum, since `wc -l bin/*
  bin/routine-release-notes` double-counts if a name is repeated in the
  argument list — a mistake made once while drafting this document and
  caught by the same re-sum).
- `bin/routine-test-lint` is 416 lines. Measured: `wc -l
  bin/routine-test-lint`.
- Bin-name references (`routine-<name>` tokens) in the repository's
  markdown: 556 hits across 50 files outside
  `openspec/changes/archive/`, versus 1,332 hits across 328 files
  inside it. Measured: `grep -roE 'routine-[a-z][a-z-]*' --include=
  '*.md'`, split on the archive path. This is relevant to any future
  shim/rename step: the live-doc count a rename would need to track is
  roughly a sixth the size of the frozen archived record, which never
  changes and will describe old names indefinitely.

## The positional-awk claim — the strongest technical argument, confirmed

The draft's central technical argument survives re-measurement: two
readers parse telemetry positionally rather than by key.

- `bin/routine-health` line 81 and `bin/routine-audit` lines 34, 65,
  107 and 133 all call `awk -F'"'` against `telemetry.jsonl` and pull
  fields by position.
- `lib/episode.sh` lines 33 and 50 do the same.
- The specific field numbers the draft cited are present: measured via
  `grep -n 'print \$[0-9]*\|== "\$[0-9]"' bin/routine-health
  bin/routine-audit lib/episode.sh | grep -oE '\$[0-9]+' | sort -u`,
  which returns `$1 $4 $8 $12 $20 $23` — `$8`, `$20`, and `$23` are
  exactly the fields the draft named.
- `bin/routine-audit`'s own header comment names the confound
  correctly: "the fixed telemetry key order … is a spec guarantee, so
  grep patterns over adjacent keys are reliable" — which is true today
  and is exactly the kind of guarantee a `encoding/json`-typed reader
  would not need to depend on. This remains the single highest-value
  argument for a compiled core's `internal/telemetry` package, whether
  or not the rest of the migration proceeds.

## Migration status and what remains open

- One script ported (`release-notes`), proven by parity against the
  existing bats suite, no gateway flipped: `bin/routine-release-notes`
  is still the version every caller runs. This matches the archived
  change's own "what is deliberately not built" list, read directly:
  no second port, no distribution mechanism, no sidecar format
  decided.
- **Prediction, not yet settled:** whether a target project ever needs
  a Go toolchain, and if so how "built locally from the checkout"
  reconciles with "zero setup in the target project." Instrument: the
  distribution change the archived proposal explicitly defers ("how a
  target project obtains the binary … is its own change") — this
  reads as settled only when that change lands and a fresh-machine
  install test in CI exercises it.
- **Prediction, not yet settled:** how the caffeine sidecars' `check
  <id> "<claim>" '<regex>' <globs>` grammar becomes data the core can
  read without losing the plain-text editability Law 5 requires for
  the seam. No format has been chosen in this tree as of this
  measurement.
- **Prediction, not yet settled:** which `bin/` script is ported next,
  and whether `bin/` scripts become 2-line `exec` shims or are removed
  once nothing calls them. Instrument: the next archived change under
  `openspec/changes/archive/` that touches `cmd/routine/`, read the
  same way this document read `2026-08-27-add-go-core/`.

## File organization, frontmatter as data, deep modules, and the Ruby/Go comparison

The draft's remaining sections — the target `internal/` package layout
mirroring `lib/`, moving the `routine-script:`/`routine-exit:`
frontmatter grammar from a comment convention to a served data
structure, godoc conventions, the Ruby-habit-to-Go-reality table, and
the deep-modules argument for `internal/telemetry` — describe no fact
about the current tree and are not re-measurable one way or the other;
they are architectural predictions about a codebase that, per the
measurements above, is one subcommand into its migration. They are
retained as predictions, not facts:

- **Prediction:** 34 `bin/` scripts eventually become subcommands of
  one multi-call binary with `bin/` shims keeping every external name
  byte-identical. Instrument: each future port's parity test, the same
  mechanism `test/core_parity.bats` already established for
  `release-notes`.
- **Prediction:** the frontmatter grammar (`routine-script:`,
  `routine-exit:`, …) becomes a served `Spec` value rather than a
  comment `routine-script-lint` greps for. Instrument: a change that
  ports `routine-script-lint` itself and replaces its grep-based checks
  with a unit test over the served value.
- **Background, not a claim about this repository:** the Ruby-to-Go
  habit table and the deep-modules framing describe the Go language in
  general; they carry no number about this tree and are included only
  as orientation for whoever picks up the next port.

## Recommendation

The migration is already following the sequence a prior recommendation
argued for, independently of this document: one Law change first
(already landed), then one script proven by parity under the existing
bats suite (already landed for `release-notes`), with no gateway
flipped and no second port rushed. The remaining, still-open decisions
are the distribution mechanism for target projects and the sidecar
data format — both already named as deferred by the archived change
itself, and both are ordinary future OpenSpec changes, not amendments,
since Laws 1 and 5 already say what they need to say. Continuing at one
port per change, each proven by the same parity-against-existing-suite
method, remains the lowest-risk path; nothing measured here argues for
a faster pace or a different one.
