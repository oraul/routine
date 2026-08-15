# Proposal — count-every-retry

## Why

The specify episode's revise budget is counted by a script:
`episode_revise_count` reads telemetry, the gate spends it, readers
report it, and "they can never disagree because there is one
implementation."

Two other retries in the same loop have no counter at all.

**The developer's floor is prose.** `agents/developer.md` says "after
about three consecutive gate failures on the same cause… stop
retrying". Nothing counts them. An agent that grinds a red gate five
times violates no rule a script can name, and Law 1 says an instruction
to an LLM is never load-bearing.

**Defect returns are uncapped.** `lib/episode.sh` resets the revise
budget on `spec.defective` — correct, re-specified work is new work —
but nothing bounds the returns themselves. A developer↔analyst
ping-pong can cycle indefinitely; the retro would measure it and no
gate would stop it.

Both are Law 1 gaps in the loop's own control surface, and both are
budgets in name only.

## What Changes

- `lib/episode.sh` gains two counters beside the existing one, so every
  budget has exactly one implementation: consecutive developer-gate
  failures for a task, and defect returns for a task.
- `routine-gate developer` spends the failure count: past the limit it
  refuses and names the road (`routine-defect` or `routine-block`)
  rather than letting the loop grind.
- `routine-defect` spends the return count: past the limit it refuses
  and names `routine-abort`, the same shape the analyst's exhausted
  budget already uses.
- Both limits are 3, matching the revise budget — one number to
  remember, and the developer contract already says "about three".

## Impact

- Affected specs: `gates`, `contract`
- Affected code: `lib/episode.sh`, `bin/routine-gate`,
  `bin/routine-defect`, `agents/developer.md`, and their suites
- `routine-defect` has never fired in three proving runs, so its cap is
  unexercised by real evidence. That is stated in the design rather than
  hidden: the counter is cheap and the road it protects is the one road
  nothing has walked.
