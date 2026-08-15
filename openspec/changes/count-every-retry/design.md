# Design — count-every-retry

## One implementation per budget, because that rule already paid

`lib/episode.sh` states why the revise count lives in one place: the
gate spends it, readers report it, "they can never disagree because
there is one implementation." `routine-health` and `routine-audit`
both read it and cannot drift.

The two new counters go in the same file for the same reason, not
because it is tidy. A budget the gate computes one way and a reader
computes another is a budget that reports a different number depending
on who asks.

## Consecutive, and what resets it

The developer's floor is about grinding the same wall, so the counter
is **consecutive failures since the last passing developer gate for
that task**. A pass resets it: a developer that fails twice, fixes, and
later fails again has not ground three times, and treating it as such
would refuse honest work.

`routine-done` moving the task on is irrelevant — the count is
per-task, so the next task starts at zero without a special case, the
same way `episode_revise_count` handles an absent telemetry file.

## Defect returns are counted per task, not per ticket

A ticket whose tasks each returned once has three healthy signals; a
task returned three times has one sick spec. Counting per ticket would
conflate them and abort a run that is working.

## The honest state of the defect cap

`routine-defect` has fired **zero** times in three proving runs, so
this cap protects a road nothing has walked. Two ways to read that:
the counter is cheap insurance on an untested path, or it is a control
for a problem nobody has.

Recorded as the second, and built anyway, for one reason: the cost of
being wrong is asymmetric. An unnecessary cap costs a refusal message
nobody sees. A missing cap costs an unbounded loop that only a human
noticing wall-clock would stop — and E3 exists precisely to walk that
road, so the counter will be exercised soon rather than never.

## Non-Goals, with what would earn each

- **Configurable limits.** One number, 3, matching the revise budget.
  Earned when a real run shows 3 is wrong for one of them.
- **A gate that counts developer failures across tasks.** Would punish
  a hard ticket for being hard.
- **Telemetry events for exhaustion.** The refusal already emits its
  gate line with a non-zero exit; a second event would be a consumer
  nobody has.
- **Capping blocks or unblocks.** A block waits on a human, and a human
  is not a loop.
