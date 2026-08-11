## ADDED Requirements

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
