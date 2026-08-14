## Why

A challenger council raised twelve objections to `add-mission-panel`
and every one survived its defender. Three are disqualifying on their
own:

- **It already disagrees with the retro.** The panel copied the
  civil-days `epoch()` out of `bin/routine-retro` verbatim and
  reimplemented the caffeine deepening queue with a different ranking
  mechanism. A defender built a fixture and reproduced the drift: the
  same corpus, two different orderings, with nothing testing them
  against each other. `lib/episode.sh` had been created one day
  earlier to prevent exactly this class of fork.
- **Its spec overstates its script.** `openspec/specs/panel/spec.md`
  normatively requires "event traffic per script" and "in-flight
  versus done counts"; the script renders neither, and the change's
  task list was ticked claiming they do. A merged spec that lies about
  its script is a rails defect.
- **The deferral was never argued.** The founding scope's non-goals
  name dashboards
  (`openspec/changes/archive/2026-08-11-add-conclude-and-retro/design.md`).
  That deferral is earnable — this repo has overturned a §10 non-goal
  before, on evidence — but `add-mission-panel` never made the
  argument, and no run has yet been driven against a real target, so
  the evidence that a human needs to watch one does not exist.

Smaller but real: the errors panel counted deliberate non-zero exits
(`tdd.red`, `spec.defective`) as failures, saturation counted refused
block transitions and could show a phantom permanent block, the file
list was word-split behind a shellcheck suppression, and the refresh
behaviour appeared in no requirement and no test.

The honest move is to take it out, not to patch a thing whose
justification was never written.

## What Changes

- **`bin/routine-panel` and `test/panel.bats` are removed**, and the
  `panel` capability with them.
- **A guard replaces it**: `test/derivation.bats` fails if any second
  script reimplements a derivation the retro owns — the civil-days
  epoch conversion or the caffeine failure ranking. The mistake that
  earned this revert cannot recur silently.

## Capabilities

### Removed Capabilities

- `panel`: the computed page and its signal contract.

### Modified Capabilities

- `retro`: its derivations are named as owned, and duplication is a
  test failure.

## Impact

- Removed: `bin/routine-panel`, `test/panel.bats`,
  `openspec/specs/panel/`.
- Added: `test/derivation.bats`.
