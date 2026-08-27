# Backlog — the standing queue

The work queue as of v0.12.0, written down so a fresh session starts
from the record instead of from memory. Every item names its evidence
or its earning condition; none is a promise. Read `CLAUDE.md` and
`CONTRIBUTING.md` first — this file only says what is queued, never
how to work.

## Queued scripts and gates

- **routine-change-sync** — the delta→spec merge as a script. Today
  the sync is hand-assembled; `routine-change-check` (v0.12.0) can
  only prove containment, not equality. Once the sync is mechanical,
  the carry rule upgrades from a net to a proof — the v0.12.0 record's
  own Gate entry names this as the earning path.
- **A CI job for the body check** — `routine-pr-body-check` decides
  the scrub but only when a hand runs it; the pull-request event
  already carries the body. Named in the v0.12.0 Gate entry
  "The body check runs at the right moment only by discipline."
- **Test frontmatter and the bidirectional coverage edge** — the
  script→test pointer is checked; the reverse direction has a known
  edge (queued as Q4 since the R-council).
- **A why line on the negative assertions** — 21 negated greps carry
  no recorded reason (queued as Q5).
- **better-bats** — genre-aware test semantics, doc plus sidecar
  (queued as R2).
- **Seeded file-order shuffle** — optional; weaker here than in RSpec
  by the R-council's own reasoning (R7).
- **routine-record-scaffold** — the release record should start from
  the range, not from memory (V2).

## Contract refinements with evidence waiting

- **The ruling probe has never met a live override.** The obligation
  (#107) landed with pins, but no epic since 0008 has carried an
  operator override — the next one settles whether the probe catches
  an unbuildable ruling at reconciliation. v0.12.0 Gate entry.
- **Developer symmetric recording** (Z2) — delegate self-reports
  omitted 2 of 3 refused attempts in run 0006; telemetry caught both.
  The analyst got the symmetric-probes obligation; the developer's
  mirror is still queued.
- **Refine the developer from run 0005** (W1) — evidence of a correct
  refusal worth folding into the contract.
- **Separate what the analyst derived from what only the operator can
  answer** (X1) — the heading exists; the sorting rule could be
  sharper.
- **The closed road** (S1) — record what was tried that is not in the
  diff, and what happened.
- **The judgment queue** (Z) — promoted findings tracked so no
  release ships a known defect; the rule is already practiced, not
  yet a rail.
- **Driver-side delegation templates** — twice in one day the driver's
  prompt contradicted a delegate's contract (`routine-done` handed to
  a developer; git handed to a contributor); both delegates that
  refused were right. A written payload template for the developer
  and contributor lines would stop the driver re-typing the mistake.

## Proving-ground work (shopapp)

- **More replays** — 0003 and 0005 carried reachable anchors and
  verbatim requirements, and each run would strengthen or break the
  one-data-point rails-improved attribution from 0002/0007. Both
  prerequisites now live outside this repository: the archived tickets
  were handed to the operator as an archive of `runs/` at v0.13.0
  (9 tickets, 11 telemetry files, 1,132 event lines) when the session
  was cleaned, and the target app's history is
  `evidence/example-history.patch`. Restoring either is a deliberate
  act, so this item is doable but no longer self-serve: it needs the
  archive restored into `runs/` and the app rebuilt from the patch
  first.
- **An epic with a live override** — feeds the ruling-probe evidence
  above.
- **`app.deps`** — the one declared road no live run has ever walked
  (waivered in `lib/roads.txt`).
- **Greenfield calibration** — has never met a run.

## Standing operator rules (recorded rulings, not preferences)

- At every approve checkpoint, present each operator question as
  lettered options with the tag "(recommend this answer)" on the
  recommended one; the ruling stays the operator's.
- Session artifacts (the journey, the pillars, the insights report)
  stay private claude.ai artifacts — never committed here, never
  linked from this repository. A fresh session lists them with the
  artifact gallery.
- Pull request bodies are judged by `bin/routine-pr-body-check` on a
  saved copy before shipping; the platform injects a session URL into
  every footer and the check is what demands the scrub.
- Merge commits, never squash, titled
  `Merge pull request #N: <type>: <change-id> — <outcome>`.

## In flight and designed

One change is parked mid-flight; the rest were designed against
measured state and are queued in dependency order. The decisions
below are the operator's rulings, not options to re-litigate.

### 1. `add-run-timeline` — PARKED at task 1.1 of 17

Parked deliberately, not abandoned. The proposal, its design, and its
task line are on `main` under `openspec/changes/add-run-timeline/`;
task 1.1 is done and merged (the golden fixture that pins the retro's
output byte for byte), and tasks 2.1 onward are untouched. Resuming
means picking up at 2.1 — the extraction of `epoch()` into
`lib/awk/epoch.awk` — with the golden test already standing guard, so
no number can move in silence.

The refinement below was already folded into the task line before
parking, as tasks 6.1 and 6.2:

- `bin/routine-evidence <render>` becomes the single renderer, taking
  a render name (`retro` the default for compatibility, `timeline`
  new), each printing the three-line header that names its generator —
  so one place knows how to make a committable render and a later
  check can rediscover how any render was made.
- `evidence/timeline.txt` is committed as its own commit.

Measured motivation: `evidence/retro.txt` was rendered 2026-08-14 and
reports `gate.developer runs=4 fails=2` where the live corpus reports
`runs=28 fails=3` — a 50% failure rate on record against 11%
measured, shipped through v0.12.0.

### 2. A release's evidence becomes a directory — NOT STARTED

Designed, not proposed. Nothing exists yet: no spec delta, no branch,
no tasks. Starting it means a fresh proposal through the loop.

A release's evidence becomes a folder, not a file. A folder named for
a release is a photograph, so staleness stops being possible by
construction; the single mutable `retro.txt` aged silently precisely
because nothing about one file says which moment it describes.

```
evidence/v0.12.0/
  record.md      the judgment (moves from evidence/v0.12.0.md)
  retro.txt      render, frozen at cut time
  timeline.txt   render, frozen at cut time
  example.patch  the target app's commits produced in this window
  runs/          telemetry per ticket concluded in this window,
                 plus ONE exemplar ticket published in full
```

Rulings:

- **Written once.** Each ticket and each app commit belongs to exactly
  one bundle — the release whose window it fell into. Measured: 9
  tickets across 12 releases; copying the whole corpus per release
  would duplicate 824K twelve times for no new information.
- **The range rule, applied twice.** A record's `#NNN` citations must
  already belong to its range; its run evidence must too. Same law,
  second application, mechanically decidable.
- **Lean plus one exemplar.** Every ticket contributes its
  `telemetry.jsonl` (so every number in the renders is re-derivable by
  a reader instead of trusted); one ticket per release is published in
  full — requirement, grounding, briefings, approve — as the worked
  example a newcomer learns the loop from.
- **The patch is code only.** Verified: the v0.12.0 patch touches
  `lib/order.rb` and `test/order_test.rb` and holds no paperwork path.
  It is `git format-patch` output, so each patch header records the
  original commit sha even though re-applying mints new ones.
- **Ticket ids stay local and may restart from 1.** The release folder
  namespaces them, so no cross-release uniqueness rule is needed and
  no allocation change is required.
- **Replay worktrees are excluded.** They are git checkouts of the
  target app and belong to its repository.
- **Consequence to write into the contract, not discover later.**
  Published telemetry carries TDD scenario labels — prose someone
  wrote — and a published exemplar carries operator answers verbatim.
  The hard rules therefore bind ticket authorship, and the convention
  check will scan the paperwork on every release diff.

Also in this change, because a bundle format with no reader is
unproven:

- `bin/routine-rebuild <vX.Y.Z> [dir]` applies every bundle's
  `example.patch` up to and including the named tag, in version order,
  into a fresh directory. Exit 0 prints the path and commit count; 1
  refuses (no bundle for the tag, target not empty, a patch that no
  longer applies, naming which); 2 usage. Emits `harness.rebuild`.
  The one subtlety worth its own test: `v0.10.0` sorts before
  `v0.9.0` lexically, so ordering is by numeric component.
- The change owes itself the proof by reconstruction: rebuild at the
  newest tag and `diff -r` against the live app. Done by hand this
  session — 9 commits, byte-for-byte identical, suite green at 49
  runs / 194 assertions — which is the experiment the task should
  automate.
- Gate entries to record rather than hide: the rebuild reconstructs
  the app, not the run (the reds live in telemetry, not the patch);
  and it cannot self-verify on a fresh clone, because the app's gate
  hook lives in gitignored `runs/<app>/hooks/`.

### 3. `routine-example <vX.Y.Z> [dir]` — the reader — NOT STARTED

Designed, not proposed, and deliberately not startable on its own: it
reads `evidence/<tag>/example.patch`, which item 2 creates. Building
the reader first would leave it pointing at paths no release writes.
It ships inside item 2's change rather than after it, because a format
with no reader is unproven.

A release's evidence is useless if nothing reads it back, so the
reader ships with the format rather than after it: apply every
`example.patch` up to and including the named tag, in version order,
into a fresh directory. Exit 0 prints the path and commit count; 1
refuses (no evidence for that tag, target not empty, a patch that no
longer applies, naming which); 2 is usage. Emits `harness.example`.
The subtlety worth its own test: `v0.10.0` sorts before `v0.9.0`
lexically, so ordering is by numeric component.

Naming ruling, derived rather than chosen. Law 7 says a name comes
from a rule where one exists and Law 10 forbids lore, which refuses
`unbundle` (a mechanism nobody says aloud) and the whole
snapshot/restore metaphor (a story invented mid-conversation). The
name derives from the artifact it reads — `evidence/<tag>/example.patch`
— and sits in the noun family beside `routine-evidence`,
`routine-timeline`, `routine-manual`. For the same reason the words
"bundle" and "snapshot" are dropped from the design prose: it is a
release's evidence, described plainly.

Proven by hand this session before being specified: four per-release
patches sliced from the app's history rebuilt all nine commits in an
empty repository, byte-for-byte identical to the live app with its
suite green at 49 runs, 194 assertions.

### 4. The freshness gate — NOT STARTED

Designed, not proposed. Blocked on item 2 for the same reason: it
refuses a render the release did not just regenerate, and there is no
per-release directory to check yet.

`routine-release-check` regenerates every render in the bundle being
cut and compares byte for byte, refusing the release naming the render
and the command that refreshes it. Renders are found by their
generator header. The gate judges renders only — a record's truth
stays the author's, as the record rule already states.

Boundary: the comparison is against the releasing machine's corpus,
since run evidence is machine-local. A render committed elsewhere
legitimately differs, and regenerating before cutting a release is the
instruction that resolves it. Earning condition for a rethink:
multi-machine releases.

Not built: no auto-regeneration inside the gate — a gate that fixes
what it judges has judged nothing.

## Decisions on record

### The example app's history was normalized

All nine commits now carry the example app's own identity rather than
the harness's default, so the published patches read as the app's
history instead of the tooling's. Content, messages and author dates
are untouched — verified by rebuilding from the patch and diffing
against the live app, byte-for-byte identical with the suite green.

The rewrite minted new commit hashes, and the archived tickets'
`Grounded-at:` anchors deliberately still name the old ones: an anchor
records what HEAD actually was when the analyst grounded, so rewriting
it to match would falsify the record. The pre-rewrite chain is
therefore pinned by the tag `pre-authorship-rewrite` in the app's
repository, and every archived anchor resolved through it while that
repository lived. That tag was container-local and did not survive the
session being cleaned, which costs nothing that was not already
accepted: the app rebuilt from `evidence/example-history.patch` starts
from the rewritten history, so a restored archived ticket's
`Grounded-at:` names a commit the rebuilt app does not contain. The
anchors stay unedited regardless — an anchor records what HEAD was at
grounding time, and rewriting it to match a later rebuild would
falsify the record. A replay of 0003 or 0005 therefore needs its
anchor mapped by position to the rebuilt chain, recorded in the replay
ticket rather than by editing the archived one.

## Case study: the harness leaves bash — in flight as `add-go-core`

Raised because macOS users hit dialect differences (bash, awk, date,
grep) and because a sibling project's bats suite takes over ten
minutes even in parallel. Everything below was measured in one
session against this repository; nothing here is a plan, and the
first task is not a rewrite.

### What the docs settle

Claude Code hooks and plugin scripts are language-agnostic — "user
defined shell commands, HTTP endpoints, or LLM prompts", any
executable. So nothing about this ecosystem requires bash, and
nothing forbids leaving it. The docs do name a portability gap
sharper than macOS: shell form runs `sh -c` on macOS and Linux, but
on Windows it is Git Bash, or PowerShell when Git Bash is absent, and
exec form there needs a real executable. Windows, not macOS, is where
bash actually blocks a user.

Official Anthropic SDKs exist for Python, TypeScript, Java, Go, Ruby,
C# and PHP — relevant only if routine ever calls the API, which it
does not today.

### What the benchmarks settle

Same derivation in every language — ISO-8601 to epoch seconds, the
one routine implements by hand because BSD awk has no `mktime` — over
1,176 timestamps taken from the live corpus, twenty runs each:

| implementation | per run | launch cost | binary |
| --- | --- | --- | --- |
| awk (today) | 1.9 ms | — | — |
| Rust | 2.0 ms | 1.68 ms | 3.8 M |
| Go | 2.1 ms | 1.68 ms | 2.3 M |
| bun compiled | 26.4 ms | 23.5 ms | 95 M |
| Node interpreted | 33.0 ms | 29.7 ms | — |

Three findings, each of which refuted something believed before it
was measured:

- **A local API or daemon is dead.** Its entire benefit is skipping
  process start, measured at 0.9 ms (bash 2.5 ms, compiled 1.6 ms).
  That is not worth daemon lifecycle, shared state, and the loss of
  the test isolation this repository deliberately pinned.
- **JavaScript would make routine slower than it is now.** A real
  routine script costs 12 ms end to end; Node needs ~30 ms to boot
  before doing any work, and `bun --compile` does not fix it (23.5 ms,
  95 MB) because the runtime still starts inside the binary. For a
  tool made of hundreds of small invocations this is fatal.
- **Compiling is not a speed argument.** awk is the fastest thing on
  the table. Go and Rust tie with it on work and tie with each other
  on launch. The honest reason to compile is portability — it deletes
  the bash 3.2 / BSD awk / BSD date / BSD grep class entirely — and
  single-artifact distribution. Go wins the practical grounds:
  smaller binary, trivial cross-compilation, flat build times.

### Where the ten minutes actually goes

Measured here: 518 tests, 51 files, 50 seconds serial on 4 cores —
about 96 ms per test, no single file dominating, while one real
script call costs 12 ms. The time is the harness forking per test,
not the work. Levers in payoff order: parallelism first (GNU parallel
is not even installed, so `bats --jobs` cannot work yet), then fewer
spawns inside tests — this repository already found 6,902 program
launches in one lint run and fixed it by batching — and only then the
runtime. Compiling alone would buy 2-3x on script execution, not 10x.

### The test framework question

| | runner | parallel | caching |
| --- | --- | --- | --- |
| bats | third-party | needs GNU parallel | none |
| Go | stdlib `testing` | packages by default, `t.Parallel()` | result caching, verified |
| Rust | built into cargo | threads by default | build only |
| Node | `node:test` or vitest/jest | yes | vitest |

Go and Rust ship their runner in the toolchain; Node is the only one
where a framework must be chosen and owned. Go's result caching was
demonstrated live: a second run of an unchanged package printed
`ok tf (cached)` without re-running.

The deeper point is that bats can only write one kind of test — spawn
a process, check its exit code — which is why every case costs a
process forever. In a compiled language most assertions become
in-process package tests, microseconds and cached, leaving a small
end-to-end layer that proves the binary wires them together.

### If a port ever happens

The suite is 15 files of pure content pins (grep over docs and
workflows — mechanical to convert, no subprocess) and 36 files that
exec a script, holding 358 `run` invocations and 432 `grep -q`
assertions.

**Do not convert the tests.** Keep bats running against the bash
implementation and build the new binary to satisfy the identical
observable behaviour, exactly as task 1.1 of `add-run-timeline` pins
the retro's output before the awk moves. Converting implementation
and tests together leaves no oracle: new code checked against new
tests proves nothing. Thin bats down only after parity.

One constraint to decide early, because it touches a capability
rather than a script: `routine-script-lint` and `routine-manual` parse
`# routine-script:`, `# routine-usage:` and `# routine-exit:` comments
out of every file in `bin/`. A compiled binary carries no shell
comments. Either the thin shell wrapper stays and keeps the
frontmatter — the cheapest answer, and the shape the operator already
proposed — or the binary exposes its contract another way and the
lint learns to ask it.

### The experiment that would settle the judgment

The benchmarks above are measured; the claim that one test framework
is more reliable *for an agent* is a judgment about training
distribution, and this repository does not let a judgment stand where
an instrument could decide it.

The instrument already exists. Give a small greenfield app in Go,
Rust and TypeScript the byte-identical requirement — the same move
`routine-replay` makes, except the variable is the target language
rather than the rails — run each through the loop, and let telemetry
grade it: `tdd.red`/`tdd.green` pairs (was there a genuine red, or did
tests pass at birth), `gate.developer` failures per task (where the
attempts were actually spent), `spec.defective` returns, episodes
against the revise budget, and `ms` on every line.

Confounds to name or the result is worthless: order effects (mitigate
by alternating and running each language twice), requirement fit (pick
something deliberately neutral — parse, compute, refuse bad input,
write a file), the analyst's grounding differing per target (report it
apart from the developer's failures), and the honest scope, which is
this setup and this model vintage rather than "Claude and Go".

Six tickets, an afternoon. The output is a table of measured counts
published in the release evidence, which anyone can recompute.

### Rulings added after the case study (operator)

The migration is no longer hypothetical: it begins as the change
`add-go-core`, and these rulings bind its design.

- **Local build, not release artifacts.** Users are developers; the
  binary is built from the checkout with `go build`, so everyone runs
  exactly the code they can read and provenance is `git describe` on
  the commit they are sitting on. No cross-compile matrix to keep
  green, no downloaded binary to trust. This narrows Law 5's
  "cross-compiled per release" wording to "built locally from the
  checkout" and makes the zero-setup claim "zero setup beyond a Go
  toolchain" — a small amendment owed by the migration proposal, not
  hidden in it.
- **Stdlib-only core.** Zero dependencies: `go build` needs no
  network, no module downloads, no supply chain. A dependency is
  earned the way this repository earns abstractions — never
  speculatively.
- **Build once per suite, never per test.** `go test` builds
  incrementally and caches results (verified live: `ok tf (cached)`);
  the bats layer builds the binary once in `setup_suite` and every
  test execs it; `routine-selfcheck` gains the same single build step
  at its head so the gate always judges the binary built from the
  current checkout. First run pays ~5 seconds; unchanged code pays
  nothing.
- **Sidecars become data, hooks stay scripts.** The caffeine sidecars
  are rule lists wearing a shell costume — `check <id> "<claim>"
  '<regex>' <globs>` repeated — so in the compiled world they become
  a data file the core interprets (JSON is the working assumption;
  the one caveat to settle at that change is regex escaping inside
  JSON strings, where a plain line-based format may read better).
  Hooks remain ten-line shell scripts forever: they are the target
  project's own code, edited in place without a toolchain, and `exec`
  plus an exit code is the one interface every machine ships.
- **The earning condition is superseded by ruling.** The case study
  asked for the macOS failure to be reproduced before any port; the
  operator ruled to begin regardless. The reproduction stays queued
  as evidence for the record — it is no longer a blocker.

### Earning condition

Reproduce the macOS failure and write it down first. The suite is
green on `macos-latest` on every pull request, so a rewrite motivated
by an unnamed failure is speculation, and Law 9 says do not build the
abstraction until it is earned. If the failure turns out to be a
missing dependency or bash 3.2 rather than a dialect difference, the
fix is a fix, not a port.

Every toolchain needed to prototype this is already installed in the
session container: Go 1.24.7, Node 22, bun 1.3.11, Python 3.11,
Rust 1.94, gcc, make.
