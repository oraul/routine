# operation Specification

## Purpose

The operational protocol the prompt files must encode: how the phase machine
runs, where humans decide, and what each agent may and may not do.

## Requirements

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
`routine-abort` and a fresh ticket, never a rail back. Phase 0 SHALL name the script frontmatter and `routine-manual` as the authoritative contract for every script the protocol calls — consulted, never recalled. When the revising context is fresh, the skill SHALL hand the analyst the surviving record — `grounding.md`, the ticket's `lint.log`, and every `defect.md` — instead of re-running the gate to regenerate it. Phase 0 SHALL resolve state by script: after `routine-scaffold` it runs `routine-health` and branches on its exit code — no active ticket means `routine-ticket-new`, one active ticket is adopted and the run resumes at the phase health derived, and a needs-human exit stops for the human. The skill SHALL NOT infer which ticket is live or where a run stopped. It SHALL state how a run resumes after an interrupted develop phase: re-entry is at `routine-next`, which hands back the same in_progress task, never at preflight; when that task already holds a passing developer gate the move is `routine-done`, since the evidence is on record. It SHALL also name the dirty-target triage — a preflight failing on a dirty target while a task is in_progress is an interrupted develop, whose roads are committing the partial work or resetting it to resume from the recorded red. The interrupted-develop triage SHALL live on the develop phase, the road a resumed run actually travels, and the delegation payload SHALL tell a re-served developer that the target's uncommitted diff is its predecessor's.

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

### Requirement: The unblock skill captures human context as evidence
`skills/unblock/SKILL.md` SHALL be human-invoked only and SHALL instruct:
converse with the human about the named ticket and task, write their
unblocking context to the task's `unblock.md`, then call `routine-unblock` —
never editing the index directly.

#### Scenario: Evidence before release
- **WHEN** the skill file is read
- **THEN** it orders unblock.md before routine-unblock and forbids index
  edits

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
the human and `/caffeinate` — never an invented topic name. It SHALL name a `routine-*` script's frontmatter head (or `routine-manual`) as the contract to read before calling — never a recalled contract. Its re-entry sources SHALL include the ticket's `lint.log` alongside `grounding.md` and the `defect.md` files. Its grounding instruction SHALL describe Evidence bullets as claim-bearing — `- <path> — <what the file was found to contain or do>` — with the ruled-out form and the `- none — <why>` floors for Alternatives and Assumptions. Its re-entry rule SHALL be anchor-first: Evidence bullets are current when `Grounded-at` equals the target's current HEAD and the worktree is clean; otherwise only bullets whose paths the diff against the worktree (plus untracked files) names are re-verified, and the anchor is refreshed — never a full re-search. Its context handles SHALL be named: `TARGET`, the repository it grounds against, and `ROUTINE_TICKET_DIR`, where its artifacts land. It MAY use cheap read-only scouts to survey the target when the host provides delegation — scout prompts are transcript-only and never load-bearing; every accepted scout claim SHALL land as an Evidence bullet naming a real path, and unverified scout claims SHALL go under `## Assumptions` — however evidence is gathered, only the ticket artifacts are contract.

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

#### Scenario: Re-entry reads the surviving defect list
- **WHEN** the agent file's re-entry section is read
- **THEN** it names lint.log among the files to read before re-deriving

#### Scenario: Evidence carries findings, not relevance
- **WHEN** the agent file's grounding output is read
- **THEN** it teaches the claim-bearing bullet form, the ruled-out
  form, and the non-empty floors

#### Scenario: Re-entry is anchor-first
- **WHEN** the agent file's re-entry section is read
- **THEN** it decides staleness by the Grounded-at anchor and re-verifies
  only diff-named and untracked paths

#### Scenario: Scout output is evidence or nothing
- **WHEN** the agent file is read
- **THEN** it admits read-only scouting with transcript-only prompts and
  routes accepted claims to Evidence bullets and unverified ones to
  Assumptions

#### Scenario: The analyst's handles are named
- **WHEN** the agent file is read
- **THEN** it names TARGET and ROUTINE_TICKET_DIR as its context
  handles

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
`routine-done` (the protocol driver's move, not the developer's). It SHALL name a `routine-*` script's frontmatter head (or `routine-manual`) as the contract to read before calling — never a recalled contract. On a re-served task — one an interrupted session left in_progress — it SHALL re-record red and green under the identical scenario label and the identical command, because the audit pairs on the recorded string and a rename or a changed command records an unpaired green. On a re-served task it SHALL read the target's uncommitted diff before writing anything — the failing test it is about to write may already be there, left by the developer it replaced.

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

#### Scenario: A replacement developer reads before writing
- **WHEN** the agent file is read
- **THEN** it instructs reading the target's uncommitted diff first on a
  re-served task

### Requirement: Agent files register as subagents
`agents/analyst.md` and `agents/developer.md` SHALL open with YAML
frontmatter carrying `name` and `description`, so the files are
loadable as subagents by the host, and the `name` SHALL match the
filename stem.

#### Scenario: Frontmatter present
- **WHEN** either agent file is read
- **THEN** it opens with `---`, a `name:` matching its filename, and a
  non-empty `description:`
