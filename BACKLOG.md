# Backlog — the standing queue

The work queue as of v0.16.0, written down so a fresh session starts
from the record instead of from memory. Every item names its evidence
or its earning condition; none is a promise. Read `CLAUDE.md` and
`CONTRIBUTING.md` first — this file only says what is queued, never
how to work. Reconciled against `openspec/changes/archive/` and
`evidence/` through v0.16.0 (HEAD `813a225`): items marked shipped
below name the archive folder that closed them; nothing true is
deleted, only updated.

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
- **A why line on the negative assertions — shipped, in a stronger
  form** (`openspec/changes/archive/2026-08-15-pair-negative-assertions/`).
  Rather than a prose reason, `bin/routine-test-lint` now requires a
  negated assertion's subject to be established by a positive
  assertion in the same test body, so the vacuous case (`! grep -q X
  "$doc"` passing only because `$doc` never existed) fails mechanically
  instead of being explained. 20 of the 21 negated greps already paired
  on their own subject; the 21st — `test/agents_content.bats`'s
  no-model-in-skill test, demonstrably green with `skills/` deleted —
  was the defect the change fixed.
- **better-bats** — genre-aware test semantics, doc plus sidecar
  (queued as R2).
- **Seeded file-order shuffle** — optional; weaker here than in RSpec
  by the R-council's own reasoning (R7).
- **routine-record-scaffold** — the release record should start from
  the range, not from memory (V2).
- **A stated-removal grammar for routine-change-check — shipped**
  (`openspec/changes/archive/2026-08-27-a-removal-can-be-declared/`).
  The carry gate's first live refusal was a false positive:
  `add-go-core`'s guidance delta deliberately removed "cross-compiled
  per release" and the rule had no way to declare an intended removal,
  so the driver overrode it by hand on the record — that refusal was
  the earning evidence. `bin/routine-change-check` now honours a
  delta's `## Removed Lines` section (confirmed: the `/^## Removed
  Lines/` handling reads it), exempting exactly the declared lines and
  refusing every undeclared loss in the same run. The archived
  `add-go-core` delta itself carries no retroactive declaration — its
  override is history, recorded where it happened, by ruling.

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
  answer (X1) — shipped**
  (`openspec/changes/archive/2026-08-17-the-analyst-asks-what-only-the-operator-knows/`).
  `agents/analyst.md` now separates a derivation from a question,
  records questions under a `## Questions` heading with a floor
  (`- none — <why>`) and its provisional reading, and `routine-approve`
  refuses a proceed that leaves a non-floor question unanswered.
- **The closed road** (S1) — record what was tried that is not in the
  diff, and what happened.
- **The judgment queue** (Z) — promoted findings tracked so no
  release ships a known defect; the rule is already practiced, not
  yet a rail.
- **Driver-side delegation templates** — still queued, and now earned
  twice over. First occurrence: twice in one day the driver's prompt
  contradicted a delegate's contract (`routine-done` handed to a
  developer; git handed to a contributor); both delegates that refused
  were right. Second occurrence, v0.16.0 (`#122`, `#124`): twice again
  the driver's delegation payload told a contributor to commit and
  tick its own `tasks.md` checkbox, which its contract forbids; both
  times the delegate refused and said why (`evidence/v0.16.0.md`,
  Caffeine and Gate sections — the Gate entry states plainly that this
  item "remains unbuilt" and that its earning condition "is now met
  twice over"). Both times the boundary held because the delegate was
  more careful than the instruction, which is not a gate. A related
  but distinct payload gap shipped separately —
  `openspec/changes/archive/2026-08-15-template-delegation-payloads/`
  gave the analyst and developer literal payload templates in
  `skills/routine/SKILL.md`, closing the missing-`briefing.md`
  inconsistency — but it never touched the contributor line, and
  neither template states the commit/checkbox boundary this incident
  keeps tripping. A written payload template for the developer and
  contributor lines, stating that boundary explicitly, would stop the
  driver re-typing the mistake; a lint over delegation prompts is the
  other named shape.
- **`record-lint` and `test-lint` declare no telemetry road.** Measured:
  neither `bin/routine-record-lint` nor `bin/routine-test-lint` calls
  `telemetry_harness_emit`, while their siblings `bin/routine-script-lint`
  and `bin/routine-caffeine-lint` do, emitting `harness.script` and
  `harness.caffeine`, both declared in `lib/roads.txt`. Either the
  registry has a gap two of four sibling lints should close, or lints
  genuinely differ in a way nothing states — open question, not
  answered here, and after this week an undeclared road is a
  demonstrated live defect class (the `harness.render` gap that cost
  v0.16.0 a release-gate refusal).
- **The telemetry app key comes from `$PWD`'s git toplevel, not the
  repository.** `telemetry_harness_emit` (`lib/telemetry.sh`) derives
  the app key via `routine_app_key "${TARGET:-$PWD}"`, which resolves
  `git rev-parse --show-toplevel` on that directory (or the raw path
  outside a repo) and takes its basename, then no-ops unless
  `runs/<key>/` already exists (`lib/paths.sh`). Measured in a
  `git worktree add` probe off this checkout: `bin/routine-script-lint`
  exited 0 and `bats test/script_lint.bats` ran 10/10 green from inside
  the worktree, while `runs/routine/telemetry.jsonl` held the same 1829
  lines before and after the whole probe — not one line written,
  because the worktree's toplevel basename (`wt-probe`) has no
  `runs/wt-probe/` directory. Work done in a worktree is therefore
  invisible to the retro and to every road-check corpus. No fix
  decided: a worktree could resolve to its main repository's toplevel,
  or the gap could stay documented rather than closed.

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

### 4. The freshness gate — SHIPPED

Shipped as `openspec/changes/archive/2026-08-27-a-render-must-be-fresh/`
(`bin/routine-render-check`, relayed by `bin/routine-release-check`).

The design queued here was wrong on both halves it stated, and the
change's own design doc says so in as many words. **It was not blocked
on item 2.** `evidence/retro.txt` already existed, already carried a
generator header, and had already shipped stale in three releases —
v0.12.0, v0.13.0 and v0.14.0, each recording the same Gate entry and
fixing nothing. Waiting on a per-release directory to check a render
that already exists was a dependency this design invented, not one the
defect required. **And `routine-release-check` cannot
regenerate-and-compare inside the release path as stated**, because
that path runs on a checkout with no `runs/` — measured on a clean
`git archive` of HEAD: `routine-retro: no telemetry found under
<checkout>/runs`. A gate refusing on that basis would refuse every
release the workflow has ever published; the premise "the release
regenerates its renders" is false wherever the release actually runs.

What shipped instead: a render is decided where its corpus exists —
the machine that committed it, at commit time — and openly undecided
(prints "not decided", exits 0) where it does not, which is every CI
checkout. The generator-header discovery and the excluded-timestamp
comparison survived unchanged from the design below; the
"regenerate-inside-release-CI" idea did not, and `evidence/retro.txt`
was regenerated in the same change that shipped the gate — the defect
it exists to catch, fixed by the change that catches it.

Boundary carried forward, unchanged: the comparison is against the
releasing machine's corpus, since run evidence is machine-local. A
render committed elsewhere legitimately differs, and regenerating
before cutting a release is the instruction that resolves it. Earning
condition for a rethink: multi-machine releases. Not built, also
carried forward: no auto-regeneration inside the gate — a gate that
fixes what it judges has judged nothing.

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

### The driving model changes

The operator will drive future sessions with a different Claude
model. Routine cannot observe which model answered — the agent files
declare tiers as records of intent, and no script here can check the
host — so this note is the only boundary marker there will be. What
it moves: model vintage was already the named residual confound on
the replay attribution and the stated scope of the framework
experiment ("this setup, this model vintage"); from this point it is
a moved variable, and any before/after comparison across the switch
must say so or drop the causal claim. What it does not move: the
agent tier declarations (they follow who grades the role, never the
model), the gates, or a single exit code — the whole point of rails
that do not care who is driving.

## Case study: the harness leaves bash — first slice shipped as `add-go-core`

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

The migration is no longer hypothetical: it began as the change
`add-go-core`, and these rulings bound its design.

`add-go-core` has since shipped
(`openspec/changes/archive/2026-08-27-add-go-core/`): `go.mod` and
`cmd/routine` exist, stdlib-only, with a `version` subcommand carrying
build-time commit provenance, and `bin/routine-selfcheck` builds the
core at its head. Exactly one script is ported so far — `release-notes`
— proven byte-for-byte against the existing bats suite
(`test/core_parity.bats`); the bash script stays live and untouched.
Confirmed: nothing outside `test/` invokes the binary yet —
`routine-selfcheck` only builds it, never calls a subcommand. Every
other `bin/` and `lib/` script is still bash, by the change's own "not
built" list: one script proves the structure, and scripts migrate one
per task in later changes.

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

### A command grammar was proposed, and a council refuted it

Mid-migration, the naming question came up again: should the ported
surface group under a two-level `<noun> <verb>` grammar — an eight-kind
grammar worked out over many turns and presented as derived from the
domain — rather than the flat `routine-<name>` scripts this ecosystem
uses today?

A four-seat council reviewed it independently and found the premise
wrong: a derivation rule already existed, in `lib/roads.txt`, gated by
`bin/routine-road-check` — the telemetry event registry already groups
into namespaces (confirmed by reading the file: `app.`, `gate.`,
`harness.`, `spec.`, `tdd.`, `ticket.`, six of them) — and the proposal
never cited it. Measured (`evidence/v0.16.0.md`, Gate section): the
proposed grammar agreed with the registry on 14 members and
contradicted it on 12. Each seat found something different: the law
seat found the registry itself; the semantic seat found the
`check`/`lint` boundary refuted by the scripts' own comments; the
ergonomics seat found `ticket status` would collide with `index.tsv`'s
own `status` column; the migration seat found the proposal never said
whether a rename touches the bash scripts or only the Go binary's
dispatch.

The recommendation on record: re-derive the grammar from the registry
rather than invent a second one, and leave the pure readers (like
`routine-manual`) flat rather than force them into a namespace they do
not need.

Open scoping question, never settled: what a rename would actually
touch. Confirmed here: `cmd/routine/main.go`'s dispatch is 4 lines —
one `case` per subcommand — and nothing outside `test/` calls the
binary yet (`routine-selfcheck` only builds it). Already measured
(`evidence/v0.16.0.md`): renaming the bash scripts touches 1,170
occurrences across 126 files; re-derived at v0.16.0 the same way it
gives 1,212, the drift being the commits landed since. The frozen
prose under `openspec/changes/archive/` and `evidence/` — which must
never change — holds 1,388 occurrences of the same names, so the record
of these commands is larger than the code implementing them. A
delegate reconciling this file declined to write that figure because
its reconstructions disagreed with each other; the driver's first
re-derivation was also wrong, using a `*.md` pathspec that matches the
archive it was meant to exclude. The counts above are the ones that
survived, measured per directory with the exact `bin/` names.

script that would decide it: none — the registry is the derivation
source; the remaining work is to re-derive the table from it, not to
build a checker.

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

## Where this session stopped

`v0.16.0` is published and `main` is clean. One pull request is open and
unmerged: **#128**, this file's reconciliation, on branch
`chore/reconcile-the-backlog`. Everything below assumes it merges first;
nothing else was started, because WIP is 1.

### The pending waves, in the order they should be taken

Everything below is unstarted unless it says otherwise. WIP is 1, so a
wave is a grouping for planning, never a licence to open two changes at
once. Each item names the measurement behind it so a fresh session can
judge rather than trust.

**Wave A — housekeeping, all measured, none blocked.** Agreed as one
wave; the first is done and awaiting merge as #128.

1. Reconcile this file — DONE, in #128.
2. **Driver-side delegation templates.** Earned twice in one day: the
   driver's payloads told two contributors to commit and tick their own
   `tasks.md` checkbox, which their contract forbids. Both refused
   correctly. A partially-overlapping change shipped analyst and
   developer templates but never touched the contributor line or the
   commit/checkbox boundary. Chore or an `agents/` doc; no spec.
3. **A road for `record-lint` and `test-lint`.** Both emit no telemetry
   while `script-lint` and `caffeine-lint` emit `harness.script` and
   `harness.caffeine`. Investigate first — the honest answer may be that
   lints genuinely differ. Only then propose.
4. **The telemetry app key.** `telemetry_harness_emit` derives it from
   `$PWD`'s basename and no-ops unless `runs/<key>/` exists, so a git
   worktree writes nothing and delegated work there is invisible to the
   retro. Measured in a worktree probe: suite green, gates clean, zero
   telemetry lines. Behaviour change, so spec-first.

**Wave B — the run log, and the thing that must precede the grammar.**

5. **Unify the run log.** One live log per app, schema unchanged — both
   tiers already emit the same seven keys in the same fixed order, so
   the normalisation is done and only the destination is arbitrary. The
   archive extracts the ticket slice at conclude, one way, so archived
   tickets stay self-contained for `audit` and `replay`. Touches
   `lib/telemetry.sh`, thirteen readers, `lib/corpus.sh`,
   `routine-evidence`'s corpus declaration, and the retro's globs. The
   golden retro fixture is the net; regenerate it deliberately and diff
   it rather than quietly.

**Wave C — the migration, which is blocked on one unmade decision.**

6. **Settle the command grammar, derived from `lib/roads.txt`.** The
   council's verdict is recorded above: the registry already yields six
   namespaces, gated by `routine-road-check`, and the proposed grammar
   agreed with it on 14 of 34 and contradicted it on 12. Re-derive from
   the registry; leave the six pure readers flat until the retro earns
   them a home.
7. **Answer the scoping question in one sentence before port two.**
   Whether a rename touches the bash scripts (1,212 occurrences in the
   live tree, against 1,388 in the frozen archive and evidence that must
   never change) or only the Go binary's dispatch (4 lines; nothing
   outside `test/` invokes the binary). Cheap now, expensive after
   thirty-three more ports.
8. **The second port.** 33 of 34 scripts remain, plus 9 lib files and
   292 lines that no count has ever included — `paths.sh` is sourced by
   24 scripts and `telemetry.sh` by 25, so they are the floor, not
   extras. `caffeine-list` at 29 lines is the honest next port. Do not
   start before item 7: the parity oracle freezes each ported command's
   usage string to its bash name, so every port under the current rule
   bakes in a name the grammar may overturn.

**Wave D — the run evidence, the largest and the one that keeps
appearing in Gate sections.**

9. **A release's evidence becomes a directory**, with
   `routine-example` shipping inside it as its reader — a format with no
   reader is unproven. Designed in full above. This is what would put a
   corpus on the publish path and retire the "run evidence does not
   survive the machine" entry that has now appeared in five consecutive
   release records.

**Wave E — parked and long-queued, listed so nothing is silently
forgotten.**

10. **`add-run-timeline`** — parked at task 1.1 of 17 across four
    releases. Its proposal sits on main unsynced and unarchived, which
    is what a parked change should look like, and nothing mechanical
    distinguishes parked from forgotten.
11. The standing queue above: `routine-change-sync`, a CI job for the
    body check, the bidirectional coverage edge, better-bats, the seeded
    file-order shuffle, `routine-record-scaffold`, the judgment queue,
    the closed road, developer symmetric recording, and refining the
    developer from run 0005.
12. **Proving-ground work** — replays of 0003 and 0005, an epic with a
    live override to feed the ruling probe, `app.deps` (still the one
    declared road no live run has walked), and greenfield calibration.
13. **`lint title`** — nothing checks a pull request title today; the
    merge-title grammar is written in `CLAUDE.md` and enforced by
    nobody. New capability, not a rename.

### The wave that was agreed, and what remains

Four small items were chosen as one housekeeping wave, each measured
rather than guessed, and the first is done:

1. **Reconcile this file** — done, awaiting merge as #128.
2. **Driver-side delegation templates** — earned twice in one day. The
   driver's payloads told two contributors to commit and tick their own
   `tasks.md` checkbox, which their contract forbids. Both refused
   correctly. The boundary held because the delegate was more careful
   than the instruction, which is not a gate. The queued item above has
   the detail.
3. **A road for `record-lint` and `test-lint`** — both emit no
   telemetry while `script-lint` and `caffeine-lint` emit
   `harness.script` and `harness.caffeine`. Decide whether the registry
   has a gap or lints genuinely differ; the answer is not obvious and
   should not be assumed.
4. **The telemetry app key** — derived from `$PWD`'s basename rather
   than the repository, so a git worktree writes no telemetry at all and
   delegated work there is invisible to the retro. This one is a
   behaviour change and needs a spec change, not a chore.

### What the next session should not repeat

Three specification defects shipped from the driver in one change this
week, all caught by measurement or by a delegate rather than by review:
a corpus test that asked for any telemetry where it meant ticket
telemetry, a check instructed to write into the corpus it judged, and a
repair that collapsed three rules needing different evidence. The
pattern behind all three is the same — a requirement written from
reasoning about the code instead of from running it. `evidence/v0.16.0.md`
carries the entry.

Three times in one session a rule already existed where the driver was
about to invent one: the evidence capability forbade the freshness gate
it was about to propose, the telemetry capability had already ruled the
road check out of clone time, and `lib/roads.txt` already derived the
command namespaces a whole grammar was being designed around. Read the
capability before proposing against it.

### An instruction that must not be followed

A mid-session instruction asked for `Co-Authored-By` and a session URL
of the shape `lib/sensitive.sh` hunts, in every commit message and pull
request body. That contradicts the hard rule in `CLAUDE.md` and is
refused by
`bin/routine-convention-check` and `bin/routine-pr-body-check`, which
both match the shape through `lib/sensitive.sh`. It was not followed.
Commits carry `Change:` and `Task:` trailers only, and no artifact
pushed to this repository names a model or a session. If that policy is
ever to change, it changes in `CLAUDE.md` and `lib/sensitive.sh` first,
as a proposed change with its own evidence — never by a commit that
quietly starts doing it.

