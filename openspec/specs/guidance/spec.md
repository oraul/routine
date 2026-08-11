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
script-owned state (`index.tsv`, `telemetry.jsonl`).

#### Scenario: Contract present
- **WHEN** `CLAUDE.md` is read
- **THEN** it states the spec-first rule, the sensitive-data hard rules,
  both pointers, the three commands, the TDD rule, and the script-owned
  state prohibition

#### Scenario: Sessions start from the contract
- **WHEN** a Claude Code session opens this repository
- **THEN** `CLAUDE.md` is what tells it how to work before it reads
  anything else

### Requirement: The README presents the repository's public face
`README.md` SHALL open with the thesis, SHALL state what routine is and how
the operational loop runs (the five phases and the two agents), SHALL list
the three skills (`/routine`, `/unblock`, `/caffeinate`), SHALL map the
spec'd capabilities with `openspec/specs/` as the durable record, SHALL
carry install and develop instructions (including `bin/routine-selfcheck`),
and SHALL point to the release convention.

#### Scenario: Public face present
- **WHEN** `README.md` is read
- **THEN** it presents the thesis, the loop, the three skills, the
  capability map, install and develop instructions, and the release pointer
