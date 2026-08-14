# Proposal — admit-scout-agent

## Why

`declare-agent-tiers` recorded `agents/scout.md` as a non-goal, earned by
"a run that used them." That condition cannot be checked: `runs/` is
gitignored, so no reader of this repository can tell whether a scout was
ever dispatched. It is an assumption dressed as a measurement — the same
blind spot that put a false claim into a merged PR.

The human has asked for the tier directly, which settles it: a
requirement from the human outranks a non-goal whose earning condition is
unverifiable. This change supersedes that non-goal explicitly rather than
quietly stepping over it.

The mechanical half of the loop is real work at the wrong price. Locating
a test file, listing what implements a symbol, and reading which fixtures
exist are graded entirely by whether the caller can then do its job — the
weakest possible grader, and therefore the cheapest justified tier. Both
the analyst and the developer meet that work; today only the analyst may
delegate it, with no declared tier, and the developer may not delegate at
all.

## What Changes

- A third agent file, `agents/scout.md`, declared at `model: haiku`:
  read-only, one survey per invocation, output that is never contract.
- `agents/developer.md` admits mechanical delegation to it, with a closed
  list of what may never be delegated — every `routine-tdd` call, every
  refusal script, and the decision that a test is red.
- `agents/analyst.md`'s existing scout paragraph names the file instead
  of describing an anonymous capability.
- The tier pin extends to all three agents; a new pin asserts the scout
  writes nothing.

## Impact

- Affected specs: `operation`
- Affected code: `agents/scout.md` (new), `agents/developer.md`,
  `agents/analyst.md`, `test/agents_content.bats`
- No script changes. Nothing in `bin/` can observe a delegation, so
  nothing in `bin/` is asked to.
