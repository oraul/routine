## Why

Every deterministic rail now exists; nothing yet drives it. This change adds
the prompt side: the `/routine` phase protocol, the `/unblock` conversation,
and the two agent contracts — all written against the scripts and spec'd
contracts, never around them.

## What Changes

- Add `skills/routine/SKILL.md`: the phase protocol
  (`preflight → specify → approve → develop → conclude`), human-invoked only
  (`disable-model-invocation: true`). Every transition calls its gate script
  and stops on non-zero; the index and telemetry are never touched directly;
  approve is a hard stop; spec-lint failures allow at most 3 revise attempts.
- Add `skills/unblock/SKILL.md`: `/unblock <ticket> <task>` — converse with
  the human, write `unblock.md`, call `routine-unblock`. Human-invoked only.
- Add `agents/analyst.md`: decomposes a requirement into briefings and tasks
  in the spec grammar, selects each briefing's caffeine manifest, revises on
  spec-lint failure, never implements.
- Add `agents/developer.md`: stateless; consumes exactly one task from
  `routine-next`; context is the task, the manifest docs, and block/unblock
  files — nothing else; red → green per scenario; fails a defective spec
  with a stated reason; blocks via `block.md` + `routine-block`.

## Capabilities

### New Capabilities

- `operation`: the operational protocol contract the prompts must encode —
  phase order and gating, the approve hard stop, the revise limit, and the
  two agents' context and refusal rules.

### Modified Capabilities

<!-- none -->

## Impact

- New prompt files only; no scripts change. Prompts are exempt from bats
  (their feedback loop is the retro); verification is
  `openspec validate --strict` plus a green selfcheck.
