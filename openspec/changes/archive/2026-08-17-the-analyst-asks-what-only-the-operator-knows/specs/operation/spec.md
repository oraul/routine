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
`routine-abort` and a fresh ticket, never a rail back. Phase 0 SHALL name the script frontmatter and `routine-manual` as the authoritative contract for every script the protocol calls — consulted, never recalled. When the revising context is fresh, the skill SHALL hand the analyst the surviving record — `grounding.md`, the ticket's `lint.log`, and every `defect.md` — instead of re-running the gate to regenerate it. Phase 0 SHALL resolve state by script: after `routine-scaffold` it runs `routine-health` and branches on its exit code — no active ticket means `routine-ticket-new`, one active ticket is adopted and the run resumes at the phase health derived, and a needs-human exit stops for the human. The skill SHALL NOT infer which ticket is live or where a run stopped. It SHALL state how a run resumes after an interrupted develop phase: re-entry is at `routine-next`, which hands back the same in_progress task, never at preflight; when that task already holds a passing developer gate the move is `routine-done`, since the evidence is on record. It SHALL also name the dirty-target triage — a preflight failing on a dirty target while a task is in_progress is an interrupted develop, whose roads are committing the partial work or resetting it to resume from the recorded red. The interrupted-develop triage SHALL live on the develop phase, the road a resumed run actually travels, and the delegation payload SHALL tell a re-served developer that the target's uncommitted diff is its predecessor's. It SHALL state the driving session's own job — holding the requirement, building each delegation payload, and deciding — and SHALL NOT declare a model for that session: a skill carries no such field and the session is the human's own, so routine can neither enforce nor verify it. It SHALL describe liveness as a property of the record rather than of a timer: a delegation returns or errors, so a caller has no ambient offline state to poll, and a run that appears stalled is diagnosed by `routine-health` and resumed through `routine-next`, which re-serves the interrupted task.
 The specify and develop steps SHALL carry literal payload templates rather than prose descriptions of what to include, because the invariant half of a delegation belongs in a file and only the variable half belongs in the call — the same split `.claude/agents/contributor.md` makes for the development loop. Each template SHALL name resolved absolute paths, since a stateless agent has no working directory it can trust and no environment it inherits. The develop template SHALL pass the task's `briefing.md`, which the developer's closed context list now expects. The specify template SHALL carry the surviving-record handoff for a revise — `grounding.md`, the ticket's `lint.log`, and every `defect.md` — so a rule the skill states in prose is one the driver cannot forget to pass. The approve step SHALL show the ticket's `## Questions` alongside `requirement.md` and every `briefing.md`, because a question only the operator can answer is invisible at the one checkpoint built for the operator's judgment when it lives in `grounding.md` alone. The specify payload template SHALL carry a context field naming what the target is and what its operator cares about, since `Requirement`, `ROUTINE_TICKET_DIR` and `TARGET` leave a stateless analyst deriving intent from code that never recorded it.
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

#### Scenario: Both delegations carry a literal template
- **WHEN** the skill file's specify and develop steps are read
- **THEN** each carries a payload template naming resolved absolute
  paths rather than a prose description of what to include

#### Scenario: The develop template passes the briefing
- **WHEN** the develop step's template is read
- **THEN** it passes the task's `briefing.md`, which the developer's
  closed context list expects
#### Scenario: Approve shows what only the operator can answer
- **WHEN** the approve step is read
- **THEN** it shows the ticket's `## Questions` beside `requirement.md`
  and every `briefing.md`

#### Scenario: The specify payload carries domain context
- **WHEN** the specify payload template is read
- **THEN** it carries a context field for what the target is and what its
  operator cares about, beside the requirement and the two handles


### Requirement: The analyst decomposes and never implements
`agents/analyst.md` SHALL instruct: read the requirement's declared work
type and its `calibration/<type>.md` before decomposing; ground first
and record it — `grounding.md`'s evidence, alternatives, and assumptions
are written before the artifacts they justify; decompose the
requirement into briefings and tasks in the spec grammar, each briefing carrying the conventions in force for its slice — the target's idioms the tasks inside it must follow, so the developer implementing that slice reads them instead of re-deriving them (requirement
header, `Type:` declaration, RFC 2119 keywords, scenarios written as
Given/When/Then lines under `## Scenario: <label>` headings — the
labels the audit binds evidence to — with `## Characterization: <label>`
as the heading for a green-at-birth pin of existing behaviour, whose
coverage is the task's developer gate rather than tdd evidence — enumerated acceptance, and a
non-empty caffeine manifest per task, with `testing/tdd` as the floor
when nothing domain-specific fits), shaped by the type's calibration;
revise against the full spec-lint defect list, continuing the same
conversation where it survives and re-grounding from `grounding.md`
where it does not; and never write implementation code or touch
script-owned state. It SHALL NOT restate individual lint rules outside
the grammar it teaches (stale restatements drift), SHALL state the
revise limit the way the gate counts it (per episode; a defect return
opens a fresh budget), and SHALL route missing caffeine vocabulary to
the human and `/caffeinate` — never an invented topic name. It SHALL name a `routine-*` script's frontmatter head (or `routine-manual`) as the contract to read before calling — never a recalled contract. Its re-entry sources SHALL include the ticket's `lint.log` alongside `grounding.md` and the `defect.md` files. Its grounding instruction SHALL describe Evidence bullets as claim-bearing — `- <path> — <what the file was found to contain or do>` — with the ruled-out form and the `- none — <why>` floors for Alternatives and Assumptions. Its re-entry rule SHALL be anchor-first: Evidence bullets are current when `Grounded-at` equals the target's current HEAD and the worktree is clean; otherwise only bullets whose paths the diff against the worktree (plus untracked files) names are re-verified, and the anchor is refreshed — never a full re-search. Its context handles SHALL be named: `TARGET`, the repository it grounds against, and `ROUTINE_TICKET_DIR`, where its artifacts land. It MAY use cheap read-only scouts to survey the target when the host provides delegation — scout prompts are transcript-only and never load-bearing; every accepted scout claim SHALL land as an Evidence bullet naming a real path, and unverified scout claims SHALL go under `## Assumptions` — however evidence is gathered, only the ticket artifacts are contract. It SHALL name `agents/scout.md` as the file those scouts are, rather than describing an anonymous capability. On re-entry after a defect return it SHALL write the patch account into the returned task itself — what the defect invalidated and what changed in response — because the `## Reconciliation` line it writes lives in `grounding.md`, which is outside the developer's closed context list, and an account the reader cannot reach is not an account. It SHALL read the verbatim failure `routine-tdd characterize` captured for a task returned that way, rather than a paraphrase of it. It SHALL describe the characterization phase as the developer's contract builds it: a `## Characterization: <label>` scenario's birth claim is proven with `routine-tdd characterize`, recording a `tdd.characterize` line and no red/green pair — never that the developer records no TDD evidence at all, which contradicts the phase and which a ticket written to it cannot satisfy. It SHALL separate a **derivation** — a claim citable to a path and a line in the target, such as the codebase's refusal idiom or its guard order — from a **question only the operator can answer**, a claim about product intent on which the target has no opinion at any depth, such as which way money rounds or whether a boundary value is a no-op or a mistake. Derivations SHALL stay under `## Assumptions`; questions SHALL be recorded under `## Questions` with the provisional reading the decomposition was built on, so the loop never stalls waiting for an answer while the override stays cheap and the decision stays attributed to whoever made it.
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
#### Scenario: The patch reaches the developer that redoes the task
- **WHEN** the agent file is read
- **THEN** it writes the patch account into the returned task itself,
  not only into `grounding.md`, and reads the captured verbatim failure
#### Scenario: The characterization phase is described as it is built
- **WHEN** the analyst file is read
- **THEN** it names `routine-tdd characterize` and the
  `tdd.characterize` evidence a characterization records, and does not
  claim the developer records no TDD evidence for it

#### Scenario: A question is not an assumption
- **WHEN** the analyst file is read
- **THEN** it separates a claim citable to the target from a claim about
  product intent, and sends the second to `## Questions` carrying the
  provisional reading

