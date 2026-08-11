## Why

A bug, a feature inside existing code, a greenfield feature, and an epic
are different shapes of work: they deserve different decomposition, different
evidence, and different developer posture. Today the agents treat every
requirement identically. Calibration gives each work type its own insights —
declared mechanically, enforced structurally, taught per type.

## What Changes

- **Grammar**: `requirement.md` declares its work type on a line
  `Type: <bug|feature|greenfield|epic>`. `routine-spec-lint` enforces the
  declaration and two type-specific structure rules: a `bug` requirement
  MUST carry a `## Reproduction` section; an `epic` MUST decompose into at
  least two briefings.
- **Calibration docs**: `calibration/{bug,feature,greenfield,epic}.md` —
  per-type guidance for both agents (how to decompose, what evidence leads,
  what posture the developer takes).
- **Prompts**: the analyst reads the declared type's calibration before
  decomposing and shapes briefings/tasks accordingly; the developer's closed
  context gains its ticket's calibration doc.

## Capabilities

### New Capabilities

- `calibration`: the work-type contract — the declaration, the per-type
  structural rules, the doc set, and who loads what.

### Modified Capabilities

- `spec-grammar`: requirement grammar gains the Type line and the two
  type-conditional checks.
- `operation`: both agent contracts gain calibration loading.

## Impact

- New: `calibration/*.md` (4 docs); modified: `bin/routine-spec-lint`,
  `agents/analyst.md`, `agents/developer.md`, lint tests.
- Grammar-breaking for previously authored tickets; none exist beyond local
  demo state.
