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

- **More replays** — 0003 and 0005 have reachable anchors and
  verbatim requirements; each run strengthens or breaks the
  one-data-point rails-improved attribution from 0002/0007.
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

## Designed in session, not yet proposed

Three changes were designed against measured state and are queued in
this order — each depends on the one before it. The decisions below
are the operator's rulings, not options to re-litigate.

### 1. Finish `add-run-timeline` (already proposed, branch exists)

Proposed at `change/add-run-timeline`, 14 tasks unstarted. Refine it
with two additions before applying:

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
repository, and every archived anchor still resolves through it.
Deleting that tag would make the queued replays of tickets 0003 and
0005 impossible — the earning condition for re-anchoring is a decision
to abandon those replays, not convenience.

### 2. The evidence bundle — `evidence/<tag>/`

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

### 3. The freshness gate

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
