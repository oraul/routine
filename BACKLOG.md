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
