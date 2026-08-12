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
`routine-abort` and a fresh ticket, never a rail back. Phase 0 SHALL name the script frontmatter and `routine-manual` as the authoritative contract for every script the protocol calls — consulted, never recalled.

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

### Requirement: The analyst decomposes and never implements
`agents/analyst.md` SHALL instruct: read the requirement's declared work
type and its `calibration/<type>.md` before decomposing; ground first
and record it — `grounding.md`'s evidence, alternatives, and assumptions
are written before the artifacts they justify; decompose the
requirement into briefings and tasks in the spec grammar (requirement
header, `Type:` declaration, RFC 2119 keywords, scenarios written as
Given/When/Then lines under `## Scenario: <label>` headings — the
labels the audit binds evidence to — enumerated acceptance, and a
non-empty caffeine manifest per task, with `testing/tdd` as the floor
when nothing domain-specific fits), shaped by the type's calibration;
revise against the full spec-lint defect list, continuing the same
conversation where it survives and re-grounding from `grounding.md`
where it does not; and never write implementation code or touch
script-owned state. It SHALL NOT restate individual lint rules outside
the grammar it teaches (stale restatements drift), SHALL state the
revise limit the way the gate counts it (per episode; a defect return
opens a fresh budget), and SHALL route missing caffeine vocabulary to
the human and `/caffeinate` — never an invented topic name. It SHALL name a `routine-*` script's frontmatter head (or `routine-manual`) as the contract to read before calling — never a recalled contract.

#### Scenario: Grammar named in the prompt
- **WHEN** the agent file is read
- **THEN** it names every grammar marker the linter enforces — including
  the type declaration, calibration loading, and the grounding record —
  and the never-implements rule

#### Scenario: Missing vocabulary goes to the human
- **WHEN** the agent file is read
- **THEN** it instructs referral to `/caffeinate` when no existing
  topic fits, instead of guessing a topic name

#### Scenario: The analyst consults the contract
- **WHEN** the agent file is read
- **THEN** it points at the script head or `routine-manual` for script
  contracts

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
`routine-done` (the protocol driver's move, not the developer's). It SHALL name a `routine-*` script's frontmatter head (or `routine-manual`) as the contract to read before calling — never a recalled contract.

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
