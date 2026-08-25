# guidance Specification (delta)

## MODIFIED Requirements

### Requirement: CLAUDE.md states the session contract
The repository SHALL provide a `CLAUDE.md` that states, at minimum: the
spec-first rule (no behavior change before a validated OpenSpec change —
never vibe); the hard rules on sensitive data (no session URLs, tokens,
personal names, account identifiers, or credentials in any commit, PR, or
artifact); a pointer to the Laws in `openspec/project.md` and the
conventions in `CONTRIBUTING.md`; the mechanical commands
(`bin/routine-selfcheck`, `npx @fission-ai/openspec validate --strict`,
`bin/routine-release-check`); the TDD rule (red → green, one tasks.md
checkbox = one commit); and the prohibition on directly editing
script-owned state (`index.tsv`, `telemetry.jsonl`). It SHALL also state the delegation model the loop runs on: that each agent file declares a `model` tier, that the tier follows who grades that role's output, that the record — every `routine-tdd` call, the refusal scripts, and the judgment that a test is red — is never delegated, and that routine checks a tier is declared and recognised rather than which model answered. Every requirement this specification places on `CLAUDE.md` and `README.md` SHALL be enforced by a test, so the contract cannot drift silently; those tests SHALL pin load-bearing terms rather than prose sentences, since line wrapping breaks sentence matching. It SHALL also state the prediction rule: every claim a session makes is either measured — saying what ran — or a prediction — naming the evidence that settles it — and never an unlabelled third thing, because a forecast wearing a measurement's sentence is how a wrong count reaches a published record and how unverified relays reach the operator as fact; the release record's "script that would decide it" and the grounding's "provisional" reading are this same rule already enforced in two artifacts, generalised to the session that drives.
It SHALL also carry the lifecycle motto — evidence tries to kill the claim; what survives is knowledge — stated where the session reads before working, because every rule above is an instance of it and a session that has read only the rules can still run validation as a search for agreement.
#### Scenario: Contract present
- **WHEN** `CLAUDE.md` is read
- **THEN** it states the spec-first rule, the sensitive-data hard rules,
  both pointers, the three commands, the TDD rule, and the script-owned
  state prohibition

#### Scenario: Sessions start from the contract
- **WHEN** a Claude Code session opens this repository
- **THEN** `CLAUDE.md` is what tells it how to work before it reads
  anything else

#### Scenario: The delegation model is in the contract
- **WHEN** `CLAUDE.md` is read
- **THEN** it names the declared tiers, the grader rule that picks them,
  the never-delegate-the-record boundary, and the limit that routine
  checks the declaration rather than the answering model

#### Scenario: The guidance docs are pinned, not trusted
- **WHEN** the test suite runs
- **THEN** a test reads `CLAUDE.md` and `README.md` and asserts the terms
  this specification requires
#### Scenario: The prediction rule is in the contract
- **WHEN** `CLAUDE.md` is read
- **THEN** it states that a claim is measured or a prediction, that a
  prediction names what settles it, and that an unlabelled third thing
  is refused

#### Scenario: The motto is in the contract
- **WHEN** `CLAUDE.md` is read
- **THEN** it carries the motto naming what evidence does to a claim
  and what survival earns

## ADDED Requirements

### Requirement: The conventions carry the motto and the grounding pillars
`openspec/project.md` SHALL carry the lifecycle motto beside its
epigraph and SHALL name the seven grounding pillars — provenance,
refutation first, independent instruments, freshness, symmetric
recording, confound honesty, and exercised roads — each with a one-line
obligation, so records, retros, and reviews cite a pillar by name
instead of re-deriving the standard. It SHALL state that a pillar is
vocabulary and never a gate: the script that enforces one is earned
separately, from retro evidence, like every abstraction in this
repository. These requirements SHALL be enforced by tests pinning
load-bearing terms, the same way this capability pins the rest of the
guidance.

#### Scenario: The pillars are named with their obligations
- **WHEN** `openspec/project.md` is read
- **THEN** it carries the motto and names all seven pillars, each with
  its obligation

#### Scenario: Naming a pillar never substitutes for a script
- **WHEN** `openspec/project.md` is read
- **THEN** it states that a pillar is vocabulary, never a gate, and that
  enforcement is earned separately from retro evidence
