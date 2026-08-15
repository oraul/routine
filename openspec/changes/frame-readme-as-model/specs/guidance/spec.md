# guidance Specification (delta)

## MODIFIED Requirements

### Requirement: The README hands over the model, not a product
`README.md` SHALL open with the thesis, SHALL state what routine is and how
the operational loop runs (the five phases and the two agents that drive
them, plus the read-only scout they may delegate reading to), SHALL list
the three skills (`/routine`, `/unblock`, `/caffeinate`), SHALL map the
spec'd capabilities with `openspec/specs/` as the durable record, SHALL
carry install and develop instructions (including `bin/routine-selfcheck`),
and SHALL point to the release convention. It SHALL open by naming routine a working model of a spec-first loop rather than a plugin to adopt, because the value on offer is the model and a reader who installs it expecting a product will judge it an unfinished one. It SHALL carry a concept pipeline whose columns are the phase, the actor answerable for it, and what stops the run there — authority and failure, not dataflow, since who decides is the part that transfers. It SHALL name what carries into another project (script-owned state, evidence outliving the session, a gate whose exit code is the decision, a record that is never delegated) apart from what is this repository's accident (bash, bats, the specific script names). Install instructions SHALL remain, positioned below the model rather than as the call to action. The README SHALL NOT claim the loop is proven in production.

#### Scenario: Public face present
- **WHEN** `README.md` is read
- **THEN** it presents the thesis, the loop, the three skills, the
  capability map, install and develop instructions, and the release pointer

#### Scenario: The scout is visible on the public face
- **WHEN** `README.md` is read
- **THEN** it distinguishes the two phase-driving agents from the
  read-only scout


#### Scenario: The opening names a model
- **WHEN** `README.md` is read
- **THEN** its first paragraphs present routine as a model to learn from
  rather than a plugin to install

#### Scenario: The pipeline shows who decides
- **WHEN** the concept pipeline is read
- **THEN** each phase names the actor answerable for it and what stops
  the run there

#### Scenario: Transfer is separated from accident
- **WHEN** `README.md` is read
- **THEN** it distinguishes the separations worth copying from the bash
  and bats this repository happens to use
