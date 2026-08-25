# spec-grammar Specification (delta)

## MODIFIED Requirements

### Requirement: Grounding is part of the ticket grammar
Every ticket SHALL carry a ticket-level `grounding.md` holding the
evidence behind the contract: a `## Evidence` section whose every
non-empty line matches `- <path> — <claim>` — the claim stating what
the file was found to contain or do, with `- <path> — ruled out:
<reason>` the blessed form for surveyed-and-rejected paths; a
`## Alternatives` section, an `## Assumptions` section, and a `## Questions` section each holding
at least one `- ` bullet, with the literal floor `- none — <why
nothing qualifies>` as the considered opt-out. `bin/routine-spec-lint`
SHALL check every Evidence line individually (one well-formed bullet
never masks a malformed sibling) and, once any task carries a
`defect.md`, SHALL additionally require a `## Reconciliation` line for
each defective task id matching `- <tid> — <what the defect
invalidated>`, matched without interpreting the id as a pattern. All
checks are mechanical form checks; the linter never judges the claim's
content — a false claim is the approve reader's catch, not the lint's. The file SHALL also carry a `Grounded-at: <sha>` header line (column 0, a 40-hex commit id — the target's HEAD when the evidence was gathered, obtained by reading the target, never writing it); the lint checks presence and form only.
Every non-floor `## Questions` bullet SHALL carry its provisional reading in the form `- <question> — provisional: <reading>` with a non-empty reading, checked per line exactly as Evidence is — the reading is the load-bearing half, the words the decomposition was built on — while the `- none — <why>` floor stays exempt.

#### Scenario: Missing grounding fails the lint
- **WHEN** a ticket has no `grounding.md`
- **THEN** the lint exits non-zero naming the file

#### Scenario: Empty evidence fails the lint
- **WHEN** `grounding.md` exists but `## Evidence` has no bullet
- **THEN** the lint exits non-zero naming the section

#### Scenario: A defect return demands reconciliation
- **WHEN** `briefings/01-x/tasks/02-y/defect.md` exists and
  `grounding.md` has no `## Reconciliation` line naming `01-02`
- **THEN** the lint exits non-zero naming the task id

#### Scenario: A claim-less evidence bullet fails
- **WHEN** an `## Evidence` line reads `- app/models/user.rb` with no
  ` — <claim>` part
- **THEN** the lint exits non-zero naming the line and the required
  form

#### Scenario: A bare id does not reconcile
- **WHEN** the only occurrence of a defective task id in
  `## Reconciliation` is inside other text (not a `- <tid> — <text>`
  line)
- **THEN** the lint exits non-zero naming the task id

#### Scenario: Silent Assumptions fail
- **WHEN** `## Assumptions` carries no bullet
- **THEN** the lint exits non-zero naming the section and the
  `- none — <why nothing qualifies>` floor

#### Scenario: A missing or malformed anchor fails
- **WHEN** `grounding.md` has no `Grounded-at:` line, or its value is
  not a 40-hex commit id
- **THEN** the lint exits non-zero naming the line and the form

#### Scenario: Silent Questions fail
- **WHEN** `## Questions` carries no bullet
- **THEN** the lint fails naming the `- none — <why nothing qualifies>`
  floor, so a ticket with nothing to ask says so rather than omitting the
  section

#### Scenario: A question separates intent from derivation
- **WHEN** a grounding records a claim the target has no opinion on —
  product intent rather than a reading of the code
- **THEN** it belongs under `## Questions` with the provisional reading
  the decomposition was built on, not under `## Assumptions`, whose
  entries are citable to a path in the target


#### Scenario: A question without its provisional reading fails
- **WHEN** a non-floor `## Questions` bullet carries no
  ` — provisional: <reading>` part
- **THEN** the lint exits non-zero naming the line and the required
  form
