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
the human and `/caffeinate` — never an invented topic name. It SHALL name a `routine-*` script's frontmatter head (or `routine-manual`) as the contract to read before calling — never a recalled contract. Its re-entry sources SHALL include the ticket's `lint.log` alongside `grounding.md` and the `defect.md` files. Its grounding instruction SHALL describe Evidence bullets as claim-bearing — `- <path> — <claim>`, one bullet per target file read or probe executed against it, the claim stating what the file was found to contain or do, or what the probe ran and returned — with the ruled-out form and the `- none — <why>` floors for Alternatives and Assumptions. Its re-entry rule SHALL be anchor-first: Evidence bullets are current when `Grounded-at` equals the target's current HEAD and the worktree is clean; otherwise only bullets whose paths the diff against the worktree (plus untracked files) names are re-verified, and the anchor is refreshed — never a full re-search. Its context handles SHALL be named: `TARGET`, the repository it grounds against, and `ROUTINE_TICKET_DIR`, where its artifacts land. It MAY use cheap read-only scouts to survey the target when the host provides delegation — scout prompts are transcript-only and never load-bearing; every accepted scout claim SHALL land as an Evidence bullet naming a real path, and unverified scout claims SHALL go under `## Assumptions` — however evidence is gathered, only the ticket artifacts are contract. It SHALL name `agents/scout.md` as the file those scouts are, rather than describing an anonymous capability. On re-entry after a defect return it SHALL write the patch account into the returned task itself — what the defect invalidated and what changed in response — because the `## Reconciliation` line it writes lives in `grounding.md`, which is outside the developer's closed context list, and an account the reader cannot reach is not an account. It SHALL read the verbatim failure `routine-tdd characterize` captured for a task returned that way, rather than a paraphrase of it. It SHALL describe the characterization phase as the developer's contract builds it: a `## Characterization: <label>` scenario's birth claim is proven with `routine-tdd characterize`, recording a `tdd.characterize` line and no red/green pair — never that the developer records no TDD evidence at all, which contradicts the phase and which a ticket written to it cannot satisfy. It SHALL separate a **derivation** — a claim citable to a path and a line in the target, such as the codebase's refusal idiom or its guard order — from a **question only the operator can answer**, a claim about product intent on which the target has no opinion at any depth, such as which way money rounds or whether a boundary value is a no-op or a mistake. Derivations SHALL stay under `## Assumptions`; questions SHALL be recorded under `## Questions` with the provisional reading the decomposition was built on, so the loop never stalls waiting for an answer while the override stays cheap and the decision stays attributed to whoever made it. Its artifacts SHALL keep a probe apart from a forecast: a claim it verified by executing against the target says so, and a claim about what unwritten code or an unrun phase will do names the grader that settles it — `routine-tdd red` grades "this scenario will be red", `routine-tdd characterize` grades "this was already true", the developer gate grades the rest — because a re-entering analyst once presented a simulation of unwritten code in the same voice as ten verified probes, and a reader could not tell which they were holding.
Its validation SHALL be refutation-first: before filing, it attempts once to refute each briefing's load-bearing claim that the target as it stands can refute — running the probe that would prove the decomposition wrong — and records the attempt and its outcome as an Evidence bullet in the section's enforced line form even when the claim survives, because support-gathering is not validation and the invented-intent and simulated-probe incidents both travelled through claims nobody had tried to break. A load-bearing claim that is a forecast is never probed in advance — its refutation is the grader it already names — and on re-entry the anchor rule governs: an anchor-current refutation bullet stands, and only a new or amended claim, or one whose cited paths the diff names, earns a fresh attempt. Its probes SHALL be recorded symmetrically: every probe it executed appears in its artifacts, inconvenient results at the same fidelity as convenient ones — an omitted miss is a curated record, and a curated record is how a false conclusion arrives well-evidenced. A recorded probe SHALL quote the command that ran and the decisive output it returned inside its bullet's claim — the Evidence line form admits no fenced block — so a reader can re-run what ran. Its re-entry sources SHALL include the ticket's `approve.md` when present — the operator's recorded rulings, each of which binds until the operator moves it; absence means approve has not yet run and never means a defect, because every recorded proceed writes the file — alongside `grounding.md`, `lint.log`, and the `defect.md` files. When it bakes a recorded ruling into its question's bullet, the reconciliation SHALL append the ruled marker to that bullet — `RULED at approve (approve.md A<n>): <the standing reading>`, the bullet's original provisional text kept in place — because the marker is what lets the approve gate stop demanding a re-answer for a ruling that already binds, and a marker in any other words is invisible to the gate that reads it. Its comparisons SHALL claim a cause only when one variable moved between the things compared; otherwise the confound — what else moved — is named, or the causal claim is dropped. Its trust in an anchor-current record SHALL be a default and never a prohibition: the lint names one sampled Evidence bullet per run — chosen by the file's own bytes, never by the author — and re-verifying that sample never counts as a re-search, because a curated record survives only where nothing is ever re-run.
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
#### Scenario: A forecast names its grader
- **WHEN** the analyst file is read
- **THEN** it separates claims verified by execution from forecasts,
  and requires each forecast to name the phase or gate that settles it

#### Scenario: The analyst tries to refute its own decomposition
- **WHEN** the analyst file is read
- **THEN** it requires one refutation attempt against each briefing's
  load-bearing claim that the target as it stands can refute, recorded
  with its outcome even when the claim survives, and sends a forecast
  to its grader instead of probing it in advance

#### Scenario: Probes are symmetric and quoted in the line form
- **WHEN** the analyst file is read
- **THEN** it requires every executed probe in the artifacts at equal
  fidelity, each bullet quoting its command and decisive output inside
  the enforced Evidence line form

#### Scenario: Re-entry reads the operator's rulings
- **WHEN** the analyst file's re-entry section is read
- **THEN** it names `approve.md`, when present, among the sources read
  before re-deriving — rulings that bind until the operator moves
  them — and treats absence as no rulings yet, never a defect

#### Scenario: A cause needs one moved variable
- **WHEN** the analyst file is read
- **THEN** it allows a causal comparison only when one variable moved,
  and otherwise requires the confound named or the cause dropped


#### Scenario: The sampled bullet is always fair to re-verify
- **WHEN** an anchor-current re-entry meets the lint's sampled
  spot-check
- **THEN** re-verifying that one bullet is permitted by contract and
  counts as the spot-check, never as a re-search

#### Scenario: A baked ruling carries the marker the gate reads
- **WHEN** the analyst reconciles a recorded operator ruling into its
  question's bullet
- **THEN** the bullet gains
  `RULED at approve (approve.md A<n>): <the standing reading>` with
  the original provisional text kept in place

### Requirement: The developer is stateless and evidence-bound
`agents/developer.md` SHALL instruct: consume exactly one task from
`routine-next`; context is the task file, the requirement's typed
contract section (`## Reproduction`/`## Touchpoints`/`## Contracts`/
`## Order` — the type's evidence, nothing else from the requirement),
the caffeine docs named in that task's own `## Caffeine` manifest, the
ticket's `calibration/<type>.md`, the task's own `briefing.md` — the slice it
implements inside, and the conventions in force there, never another slice's —
block/unblock files when present, the task's own `defect.md` when present — the account of why the task came back, which a developer redoing it MUST be able to read and not merely write, and
the two handles every scripted call needs — the ticket directory
(`ROUTINE_TICKET_DIR`, the `<ticket-dir>` argument of the refusal
scripts) and the target root (`TARGET`) — nothing else. It SHALL state
the precedence when sources conflict (task > target conventions, which the briefing's conventions in force sit with >
calibration > caffeine; earlier manifest topic first among caffeine
docs), SHALL record TDD evidence under the task's own
`## Scenario: <label>` headings — the label verbatim as the scenario
string, red and green bound to the identical label and identical
command (the audit demands a covering green per label and pairs the
evidence byte-exact) — with characterization tests kept out of the TDD
evidence — a `## Characterization: <label>` scenario is implemented in
the ordinary suite the gate runs and never routed through
`routine-tdd`, whose red phase would refuse it — It SHALL instruct a third TDD phase, `routine-tdd characterize`, for a `## Characterization: <label>` scenario, and SHALL state that a characterization the phase refuses is a defective spec rather than work — the claim that the scenario was already true belongs to whoever wrote it. It SHALL require the defect reason to state what was implemented and why it was coded that way, so the analyst patches from the developer's actual state rather than re-deriving it. It SHALL instruct that the implementation for a scenario is the narrowest one that greens it, and SHALL name the misreading: a later scenario in the same task passing the moment its test is written means too much was taken on an earlier scenario, not that a characterization was found. It SHALL bound the developer-gate loop with an off-ramp
(repeated gate failures or a fix that leaves the task's scope route to
the scripted refusals, never an unbounded retry), SHALL return a
defective spec by calling `routine-defect <ticket-dir> <reason>`
instead of improvising, and on blockage SHALL write `block.md` and call
`routine-block`. The Never list SHALL cover script-owned state, other
tasks, out-of-manifest caffeine, `runs/<app>/hooks/*`, and calling
`routine-done` (the protocol driver's move, not the developer's). It SHALL name a `routine-*` script's frontmatter head (or `routine-manual`) as the contract to read before calling — never a recalled contract. It SHALL distinguish the two ways a task is re-served, because they call for opposite first moves: an **interruption** leaves partial work behind and the task's text unchanged, while a **defect return** leaves no work and text the analyst has since amended — the first is met by reading the target's uncommitted diff, the second by reading `defect.md` and the amended task before writing anything. On a re-served task — one an interrupted session left in_progress — it SHALL re-record red and green under the identical scenario label and the identical command, because the audit pairs on the recorded string and a rename or a changed command records an unpaired green. On a re-served task it SHALL read the target's uncommitted diff before writing anything — the failing test it is about to write may already be there, left by the developer it replaced. It MAY delegate read-only mechanical surveys of `TARGET` to `agents/scout.md` where the host provides delegation — locating files, listing call sites, reporting which fixtures exist — under the same transcript-only rule the analyst works under: the delegate's prose is never load-bearing, and a claim the developer keeps it verifies by opening the path itself. The admission SHALL be permissive, never required: where no delegation exists the developer does the work itself and nothing in the loop changes. It SHALL carry a closed list of moves that are never delegated — every `routine-tdd` call, `routine-defect`, `routine-block`, and the judgment that a test failed for the right reason — because those write the record the audit replays.

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

#### Scenario: Mechanical work may be delegated, the record may not
- **WHEN** the agent file is read
- **THEN** it admits read-only delegation to `agents/scout.md` and names
  the closed list of moves that are never delegated

#### Scenario: The contracts name the characterization heading
- **WHEN** the analyst and developer agent files are read
- **THEN** the analyst emits `## Characterization:` for green-at-birth
  pins and the developer routes such scenarios to the ordinary suite by
  name

#### Scenario: The developer reads its slice's briefing
- **WHEN** the developer agent file is read
- **THEN** its closed context list admits the task's own `briefing.md`
  and ranks its conventions with the target's own

#### Scenario: The briefing carries the conventions in force
- **WHEN** the analyst agent file is read
- **THEN** it requires each briefing to carry the conventions in force
  for its slice

#### Scenario: A redoing developer can read why the task came back
- **WHEN** the agent file is read
- **THEN** its closed context list admits the task's own `defect.md`,
  and it separates a defect return from an interruption by what each
  leaves behind

#### Scenario: A false characterization is the spec's fault
- **WHEN** the agent file is read
- **THEN** it names `routine-tdd characterize` and states that a
  refused characterization is a defective spec rather than work

#### Scenario: A stolen red is named as such
- **WHEN** the agent file is read
- **THEN** it instructs the narrowest implementation per scenario and
  states that a later scenario passing at birth means an earlier one
  took too much rather than that a characterization was found

### Requirement: Agent files register as subagents
`agents/analyst.md`, `agents/developer.md`, and `agents/scout.md` SHALL
open with YAML frontmatter carrying `name` and `description`, so the
files are loadable as subagents by the host, and the `name` SHALL match
the filename stem. Each file SHALL also declare its `model` tier, chosen by who grades that role's output: work a script grades may run at a lower tier, while judgment only a human grades SHALL NOT be pinned below the driving session. Routine SHALL check only what it owns — that the field is present and its value is one this repository recognises — since no script here can observe which model answered. `agents/scout.md` SHALL declare the cheapest tier this repository recognises, since a scout's only grader is whether its caller could then do its job, and SHALL instruct one read-only survey per invocation whose output is never contract: it writes nothing to `TARGET`, records no telemetry, writes no ticket artifact, and calls no `routine-*` script.

#### Scenario: Frontmatter present
- **WHEN** any agent file is read
- **THEN** it opens with `---`, a `name:` matching its filename, and a
  non-empty `description:`

#### Scenario: The tier is declared, not remembered
- **WHEN** any agent file is read
- **THEN** its frontmatter declares a `model` whose value the repository
  recognises

#### Scenario: The scout reads and never writes
- **WHEN** `agents/scout.md` is read
- **THEN** it declares the haiku tier and forbids writing to the target,
  ticket artifacts, and every `routine-*` call

