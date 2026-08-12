## Why

Two councils audited the agent and skill prompts against the scripts
they narrate and found them lying in six places: the developer's
"closed list" omits three things every run factually hands it (the
ticket directory, the target root, the requirement's typed contract
section); nothing orders the sources when their docs conflict; the
developer-gate loop is unbounded ("keep working until it is green");
the analyst restates two lint rules stale; the caffeinate skill
describes a pre-lint world (one fixture per rule, no metadata headers,
no `lib/sidecar.sh`); the unblock skill's signature drifted from its
script. Prompts are never load-bearing (Law 1), but wrong prompts burn
revise budgets against gates that were always going to fail.

## What Changes

- **`agents/developer.md`**: the closed context list admits
  `ROUTINE_TICKET_DIR` (it IS the `<ticket-dir>` argument the refusal
  scripts need), `TARGET`, and the requirement's typed contract
  section; one precedence ladder (task > target conventions >
  calibration > caffeine, earlier manifest topic first); red and green
  bind to the identical scenario string and command, with
  characterization tests kept out of the TDD evidence; the gate loop
  gains a defect-or-block off-ramp; the Never list gains
  `runs/<app>/hooks/*` and `routine-done`.
- **`agents/analyst.md`**: the stale lint restatement goes (the Output
  section already carries all four contract topics); missing
  vocabulary refers the human to `/caffeinate` instead of inventing
  topic names; the revise limit is stated the way the gate counts it
  (per episode; a defect return opens a fresh budget).
- **Both agents**: YAML frontmatter (`name`, `description`) so the
  files register as subagents.
- **`skills/routine/SKILL.md`**: phase 0 exports `TARGET`; delegation
  hands each agent its ticket directory and target explicitly (a
  stateless agent's payload is its whole world); conclude states the
  honest failure road — a done task the audit refuses cannot be
  re-evidenced, the road is `routine-abort` and a fresh ticket.
- **`skills/unblock/SKILL.md`**: the argument form matches the script —
  `<ticket-dir> [task-id]`.
- **`skills/caffeinate/SKILL.md`**: step 3 rewritten to the enforced
  contract — exact H1 and metadata headers, `lib/sidecar.sh` `check`
  calls, verbatim doc/sidecar rule agreement, one fixture per topic at
  `test/caffeine_<ns>_<topic>.bats`, and `routine-caffeine-lint` in
  the acceptance bar.
- **Spec truth repair**: the operation, calibration, and caffeine
  specs updated where their text predates the enforced reality.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `operation`: the skill and both agent contracts match the scripts
  they narrate.
- `calibration`: the typed-structure requirement names all four
  contract topics, agreeing with the contract capability.
- `caffeine`: the generation requirement describes the lint's
  contract, not the pre-lint one.

## Impact

- Modified: `agents/developer.md`, `agents/analyst.md`,
  `skills/routine/SKILL.md`, `skills/unblock/SKILL.md`,
  `skills/caffeinate/SKILL.md`.
- Added: `test/agents_content.bats` (content pins, terms of art only).
