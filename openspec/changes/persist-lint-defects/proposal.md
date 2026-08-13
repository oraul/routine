## Why

The lint prints its defect list to stderr and nowhere else. When the
orchestrating session is fresh mid-episode, nobody holds that list —
and the only way to regenerate it is re-running the lint, which appends
another counted `spec.lint` failure to the revise budget. Information
recovery is charged as a revise attempt: the spec's "3 revise attempts
per episode" silently becomes 2 informed ones.

## What Changes

- **`bin/routine-spec-lint` mirrors its defects to the ticket**: every
  defect line written to stderr also lands in script-owned
  `<ticket>/lint.log`, truncated at the start of each run (after the
  usage check, so an exit-2 run never touches the ticket). A passing
  run leaves it empty.
- **The prompts hand the survivor over**: the skill's fresh-context
  branch hands the analyst `grounding.md` plus `lint.log` and the
  `defect.md` files — no re-run needed to see what failed; the
  analyst's re-entry list names `lint.log` alongside them.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `spec-grammar`: the defect list survives the run on script-owned
  state.
- `operation`: the skill and analyst re-entry read the surviving list
  instead of re-running for it.

## Impact

- Modified: `bin/routine-spec-lint`, `skills/routine/SKILL.md`,
  `agents/analyst.md`, `test/spec_lint.bats`,
  `test/agents_content.bats`.
