## Why

The road check landed in the release gate one release ago and its first
live run refused the release. Measured on a virgin checkout, the same
command twice in a row:

```
run 1:  routine-road-check: nothing decided — no telemetry ...   exit 0
run 2:                                                           exit 1
```

Nothing changed between them except that run 1 emitted its own
`harness.roads` line. One line makes the corpus non-empty, so run 2
judged a corpus containing only its own footprint and reported 30
declared roads as never walked. In CI the release gate's earlier stage
(`routine-render-check`) emitted first, so the road check was already
poisoned before it ran, and `v0.16.0` could not publish.

Two defects, both in the specification rather than the code:

- **"No telemetry at all" is the wrong test for an absent corpus.** The
  harness tier records the harness's own footprint. Evidence that a
  road was *walked by a run* is ticket telemetry — which is exactly the
  corpus `routine-evidence` already counts and `routine-retro`
  aggregates.
- **A check must not write into the corpus it judges.** The previous
  change deliberately kept `harness.roads` emitting on the undecided
  path, reasoning that the road the check opens should be walked by
  walking it. That reasoning is what made the check undecidable only
  once.

## What Changes

- The undecided test becomes the absence of a **run corpus** — ticket
  telemetry, resolved through `lib/corpus.sh`, the shared definition
  `routine-evidence` already uses — rather than the absence of any
  telemetry.
- On the undecided path the check emits nothing, so running it twice
  gives the same answer twice.
- When a run corpus *is* present the check judges every telemetry line
  under the runs directory exactly as before, harness tier included, so
  an undeclared harness road is still caught.

## What is deliberately not built

- **No change to what counts as walked.** With a corpus present, the
  rules are untouched; only the question "is there a corpus to judge?"
  changes.
- **No suppression of the check's own road elsewhere.** Where the check
  decides, it still records its verdict as `harness.roads` — that
  emission is a verdict about a real corpus, not a footprint standing
  in for one.
