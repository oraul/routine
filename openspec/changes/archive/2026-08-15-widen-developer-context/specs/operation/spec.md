# operation Specification (delta)

## MODIFIED Requirements

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
the human and `/caffeinate` — never an invented topic name. It SHALL name a `routine-*` script's frontmatter head (or `routine-manual`) as the contract to read before calling — never a recalled contract. Its re-entry sources SHALL include the ticket's `lint.log` alongside `grounding.md` and the `defect.md` files. Its grounding instruction SHALL describe Evidence bullets as claim-bearing — `- <path> — <what the file was found to contain or do>` — with the ruled-out form and the `- none — <why>` floors for Alternatives and Assumptions. Its re-entry rule SHALL be anchor-first: Evidence bullets are current when `Grounded-at` equals the target's current HEAD and the worktree is clean; otherwise only bullets whose paths the diff against the worktree (plus untracked files) names are re-verified, and the anchor is refreshed — never a full re-search. Its context handles SHALL be named: `TARGET`, the repository it grounds against, and `ROUTINE_TICKET_DIR`, where its artifacts land. It MAY use cheap read-only scouts to survey the target when the host provides delegation — scout prompts are transcript-only and never load-bearing; every accepted scout claim SHALL land as an Evidence bullet naming a real path, and unverified scout claims SHALL go under `## Assumptions` — however evidence is gathered, only the ticket artifacts are contract. It SHALL name `agents/scout.md` as the file those scouts are, rather than describing an anonymous capability.

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
ticket's `calibration/<type>.md`, the task's own `briefing.md` — the slice it
implements inside, and the conventions in force there, never another slice's —
block/unblock files when present, and
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
`routine-tdd`, whose red phase would refuse it — SHALL bound the developer-gate loop with an off-ramp
(repeated gate failures or a fix that leaves the task's scope route to
the scripted refusals, never an unbounded retry), SHALL return a
defective spec by calling `routine-defect <ticket-dir> <reason>`
instead of improvising, and on blockage SHALL write `block.md` and call
`routine-block`. The Never list SHALL cover script-owned state, other
tasks, out-of-manifest caffeine, `runs/<app>/hooks/*`, and calling
`routine-done` (the protocol driver's move, not the developer's). It SHALL name a `routine-*` script's frontmatter head (or `routine-manual`) as the contract to read before calling — never a recalled contract. On a re-served task — one an interrupted session left in_progress — it SHALL re-record red and green under the identical scenario label and the identical command, because the audit pairs on the recorded string and a rename or a changed command records an unpaired green. On a re-served task it SHALL read the target's uncommitted diff before writing anything — the failing test it is about to write may already be there, left by the developer it replaced. It MAY delegate read-only mechanical surveys of `TARGET` to `agents/scout.md` where the host provides delegation — locating files, listing call sites, reporting which fixtures exist — under the same transcript-only rule the analyst works under: the delegate's prose is never load-bearing, and a claim the developer keeps it verifies by opening the path itself. The admission SHALL be permissive, never required: where no delegation exists the developer does the work itself and nothing in the loop changes. It SHALL carry a closed list of moves that are never delegated — every `routine-tdd` call, `routine-defect`, `routine-block`, and the judgment that a test failed for the right reason — because those write the record the audit replays.

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
