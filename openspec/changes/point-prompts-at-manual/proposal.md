## Why

The prompts restate script contracts from memory, and memory is what
kept drifting — the agents council existed because of it. Since
add-script-contract, the authoritative contract lives in each script's
frontmatter with `routine-manual` assembling the whole surface, both
lint-enforced. The prompts should say so: consult the contract, never
recall it. The protocol branching (what to *do* on `routine-next` exit
3 versus 4) stays in the skill — that is protocol, not contract.

## What Changes

- **`skills/routine/SKILL.md`**: phase 0 names `routine-manual` and the
  frontmatter as the authoritative contract for every script the
  protocol calls — when in doubt, read the head, never recall.
- **`agents/analyst.md` and `agents/developer.md`**: one rule each —
  a `routine-*` script's head is its contract (usage, env, exit codes);
  read it or `routine-manual` before calling, never guess from memory.
- Content pins in `test/agents_content.bats`.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `operation`: the three prompt contracts name the manual as the
  authority on script contracts.

## Impact

- Modified: `skills/routine/SKILL.md`, `agents/analyst.md`,
  `agents/developer.md`, `test/agents_content.bats`.
