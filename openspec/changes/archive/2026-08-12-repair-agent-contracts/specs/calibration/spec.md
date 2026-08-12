# calibration Specification (delta)

## MODIFIED Requirements

### Requirement: Type-specific structure is enforced mechanically
For `Type: bug`, `requirement.md` SHALL contain a `## Reproduction`
section; for `Type: feature`, a `## Touchpoints` section; for
`Type: greenfield`, a `## Contracts` section; for `Type: epic`, an
`## Order` section, and the ticket SHALL contain at least two briefing
directories. `routine-spec-lint` SHALL reject each missing typed
section naming it (the contract capability owns the section
definitions; this requirement agrees with it — no type is
structure-free).

#### Scenario: Bug without reproduction
- **WHEN** a `Type: bug` requirement lacks `## Reproduction`
- **THEN** the lint exits non-zero naming the missing section

#### Scenario: Single-briefing epic
- **WHEN** a `Type: epic` ticket has one briefing
- **THEN** the lint exits non-zero saying an epic decomposes into at least
  two briefings

#### Scenario: Feature without touchpoints
- **WHEN** a `Type: feature` requirement lacks `## Touchpoints`
- **THEN** the lint exits non-zero naming the missing section
