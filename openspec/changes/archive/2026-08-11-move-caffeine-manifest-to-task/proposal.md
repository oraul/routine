## Why

The caffeine manifest lives on the briefing, but the developer works one
task at a time and different tasks in one briefing need different topics —
a migration task cares about `ruby/active_record`, its sibling view task
does not. The manifest moves to where the work is: the analyst declares
caffeine per task, and the developer loads exactly its own task's topics.

## What Changes

- **Grammar**: `## Caffeine` moves from `briefing.md` to every `task.md`
  (list may be empty beneath the heading). `routine-spec-lint` checks the
  section per task and no longer requires it on briefings.
- **Developer gate**: the baseline reads the in-progress **task's**
  manifest instead of the briefing's.
- **Prompts**: the analyst selects the manifest per task while writing the
  briefing's tasks; the developer's closed context references its own
  task's manifest. The `/routine` skill text needs no change (it never
  named the manifest's location).

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `spec-grammar`: the caffeine-section rule moves from briefing to task.
- `gates`: the developer baseline reads the task manifest.
- `operation`: the analyst contract says per-task manifest selection; the
  developer contract's closed context names the task's manifest.

## Impact

- Modified: `bin/routine-spec-lint`, `bin/routine-gate`,
  `agents/analyst.md`, `agents/developer.md`, gate and lint tests.
- Breaking for ticket artifacts authored under the old grammar; no such
  tickets exist outside local demo state.
