## Why

A developer that dies mid-task leaves its partial work uncommitted in
the target. Nothing tells the resuming session it is there:
`routine-health` never looks at the target, so it reports a clean
"resumable — next: routine-next" over a tree full of a predecessor's
half-finished edits, and the replacement developer is stateless, so it
starts writing a failing test that may already exist.

The guidance written for this case landed on the wrong road. It sits in
the skill's preflight phase — but a resumed run goes phase 0 → health →
develop and never passes preflight, so the one branch that needed it is
the one branch that cannot reach it.

## What Changes

- **Health reports the partial work**: when a task is in_progress and
  `TARGET` is set to a git repository with a dirty worktree, the report
  names it as an interrupted developer's uncommitted work and shows the
  changed paths. The phase and exit code are unchanged — this is
  context for the resume, not a blocker; resuming forward is the normal
  road.
- **The guidance moves to the road that reaches it**: the skill's
  develop phase carries the triage (work forward from the partial work,
  or reset it and resume from the recorded red), and the delegation
  payload tells the re-served developer that the diff in the target is
  its predecessor's.
- **The developer reads it before writing**: on a re-served task, the
  uncommitted diff in `TARGET` is the first thing to read — the test it
  is about to write may already be there.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `health`: the reader sees the target when a task is in flight.
- `operation`: the resume road carries the triage, and the developer
  reads the partial work.

## Impact

- Modified: `bin/routine-health`, `skills/routine/SKILL.md`,
  `agents/developer.md`, `test/health.bats`,
  `test/agents_content.bats`.
