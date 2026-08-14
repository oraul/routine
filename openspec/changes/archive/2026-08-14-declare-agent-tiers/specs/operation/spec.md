# operation Specification (delta)

## MODIFIED Requirements


### Requirement: Agent files register as subagents
`agents/analyst.md` and `agents/developer.md` SHALL open with YAML
frontmatter carrying `name` and `description`, so the files are
loadable as subagents by the host, and the `name` SHALL match the
filename stem. Each file SHALL also declare its `model` tier, chosen by who grades that role's output: work a script grades may run at a lower tier, while judgment only a human grades SHALL NOT be pinned below the driving session. Routine SHALL check only what it owns — that the field is present and its value is one this repository recognises — since no script here can observe which model answered.

#### Scenario: Frontmatter present
- **WHEN** either agent file is read
- **THEN** it opens with `---`, a `name:` matching its filename, and a
  non-empty `description:`

#### Scenario: The tier is declared, not remembered
- **WHEN** either agent file is read
- **THEN** its frontmatter declares a `model` whose value the repository
  recognises

### Requirement: The routine skill encodes the gated phase machine
`skills/routine/SKILL.md` SHALL be human-invoked only
(`disable-model-invocation: true`) and SHALL instruct the protocol
`preflight → specify → approve → develop → conclude`, where every phase
transition calls its gate or lifecycle script and a non-zero exit stops
the run. It SHALL forbid direct writes to `index.tsv` and
`telemetry.jsonl`, SHALL make approve a hard stop for the human whose
proceed is recorded by `routine-approve` (with any remarks the human
made), SHALL limit specify to 3 revise attempts per episode with the
exhausted branch calling `routine-abort` (never an abort in prose), and
SHALL distinguish `routine-next`'s exits: 0 a task, 2 a caller bug (bad
ticket dir), 3 a blocked line, 4 all done. Phase 0 SHALL export both
handles later calls need — `ROUTINE_TICKET_DIR` and `TARGET` — and
delegation SHALL hand each agent its ticket directory and target
explicitly, because a stateless agent's payload is its whole world.
The conclude phase SHALL state the honest failure road: audit
violations on a task already marked done cannot be re-evidenced
(telemetry is script-owned and append-only), so the road is
`routine-abort` and a fresh ticket, never a rail back. Phase 0 SHALL name the script frontmatter and `routine-manual` as the authoritative contract for every script the protocol calls — consulted, never recalled. When the revising context is fresh, the skill SHALL hand the analyst the surviving record — `grounding.md`, the ticket's `lint.log`, and every `defect.md` — instead of re-running the gate to regenerate it. Phase 0 SHALL resolve state by script: after `routine-scaffold` it runs `routine-health` and branches on its exit code — no active ticket means `routine-ticket-new`, one active ticket is adopted and the run resumes at the phase health derived, and a needs-human exit stops for the human. The skill SHALL NOT infer which ticket is live or where a run stopped. It SHALL state how a run resumes after an interrupted develop phase: re-entry is at `routine-next`, which hands back the same in_progress task, never at preflight; when that task already holds a passing developer gate the move is `routine-done`, since the evidence is on record. It SHALL also name the dirty-target triage — a preflight failing on a dirty target while a task is in_progress is an interrupted develop, whose roads are committing the partial work or resetting it to resume from the recorded red. The interrupted-develop triage SHALL live on the develop phase, the road a resumed run actually travels, and the delegation payload SHALL tell a re-served developer that the target's uncommitted diff is its predecessor's. It SHALL state the driving session's own job — holding the requirement, building each delegation payload, and deciding — and SHALL NOT declare a model for that session: a skill carries no such field and the session is the human's own, so routine can neither enforce nor verify it. It SHALL describe liveness as a property of the record rather than of a timer: a delegation returns or errors, so a caller has no ambient offline state to poll, and a run that appears stalled is diagnosed by `routine-health` and resumed through `routine-next`, which re-serves the interrupted task.

#### Scenario: Protocol present in the skill
- **WHEN** the skill file is read
- **THEN** it names the five phases in order, the gate call per transition,
  the stop-on-non-zero rule, the approve hard stop recorded by
  `routine-approve`, and the 3-revise limit
  with the `routine-abort` exhausted branch and every `routine-next` exit
  code explained

#### Scenario: The delegation payload is explicit
- **WHEN** the skill file is read
- **THEN** phase 0 exports `ROUTINE_TICKET_DIR` and `TARGET`, the
  delegation steps hand the agent its ticket directory and target, and
  conclude routes a refused done task to `routine-abort`

#### Scenario: The manual is the authority in the skill
- **WHEN** the skill file is read
- **THEN** it names `routine-manual` (or the script head) as the
  contract source instead of restating contracts from memory

#### Scenario: Recovery reads, never re-runs
- **WHEN** a fresh context resumes a specify episode
- **THEN** the skill hands over grounding.md, lint.log, and defect.md
  files rather than spending a counted lint run on recovery

#### Scenario: Resuming reads state instead of inferring it
- **WHEN** the skill file's phase 0 is read
- **THEN** it runs `routine-health` and branches on the exit code rather
  than judging whether an active ticket exists

#### Scenario: A resumed develop phase re-enters at the task line
- **WHEN** the skill file is read
- **THEN** it states that resuming develop calls `routine-next` rather
  than restarting at preflight, and that a task with a passing gate
  goes straight to `routine-done`

#### Scenario: The triage sits where the resume passes
- **WHEN** the skill file's develop phase is read
- **THEN** it carries the partial-work triage and passes the target's
  uncommitted diff to the re-served developer

#### Scenario: The driver declares no tier for itself
- **WHEN** any skill file is read
- **THEN** it declares no model for the driving session

#### Scenario: A stalled run is read, never timed out
- **WHEN** the skill file is read
- **THEN** it routes an agent that appears stalled to `routine-health` and
  `routine-next` rather than to any timeout
