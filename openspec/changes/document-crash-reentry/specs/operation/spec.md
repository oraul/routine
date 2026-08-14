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
`routine-abort` and a fresh ticket, never a rail back. Phase 0 SHALL name the script frontmatter and `routine-manual` as the authoritative contract for every script the protocol calls — consulted, never recalled. When the revising context is fresh, the skill SHALL hand the analyst the surviving record — `grounding.md`, the ticket's `lint.log`, and every `defect.md` — instead of re-running the gate to regenerate it. Phase 0 SHALL resolve state by script: after `routine-scaffold` it runs `routine-health` and branches on its exit code — no active ticket means `routine-ticket-new`, one active ticket is adopted and the run resumes at the phase health derived, and a needs-human exit stops for the human. The skill SHALL NOT infer which ticket is live or where a run stopped. It SHALL state how a run resumes after an interrupted develop phase: re-entry is at `routine-next`, which hands back the same in_progress task, never at preflight; when that task already holds a passing developer gate the move is `routine-done`, since the evidence is on record. It SHALL also name the dirty-target triage — a preflight failing on a dirty target while a task is in_progress is an interrupted develop, whose roads are committing the partial work or resetting it to resume from the recorded red.

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

### Requirement: The developer is stateless and evidence-bound
`agents/developer.md` SHALL instruct: consume exactly one task from
`routine-next`; context is the task file, the requirement's typed
contract section (`## Reproduction`/`## Touchpoints`/`## Contracts`/
`## Order` — the type's evidence, nothing else from the requirement),
the caffeine docs named in that task's own `## Caffeine` manifest, the
ticket's `calibration/<type>.md`, block/unblock files when present, and
the two handles every scripted call needs — the ticket directory
(`ROUTINE_TICKET_DIR`, the `<ticket-dir>` argument of the refusal
scripts) and the target root (`TARGET`) — nothing else. It SHALL state
the precedence when sources conflict (task > target conventions >
calibration > caffeine; earlier manifest topic first among caffeine
docs), SHALL record TDD evidence under the task's own
`## Scenario: <label>` headings — the label verbatim as the scenario
string, red and green bound to the identical label and identical
command (the audit demands a covering green per label and pairs the
evidence byte-exact) — with characterization tests kept out of the TDD
evidence, SHALL bound the developer-gate loop with an off-ramp
(repeated gate failures or a fix that leaves the task's scope route to
the scripted refusals, never an unbounded retry), SHALL return a
defective spec by calling `routine-defect <ticket-dir> <reason>`
instead of improvising, and on blockage SHALL write `block.md` and call
`routine-block`. The Never list SHALL cover script-owned state, other
tasks, out-of-manifest caffeine, `runs/<app>/hooks/*`, and calling
`routine-done` (the protocol driver's move, not the developer's). It SHALL name a `routine-*` script's frontmatter head (or `routine-manual`) as the contract to read before calling — never a recalled contract. On a re-served task — one an interrupted session left in_progress — it SHALL re-record red and green under the identical scenario label and the identical command, because the audit pairs on the recorded string and a rename or a changed command records an unpaired green.

#### Scenario: Statelessness named in the prompt
- **WHEN** the agent file is read
- **THEN** it names the one-task rule, the closed context list including
  the calibration doc, the scripted defect return, and the block procedure

#### Scenario: The context list matches what the scripts demand
- **WHEN** the agent file is read
- **THEN** the closed list admits `ROUTINE_TICKET_DIR`, `TARGET`, and
  the requirement's typed contract section, and states the precedence
  ladder

#### Scenario: The gate loop has a floor
- **WHEN** the developer gate keeps failing or the fix would leave the
  task's scope
- **THEN** the agent file routes to `routine-defect` or `routine-block`,
  never an unbounded retry

#### Scenario: Evidence carries the task's labels
- **WHEN** the agent file is read
- **THEN** it instructs recording red and green under the task's
  `## Scenario: <label>` headings verbatim

#### Scenario: The developer consults the contract
- **WHEN** the agent file is read
- **THEN** it points at the script head or `routine-manual` for script
  contracts

#### Scenario: A re-served task keeps its evidence identical
- **WHEN** the agent file is read
- **THEN** it instructs re-recording red and green with the identical
  label and command on a task that was interrupted
