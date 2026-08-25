# Proposal — a-pass-cleans-the-characterize-log

## Why — the interface delivers wrong evidence confidently

Measured in run 0006, not hypothesized: three DONE tasks in the
archive carry a `characterize.log` written by a refused attempt that a
later passing `characterize` never removed — two wrong-cwd
`LoadError`s and one `cd: too many arguments`. Every claim those logs
"document" was eventually proven green; the logs describe slips that
no longer describe anything.

The bite is the chain this repository's own contracts built. The
analyst's re-entry rule reads a returned task's `characterize.log` as
"the verbatim captured failure, not the developer's paraphrase", and
`routine-defect` attaches whatever log it finds to `defect.md`. A task
re-served after a later defect hands the analyst a stale `LoadError`
as if it were the current failure — the #91/#92 interface delivering
wrong evidence with a script's authority, which is worse than
delivering none.

## What changes

A passing `characterize` removes the task's `characterize.log`. The
claim is proven; the refusal history's home is telemetry, which
already carries every exit-1 event. Truncate-per-run between refusals
stays as it is; this adds the mirror: a pass ends the story and takes
the stale page with it.

## Prediction, labelled, with what settles it

The fix is a few lines in the pass path. Settled by the new test: red
against the current `bin/routine-tdd` (refuse once, pass once, log
survives) and green after (log gone). The three archived logs stay —
archives are script-owned history, and `routine-defect` cannot fire on
an archived ticket.

## Not built

- **Cleaning the archive.** Hand-editing script-owned state is the
  hard rule this repository opens with.
- **Removing the log on `red`/`green` passes too.** Only
  `characterize` writes it; only `characterize` owns it.
