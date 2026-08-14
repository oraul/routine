# guidance Specification

## Purpose

The session contract: what every Claude Code session working on this
repository must know before touching anything, loaded automatically via
CLAUDE.md.

## Requirements

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
script-owned state (`index.tsv`, `telemetry.jsonl`). It SHALL also state the delegation model the loop runs on: that each agent file declares a `model` tier, that the tier follows who grades that role's output, that the record — every `routine-tdd` call, the refusal scripts, and the judgment that a test is red — is never delegated, and that routine checks a tier is declared and recognised rather than which model answered. Every requirement this specification places on `CLAUDE.md` and `README.md` SHALL be enforced by a test, so the contract cannot drift silently; those tests SHALL pin load-bearing terms rather than prose sentences, since line wrapping breaks sentence matching.

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

### Requirement: The README presents the repository's public face
`README.md` SHALL open with the thesis, SHALL state what routine is and how
the operational loop runs (the five phases and the two agents that drive
them, plus the read-only scout they may delegate reading to), SHALL list
the three skills (`/routine`, `/unblock`, `/caffeinate`), SHALL map the
spec'd capabilities with `openspec/specs/` as the durable record, SHALL
carry install and develop instructions (including `bin/routine-selfcheck`),
and SHALL point to the release convention.

#### Scenario: Public face present
- **WHEN** `README.md` is read
- **THEN** it presents the thesis, the loop, the three skills, the
  capability map, install and develop instructions, and the release pointer

#### Scenario: The scout is visible on the public face
- **WHEN** `README.md` is read
- **THEN** it distinguishes the two phase-driving agents from the
  read-only scout

