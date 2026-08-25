# Proposal — the-replay-lands-on-a-branch

## Why — the first live replay was refused by the loop's own gate

`routine-replay` created its worktree with `--detach`, and
`routine-gate preflight` refuses a detached HEAD — so the first live
replay (archived 0002 → ticket 0007) stopped at the first gate and the
worktree had to be branched by hand before the run could start
(measured — the refusal line and the manual `git switch -c` are in the
session record, and the run then concluded clean). Two rules
individually reasonable, jointly broken on first contact: the same
class of failure the archived 0002 died of, caught one gate earlier.
The operator's rule stands: no release ships a known defect.

The same run also went where the C2 grammar said it would: the
`ticket.replay` waiver went stale the moment the road was walked, and
the live road-check now exits 1 demanding the drop (measured — the
refusal line quoted in the session).

## What changes

- `routine-replay` creates the worktree on a branch —
  `replay/<archived-id>-<sha8>` at the anchor commit — instead of
  detached, so the preflight passes without hand-work. The held-still
  guarantee is unchanged: the branch points at the anchor, and the
  test asserts HEAD equals the anchor as before.
- The stale `ticket.replay` waiver is dropped from `lib/roads.txt`:
  the road has been walked (ticket 0007's telemetry carries the line),
  so the waiver's why is now false.
- The `tickets` spec's replay requirement changes one line (detached →
  replay-named branch) and gains the preflight scenario.

## Not built, with what would earn it

- **Branch cleanup on worktree removal.** A removed worktree leaves
  its `replay/*` branch in the target; a re-replay of the same
  archived ticket then refuses at branch creation with git's own
  message. Earned by the first session that actually re-replays after
  a manual cleanup; until then the refusal is loud and the fix is one
  `git branch -D`.
