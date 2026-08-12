# caffeine: testing/tdd
<!-- caffeine-topic: testing/tdd -->
<!-- caffeine-applies: any -->
<!-- caffeine-source: https://martinfowler.com/bliki/TestDrivenDevelopment.html -->
<!-- caffeine-reviewed: 2026-08-12 -->
<!-- caffeine-mode: doc-only -->

Language-agnostic, doc-only: the loop's own discipline. Loaded when your
task's manifest names `testing/tdd`. The target's own test conventions
outrank this guide where they conflict. The mechanical half is
`routine-tdd` — every red and green runs through it, and the audit
replays the evidence.

## The cycle, annotated

```text
routine-tdd red   "order rejects negative quantities" -- <test command>
#   The red must PROVE something: run it and read the failure. A red
#   that fails with NameError proves the class is missing, not that the
#   behavior is absent — write the smallest scaffolding until the
#   failure message states the missing BEHAVIOR, then stop scaffolding.
#   routine-tdd refuses a red that passes: a red that isn't red is a
#   protocol violation, not a warning.

# ... implement the smallest thing that could satisfy the scenario ...

routine-tdd green "order rejects negative quantities" -- <test command>
#   Same scenario string, same command: the pair is the evidence the
#   audit checks. Green with a DIFFERENT test than the red proved
#   nothing — never swap the command between phases.
```

## Judgment

- **One behavior per example.** A failure names exactly one broken
  promise; two assertions proving one behavior is fine, two behaviors in
  one example is not. Size each scenario so one red→green cycle carries
  it — a scenario needing three cycles is three scenarios.
- **Name the behavior, not the incident.** "rejects negative quantities"
  outlives "fixes bug #4521"; the suite is the living spec, and names
  are what it says.
- **Characterization tests are a different instrument.** They pin
  EXISTING behavior before you change a seam and are green at birth by
  design — they run inside the app's own suite, never through
  `routine-tdd red`. Only the new behavior's scenarios show red first
  (see `calibration/feature.md`).
- **The failure message is the audience.** Before green, break the
  implementation mentally and ask whether the red output would tell a
  stranger what promise broke and where.
- **Refactor on green only.** The cycle ends with the test passing and
  the code clean; cleaning while red mixes two kinds of change and hides
  which one broke what.
- **Never delete a red to get to green.** A scenario that turned out
  wrong is a defective spec — that is `routine-defect`'s road, and the
  reason lands in `defect.md`, not in a silent test edit.
