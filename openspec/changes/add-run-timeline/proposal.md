## Why

`runs/` holds 1114 telemetry lines across 11 files spanning 2026-08-11 to
2026-08-26, and nothing reads them in time order. `routine-health` reads one
living ticket, `routine-audit` judges one finished ticket, and
`routine-retro` collapses every ticket that ever ran into one column of
all-time totals. So the corpus can answer "how often does the developer gate
fail" (28 runs, 3 failures) and cannot answer "is it failing less than it
used to" — the question every retro, council, and release record actually
asks before deciding what to build next.

The absence is not cosmetic. `evidence/retro.txt`, the committed render the
repository offers reviewers in place of the gitignored corpus, was taken at
2026-08-14T08:15:52Z and reports `gate.developer runs=4 fails=2`; the live
corpus reports `runs=28 fails=3`. A reader who trusts the snapshot reads a
failure rate of 0.50 where the measured rate is 0.11. An aggregate with no
time axis cannot show that it went stale, because it looks exactly the same
whether it covers one day or fifteen.

## What Changes

- Add `bin/routine-timeline`, a pure reader that prints one row per ticket
  in chronological order across every app: when it started, its outcome, the
  tasks it closed, the specify episodes it spent, its failures, and its
  elapsed time. Reading top to bottom is reading the project's history.
- Extract the two derivations the timeline shares with the retro — the
  ISO-8601-to-epoch conversion and the per-event failure classification —
  into `lib/awk/`, sourced by both through `awk -f`, so one number keeps one
  implementation while gaining a second consumer.
- Widen `test/derivation.bats` to guard the shared location instead of the
  retro's private copy, and to cover the failure classifier, which is
  forkable today and guarded by nothing.

## Capabilities

### New Capabilities
- `timeline`: the chronological reader over the whole run corpus — one row
  per ticket in time order, outcome and cost derived from script-owned state
  alone, writing nothing.

### Modified Capabilities
- `retro`: the single-implementation rule currently names `bin/routine-retro`
  as the one home of the shared derivations. With a second consumer, the home
  becomes `lib/awk/` and the rule extends to the failure classification, which
  the requirement describes in prose today but binds to no location.

## Impact

- New: `bin/routine-timeline`, `test/timeline.bats`, `lib/awk/epoch.awk`,
  `lib/awk/classify.awk`.
- Modified: `bin/routine-retro` (sources the extracted derivations instead of
  carrying them inline; its output is unchanged byte for byte),
  `test/derivation.bats` (guards the new home), `openspec/specs/retro/spec.md`.
- Unchanged: every telemetry line, every gate, every exit code already in
  service. The timeline emits no telemetry and opens no new road, so
  `lib/roads.txt` and `bin/routine-road-check` are untouched.
- `evidence/retro.txt` keeps rendering the retro alone; the timeline is not
  added to the committed snapshot in this change.
