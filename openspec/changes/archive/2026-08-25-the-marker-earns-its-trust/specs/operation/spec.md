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
the human and `/caffeinate` — never an invented topic name. It SHALL name a `routine-*` script's frontmatter head (or `routine-manual`) as the contract to read before calling — never a recalled contract. Its re-entry sources SHALL include the ticket's `lint.log` alongside `grounding.md` and the `defect.md` files. Its grounding instruction SHALL describe Evidence bullets as claim-bearing — `- <path> — <claim>`, one bullet per target file read or probe executed against it, the claim stating what the file was found to contain or do, or what the probe ran and returned — with the ruled-out form and the `- none — <why>` floors for Alternatives and Assumptions. Its re-entry rule SHALL be anchor-first: Evidence bullets are current when `Grounded-at` equals the target's current HEAD and the worktree is clean; otherwise only bullets whose paths the diff against the worktree (plus untracked files) names are re-verified, and the anchor is refreshed — never a full re-search. Its context handles SHALL be named: `TARGET`, the repository it grounds against, and `ROUTINE_TICKET_DIR`, where its artifacts land. It MAY use cheap read-only scouts to survey the target when the host provides delegation — scout prompts are transcript-only and never load-bearing; every accepted scout claim SHALL land as an Evidence bullet naming a real path, and unverified scout claims SHALL go under `## Assumptions` — however evidence is gathered, only the ticket artifacts are contract. It SHALL name `agents/scout.md` as the file those scouts are, rather than describing an anonymous capability. On re-entry after a defect return it SHALL write the patch account into the returned task itself — what the defect invalidated and what changed in response — because the `## Reconciliation` line it writes lives in `grounding.md`, which is outside the developer's closed context list, and an account the reader cannot reach is not an account. It SHALL read the verbatim failure `routine-tdd characterize` captured for a task returned that way, rather than a paraphrase of it. It SHALL describe the characterization phase as the developer's contract builds it: a `## Characterization: <label>` scenario's birth claim is proven with `routine-tdd characterize`, recording a `tdd.characterize` line and no red/green pair — never that the developer records no TDD evidence at all, which contradicts the phase and which a ticket written to it cannot satisfy. It SHALL separate a **derivation** — a claim citable to a path and a line in the target, such as the codebase's refusal idiom or its guard order — from a **question only the operator can answer**, a claim about product intent on which the target has no opinion at any depth, such as which way money rounds or whether a boundary value is a no-op or a mistake. Derivations SHALL stay under `## Assumptions`; questions SHALL be recorded under `## Questions` with the provisional reading the decomposition was built on, so the loop never stalls waiting for an answer while the override stays cheap and the decision stays attributed to whoever made it. Its artifacts SHALL keep a probe apart from a forecast: a claim it verified by executing against the target says so, and a claim about what unwritten code or an unrun phase will do names the grader that settles it — `routine-tdd red` grades "this scenario will be red", `routine-tdd characterize` grades "this was already true", the developer gate grades the rest — because a re-entering analyst once presented a simulation of unwritten code in the same voice as ten verified probes, and a reader could not tell which they were holding.
Its validation SHALL be refutation-first: before filing, it attempts once to refute each briefing's load-bearing claim that the target as it stands can refute — running the probe that would prove the decomposition wrong — and records the attempt and its outcome as an Evidence bullet in the section's enforced line form even when the claim survives, because support-gathering is not validation and the invented-intent and simulated-probe incidents both travelled through claims nobody had tried to break. A load-bearing claim that is a forecast is never probed in advance — its refutation is the grader it already names — and on re-entry the anchor rule governs: an anchor-current refutation bullet stands, and only a new or amended claim, or one whose cited paths the diff names, earns a fresh attempt. Its probes SHALL be recorded symmetrically: every probe it executed appears in its artifacts, inconvenient results at the same fidelity as convenient ones — an omitted miss is a curated record, and a curated record is how a false conclusion arrives well-evidenced. A recorded probe SHALL quote the command that ran and the decisive output it returned inside its bullet's claim — the Evidence line form admits no fenced block — so a reader can re-run what ran. Its re-entry sources SHALL include the ticket's `approve.md` when present — the operator's recorded rulings, each of which binds until the operator moves it; absence means approve has not yet run and never means a defect, because every recorded proceed writes the file — alongside `grounding.md`, `lint.log`, and the `defect.md` files. When it bakes a recorded ruling into its question's bullet, the reconciliation SHALL append the ruled marker to that bullet — `RULED at approve (approve.md A<n>): <the standing reading>`, the bullet's original provisional text kept in place — because the marker is what lets the approve gate stop demanding a re-answer for a ruling that already binds, and a marker in any other words is invisible to the gate that reads it. Before baking, an override's ruling is validated like any load-bearing claim: the reconciliation SHALL attempt once to refute the ruling's implementability where the target as it stands can refute it — running the probe that would prove the ruling cannot be built as written — recording the attempt as an Evidence bullet either way, and a ruling the probe refutes goes back to the operator with the probe quoted rather than into the artifacts, because a ruling and a requirement that could not both be true were once discovered by the developer mid-build instead of at reconciliation, and the amendment cost a fourth proceed. Its comparisons SHALL claim a cause only when one variable moved between the things compared; otherwise the confound — what else moved — is named, or the causal claim is dropped. Its trust in an anchor-current record SHALL be a default and never a prohibition: the lint names one sampled Evidence bullet per run — chosen by the file's own bytes, never by the author — and re-verifying that sample never counts as a re-search, because a curated record survives only where nothing is ever re-run.
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


#### Scenario: A ruling is probed before it is baked
- **WHEN** the analyst reconciles an override whose implementability
  the target as it stands can refute
- **THEN** the refutation attempt is recorded as an Evidence bullet,
  and a refuted ruling returns to the operator with the probe quoted
  instead of being baked into the artifacts
