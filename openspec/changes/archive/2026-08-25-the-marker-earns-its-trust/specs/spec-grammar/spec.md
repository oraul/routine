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
A non-floor `## Questions` bullet carrying the ruled marker `RULED at approve (approve.md A<n>)` SHALL cite an answer the record holds: the lint fails the bullet when the ticket has no `approve.md`, or when no entry in it records an `A<n>:` line for the cited index — because `routine-approve` lifts its refusal on the marker's strength, and a path a gate trusts must be harnessed — while attribution and agreement stay judgments: the lint checks that the cited ruling exists, never that it says what the marker claims.
Whenever `## Evidence` holds bullets, `bin/routine-spec-lint` SHALL additionally name one sampled Evidence bullet as the spot-check to re-verify — selected deterministically from the file's own bytes, never by the author, so verification cannot be steered toward convenient claims — reported on stdout and never gating: the sample line changes no exit code. The lint stays form-only; the sample is a selection, not a judgment.

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

#### Scenario: A spot-check sample is named without gating
- **WHEN** the lint runs over a grounding whose `## Evidence` holds
  bullets
- **THEN** it names exactly one of them as the sampled spot-check and
  the exit code is what the form checks alone decide

#### Scenario: A marker citing a recorded ruling passes
- **WHEN** a bullet carries `RULED at approve (approve.md A2): <the
  standing reading>` and some entry in the ticket's `approve.md`
  records an `A2:` line
- **THEN** the lint passes the bullet

#### Scenario: A marker citing no recorded ruling fails
- **WHEN** a bullet carries the ruled marker but the ticket has no
  `approve.md`, or no entry records the cited `A<n>:` line
- **THEN** the lint exits non-zero naming the bullet and the ruling it
  could not find
