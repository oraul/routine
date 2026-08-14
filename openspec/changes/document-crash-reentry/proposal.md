## Why

Resuming a run whose developer died mid-task already works — but only
by construction, provable solely by reading the scripts. Three
behaviours were verified in the code for this change:
`routine-next` re-serves the interrupted task (it selects the first
row that is not done, in_progress included, and re-flips nothing);
the audit's red→green pairing keys on the recorded scenario string and
takes the *earliest* failing red, so a re-run's second red→green pair
is tolerated — provided the command is identical, since the recorded
string carries the command hash; and a second `routine-approve` is
harmless (presence-checked, notes appended, never truncated).

None of that is written down. A resuming session must either
rediscover it by reading bash, or — worse — assume the safe-looking
move is to start over. And the one genuinely rough edge has no
guidance at all: a developer that died mid-task leaves the target
dirty, which the preflight gate then refuses.

## What Changes

- **`skills/routine/SKILL.md` phase 4** gains a re-entry paragraph:
  a resumed develop phase re-enters at `routine-next` (never at
  preflight), which hands back the same task; when the interrupted
  task already has a passing developer gate, `routine-done` is the
  move — the evidence is on record.
- **Phase 1** names the dirty-target triage: a preflight failing on a
  dirty target while a task is in_progress is an interrupted develop,
  not a broken run, and the two sanctioned roads are committing the
  partial work or resetting it to resume from the recorded red.
- **`agents/developer.md`** gains the resume rule: on re-serve,
  re-record red and green with the **identical** scenario label and
  the identical command — a rename or a changed command records an
  unpaired green the audit will refuse.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `operation`: the skill and the developer contract cover re-entry.

## Impact

- Modified: `skills/routine/SKILL.md`, `agents/developer.md`,
  `test/agents_content.bats`.
