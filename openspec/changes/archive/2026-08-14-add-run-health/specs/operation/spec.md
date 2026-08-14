# operation Specification (delta)

## MODIFIED Requirements

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
`routine-abort` and a fresh ticket, never a rail back. Phase 0 SHALL name the script frontmatter and `routine-manual` as the authoritative contract for every script the protocol calls — consulted, never recalled. When the revising context is fresh, the skill SHALL hand the analyst the surviving record — `grounding.md`, the ticket's `lint.log`, and every `defect.md` — instead of re-running the gate to regenerate it. Phase 0 SHALL resolve state by script: after `routine-scaffold` it runs `routine-health` and branches on its exit code — no active ticket means `routine-ticket-new`, one active ticket is adopted and the run resumes at the phase health derived, and a needs-human exit stops for the human. The skill SHALL NOT infer which ticket is live or where a run stopped.

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
