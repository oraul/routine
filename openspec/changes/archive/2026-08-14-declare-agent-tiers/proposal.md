## Why

The loop already separates two kinds of work, and they are not equally
gradeable. The developer's output is graded by scripts — a failing test
must fail, a green must pass, the gate runs the app's own suite, and the
audit replays the record. The analyst's output is graded by a structural
lint and a human: nothing mechanical can tell a coherent decomposition
from an incoherent one that happens to satisfy the grammar.

That difference is what a model tier should follow, and the host reads
the declaration from each agent's frontmatter — so the tier can be data
rather than an instruction anybody has to remember.

Two things this change refuses to pretend. Routine declares **no** model
for the driving session: a skill carries no such field, and the session
is the human's own, so it can be neither enforced nor verified. And no
`model` key joins telemetry — `routine-health` and `routine-audit` parse
the fixed key order positionally (`awk -F'"'` on `$8`, `$12`, `$20`,
`$23`), so any key inserted before `exit` breaks both readers. The
consequence is stated rather than hidden: the tiers ship as a recorded
choice, and the retro cannot adjudicate them.

## What Changes

- **Each agent declares its tier**: `model:` joins the frontmatter of
  `agents/analyst.md` and `agents/developer.md`. The developer runs at
  a mid tier because scripts grade every line it writes. The analyst
  inherits the driving session's model, because pinning judgment below
  the session that supplies the requirement is the one split that
  cannot be defended.
- **The skill states the orchestrator's contract**: the driving session
  is the judgment tier — it holds the requirement, builds each payload,
  and decides — and it declares no model for itself.
- **Liveness is stated honestly**: a delegation returns or it errors,
  so there is no ambient offline state to poll and no timeout a blocked
  caller could run. A run that looks stalled is diagnosed by
  `routine-health` reading script-owned state, and `routine-next`
  re-serves the interrupted task.

## Capabilities

### Modified Capabilities

- `operation`: the agent registration requirement carries the tier
  declaration, the skill requirement carries the orchestrator contract
  and the no-model-for-the-driver rule, and liveness is described where
  the resume actually happens.

## Impact

- Modified: `agents/analyst.md`, `agents/developer.md`,
  `skills/routine/SKILL.md`, `test/agents_content.bats`.
