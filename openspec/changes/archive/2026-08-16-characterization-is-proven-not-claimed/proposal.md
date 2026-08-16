# Proposal — characterization-is-proven-not-claimed

## Why — one claim is validated, its mirror is not

`routine-tdd red` refuses a scenario that passes: *a red that isn't red
is a protocol violation, not a warning*. The analyst's claim "this
scenario can go red" is checked by a script, every time.

The opposite claim has no such check. When the analyst writes
`## Characterization: <label>`, it asserts the scenario is **green at
birth**. Nothing validates that. A false characterization simply makes
the suite red somewhere, and it is left to whoever notices to work out
that the spec was wrong rather than the code.

Proving run 0005 is the evidence. Task 01-02's characterization —
*removing the last remaining item leaves the order empty with a zero
total* — was false: `total_cents` raises on an empty list. The developer
found it by running the scenario by hand before writing anything, and
routed it to `routine-defect`. That worked, and it worked because that
developer thought to check first. Nothing required it to.

## Why the return arrives thin

The return road exists and run 0005 proved it end to end. What it
carries is the problem.

`routine-tdd` records exit codes to telemetry and **persists no output**;
the failing text dies in the developer's terminal. `routine-defect`
writes a timestamp and the reason string, nothing more. So the exact
failure survives only if the developer happens to retype it — in run
0005 the developer paraphrased (*"raises ArgumentError: order has no
items"*) rather than pasting what actually printed.

And the developer's own state — what it had implemented, and why it
coded it that way — does not travel at all. The re-entering analyst in
run 0005 recovered it by reading the worktree, and found a second defect
doing so (an unknown name raising `TypeError`, not the silent no-op the
task's prose claimed). That was diligence, not interface. The next
analyst may not.

## What changes

1. **A birth claim is proven.** `routine-tdd` gains a third phase,
   `characterize`, mirroring `red`: it requires the command to **pass**
   and refuses when it fails. A characterization that is red is a
   defective spec — the analyst's claim, not the developer's problem.
2. **The exact failure is captured, not retyped.** When
   `characterize` refuses, the command's real output is persisted where
   the analyst will read it, verbatim.
3. **The return carries the developer's context.** The defect record
   gains what was implemented and why, alongside the captured failure,
   so the analyst patches from the developer's actual state rather than
   re-deriving it.
4. **One clause folded in from the stolen-red finding**: implement the
   narrowest thing that greens the scenario in hand; a later scenario
   passing at birth means too much was taken earlier, not that a
   characterization was found.

## The developer redoing the task cannot currently see the patch

The *road* back to the developer exists — the analyst amends,
`routine-next` re-serves, a fresh stateless developer picks it up. Run
0005 exercised it and 01-02 went green. No road needs building.

What the developer receives on that road is the problem, and it is a
hole rather than a thin spot:

- **`defect.md` is not in the developer's closed context list.** The
  file appears once in `agents/developer.md`, in the Refusals section,
  where the developer *writes* it. A developer redoing a returned task
  may therefore write the account of why it came back and may not read
  one.
- **The re-served rule covers the wrong case.** It addresses "one an
  interrupted session left in_progress" and prescribes reading the
  target's uncommitted diff. A defect return is the opposite situation:
  no partial work, because the predecessor refused — and *amended text*,
  which the rule never mentions.
- **The reconciliation is written where the developer cannot read it.**
  The analyst records `- <task-id> — <what the defect invalidated>` in
  `grounding.md`, and the lint enforces it. `grounding.md` is not in the
  developer's closed list.

In run 0005 the redoing developer knew all of this only because the
driver's delegation payload said so by hand. That is the driver
compensating for an interface, which is the same fault E1 and E4 fixed
elsewhere.

## Honest scoping of item 4

The stolen red is not a hole. Had the developer recorded that scenario's
red, `routine-tdd red` would have refused it (exit 1); had it skipped the
scenario, the audit refuses that too — *an uncovered labeled scenario is
a violation*. The label lives in `task.md`, which the developer does not
write, so it cannot be relabelled away either.

It costs a wasted cycle, not a false green. It rides along because it
touches the same paragraph of the same contract, and building it
separately would mean editing `agents/developer.md` twice.

## Impact

- `bin/routine-tdd` — a third phase, output capture on refusal
- `bin/routine-defect` — the record carries the developer's context
- `agents/developer.md`, `agents/analyst.md` — the new phase and what
  the return carries
- `openspec/specs/tdd/spec.md`, `openspec/specs/operation/spec.md`
- `skills/routine/SKILL.md` — the revise payload names the captured
  failure

## Not built, with what would earn it

- **A script judging whether the developer's stated context is
  adequate.** Whether an explanation is useful is not decidable here,
  exactly as the record lint decides form and never truth.
- **Fingerprinting a stolen red across scenarios.** `routine-tdd`
  records the command hash but not which test failed. Speculation on one
  self-caught occurrence.
