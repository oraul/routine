# Proposal — the-replay-moves-only-the-rails

## Why — every "the loop improved" is still a prediction

The records have been careful twice: the v0.8.0 record refused to
credit the rails for the 0002→0003 abort-to-clean transition because
the requirement text had also changed, and the v0.9.0 record upheld
the refusal — two variables moved, so the cause could not be claimed.
That discipline is now contract (the confound rule, #98). What has
never existed is the instrument that would settle such claims: replay
an archived requirement **verbatim** against the current rails with
the target reset to the archived anchor, so the requirement and the
target hold still and only the rails differ. The v0.9.0 record named
this exact experiment as "now buildable — which it was not when v0.8.0
said so." It has been buildable and unbuilt for two releases; until it
runs, every improvement claim stays a prediction whose grader does not
exist.

Measured before proposing: every archived shopapp anchor still
resolves (`git cat-file -e` on all four distinct `Grounded-at` values
— the greps and probes ran), and ticket 0001, which predates the
anchor rule, has none — the honest refusal case.

## What changes

- **`bin/routine-replay <archived-ticket-dir>`** creates the
  controlled arm: a detached worktree of the target at the archived
  anchor — placed at `runs/<app>/replays/<id>-<sha8>/<app>` so the
  app key every gate derives resolves to the same state tree — and a
  fresh ticket via `routine-ticket-new` (WIP stays 1) whose
  `requirement.md` is byte-identical to the archived one, with
  provenance in `replay.md` and a `ticket.replay` telemetry line. The
  archived run's final event is printed beside the new paths, so the
  operator knows the outcome under comparison.
- **Refusals create nothing lasting**: no requirement, no well-formed
  anchor (pre-anchor runs cannot be replayed honestly), an
  unresolvable anchor, an existing replay worktree — and a refused
  allocation removes the worktree it just created.
- **`ticket.replay` joins `lib/roads.txt`** with an honest waiver —
  never walked until the first live replay runs — and the road-check
  will refuse the waiver as stale the moment that happens, which is
  the reminder to drop it.
- The `tickets` spec carries the requirement as ADDED.

## Not built, with what would earn it

- **Running the first replay inside this change.** The loop's approve
  checkpoint belongs to the operator; a replay run is a live
  two-agent session with a human in it, not a task a change can tick.
  The instrument lands here; the experiment is the next run the
  operator starts.
- **A comparison script.** What an abort-to-clean transition means is
  a judgment about two runs' records; scripting the verdict would
  cross the truth boundary every lint here holds. Earned only if
  replays become frequent enough that reading two telemetry files by
  hand is the bottleneck.
- **Replaying the analyst's artifacts.** Only `requirement.md` is
  copied: grounding, briefings, and tasks are exactly what the new
  rails must produce themselves — copying them would move the answer
  in with the question.
- **Worktree lifecycle management.** One replay at a time per
  archived ticket; the worktree is removed by hand when its ticket
  concludes or aborts. A reaper is earned by the first session that
  actually trips over a stale one.
