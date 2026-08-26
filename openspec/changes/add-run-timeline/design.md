## Context

See proposal.md — Why. Three constraints shape the approach, and none is
negotiable:

- **Law 5 (bash-only runtime).** bash 3.2 + coreutils. No jq, no Node. The
  corpus is JSON, so every reader here parses it with `awk -F'"'` positionally
  against the fixed key order `ts,event,script,ticket,task,exit,ms` that
  `lib/telemetry.sh` guarantees. `lib/episode.sh` already documents that
  convention and its field positions; the timeline inherits it rather than
  inventing a parse.
- **Law 5 again, on the clock.** BSD awk has no `mktime`, which is why
  `bin/routine-retro` carries a hand-written civil-days `epoch()`. Any second
  reader needing elapsed time needs that same function.
- **`test/derivation.bats`.** The guard asserts `function epoch(` appears in
  exactly one `bin/*` file and that the file is `routine-retro`. It exists
  because a fork already happened once. A new reader that needs `epoch()`
  therefore cannot be written without deciding where the shared copy lives —
  the guard converts this from a style question into a blocking one, which is
  the guard working.

## Goals / Non-Goals

**Goals:**

- One row per ticket, in time order, whose numbers are the same numbers the
  retro reports over the same corpus.
- Leave `bin/routine-retro`'s output byte-identical, since `evidence/retro.txt`
  is its committed render and a drift there is a drift in the durable record.
- Come out of the change with the shared-derivation guard stronger than it
  went in.

**Non-Goals:**

- No trend arithmetic — no rolling failure rate, no "improving/regressing"
  verdict, no comparison between windows. The rows carry the facts in order; a
  reader draws the trend. Deriving a trend means picking a window and a
  baseline, and neither is earned by evidence yet (Law 9). What would earn it:
  a retro where a human reads the timeline and states, in the record, the
  comparison they had to do by hand.
- No new telemetry event. The timeline is a reader; it emits nothing, so
  `lib/roads.txt` gains no road and `bin/routine-road-check` is untouched.
- Not added to `evidence/retro.txt` in this change. The evidence capability
  requires that snapshot be the retro's output *verbatim*; adding a second
  body is its own change with its own spec delta.
- No per-task rows. The ticket is the unit of history; a task-level timeline
  is `bin/routine-audit`'s territory and would multiply 25 rows into hundreds.

## Decisions

**D1 — A new script, not a retro section.**
`bin/routine-timeline` rather than a `timeline:` block appended to
`bin/routine-retro`. The retro's contract says it aggregates; the timeline's
says it orders. More concretely: the retro's output is committed to
`evidence/retro.txt` verbatim, so appending to it changes the durable record's
shape as a side effect of adding a view. Separate scripts keep the blast
radius at "a new file" and let the timeline take a `[runs-dir]` argument
without touching the retro's calling contract.
*Alternative considered:* a `--timeline` flag on the retro. Rejected: it makes
one script's output depend on a flag that the evidence renderer must then know
not to pass.

**D2 — Extract the shared derivations to `lib/awk/`, invoked with repeated
`-f`.**
`epoch()` and the failure classifier move to `lib/awk/epoch.awk` and
`lib/awk/classify.awk`. Both readers invoke
`awk -F'"' -f lib/awk/epoch.awk -f lib/awk/classify.awk -f lib/awk/<body>.awk`.
Repeated `-f` is POSIX, and concatenating program files is the only mechanism
awk offers for sharing a function across programs.
*Measured:* `awk -f a.awk -f b.awk` calling a function defined in `a.awk` from
`b.awk` prints the expected result under mawk 1.3.4 on this machine.
*Prediction, not yet measured:* the same holds under macOS's BSD awk (the
platform Law 5 names). The bats suite running on a BSD-awk host settles it;
until it has, this is the change's one unverified portability claim.
*Alternative considered:* keep the program inline and prepend the shared
function with `-f "$lib/epoch.awk" -f /dev/stdin <<'AWK'`. Smaller diff, but it
spends a `/dev/stdin` trick to avoid moving a file — Law 10 says boring, and
the golden test in D4 makes moving the body cheap.
*Alternative considered:* duplicate `epoch()` into the timeline. This is the
defect the guard exists to catch, and it is named here only so the record shows
it was considered and refused.

**D3 — The timeline reads the retro's exact corpus.**
Ticket telemetry only — `<runs-dir>/<app>/tickets/<id>/` and
`<runs-dir>/<app>/tickets/archive/<id>/`. Not "every `telemetry.jsonl` at any
depth", which is `bin/routine-road-check`'s rule and would additionally sweep
`runs/<app>/telemetry.jsonl`, where the harness events (`harness.selfcheck`,
`harness.convention`, …) land. Those lines carry no ticket, so they cannot
form rows; including them would only let the timeline's failure count exceed
the retro's over the same tree, which is exactly the disagreement D2 exists to
prevent. The two readers now differ in what they *print* and never in what
they *read*.

**D4 — The extraction is guarded by a golden output test, shown red first.**
Before `epoch()` moves, `test/retro.bats` gains a test that runs the retro over
a fixture corpus and compares the full output byte for byte against a checked-in
expectation. That test must be green *before* the extraction and green *after*
it. It is the only mechanical proof that a refactor of the evidence renderer
changed no number.

**D5 — The widened guard is proven by planting the fork it must catch.**
`test/derivation.bats` changes from "exactly one `bin/*` defines `epoch()`" to
"exactly one file under `lib/awk/` defines it and no `bin/*` does", plus the
same shape for the classifier. A guard rewritten to match the new layout can
pass vacuously — a wrong grep matches nothing and reports one-of-one. So each
widened assertion is first run against a deliberately planted duplicate and
shown failing, then the duplicate is removed. Red on the planted fork is the
evidence the guard still guards.

## Risks / Trade-offs

- **The retro is the source of committed evidence; refactoring it can silently
  change `evidence/retro.txt`.** → D4's golden test, green before and after the
  move, plus regenerating the snapshot as its own commit so the diff is
  reviewable in isolation rather than mixed into the refactor.
- **BSD awk's handling of repeated `-f` is unverified here.** → Named as a
  prediction in D2 rather than asserted; the suite on a BSD-awk host settles
  it. If it fails, the fallback is D2's rejected alternative
  (`-f shared.awk -f /dev/stdin`), which costs a trick but not the design.
- **A widened guard can pass vacuously and leave the corpus less protected than
  before.** → D5: every widened assertion is shown red against a planted fork
  before it is trusted.
- **Two readers over one corpus can still disagree if they diverge later.** The
  spec binds the timeline to the retro's classification and corpus, but no
  script compares the two totals. → Accepted for now, and named: the earning
  condition for a cross-reader agreement check is the first time they actually
  disagree in a real run. Building it now would be speculation (Law 9).
- **`epoch()` in a shared file becomes public surface.** A third consumer can
  now depend on it without review. → Accepted; that is the point of extracting
  it, and `lib/` files are already covered by shellcheck and the suite.

## Open Questions

- Whether the elapsed column should read seconds or `HhMm`. Presentation only:
  it changes no requirement, no corpus, and no task, and is settled when the
  first row is printed and looked at.
