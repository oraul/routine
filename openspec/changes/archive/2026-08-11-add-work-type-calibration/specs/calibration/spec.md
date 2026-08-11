## Purpose

Work-shape awareness: every ticket declares whether it is a bug, a feature
in existing code, a greenfield feature, or an epic, and both agents load
that type's calibration before working.

## ADDED Requirements

### Requirement: Every requirement declares its work type
`requirement.md` SHALL contain a line `Type: <type>` where `<type>` is one
of `bug`, `feature`, `greenfield`, `epic`. `routine-spec-lint` SHALL reject
a missing or unknown type naming the valid values.

#### Scenario: Unknown type rejected
- **WHEN** `requirement.md` declares `Type: refactor`
- **THEN** the lint exits non-zero naming the four valid types

### Requirement: Type-specific structure is enforced mechanically
For `Type: bug`, `requirement.md` SHALL contain a `## Reproduction`
section. For `Type: epic`, the ticket SHALL contain at least two briefing
directories. Other types add no structural rule.

#### Scenario: Bug without reproduction
- **WHEN** a `Type: bug` requirement lacks `## Reproduction`
- **THEN** the lint exits non-zero naming the missing section

#### Scenario: Single-briefing epic
- **WHEN** a `Type: epic` ticket has one briefing
- **THEN** the lint exits non-zero saying an epic decomposes into at least
  two briefings

### Requirement: Calibration docs exist per type and agents load them
The repository SHALL provide `calibration/<type>.md` for each of the four
types, containing decomposition guidance for the analyst and posture
guidance for the developer. The analyst SHALL read the declared type's
calibration before decomposing; the developer's closed context SHALL
include its ticket's calibration doc.

#### Scenario: Doc per type
- **WHEN** the repository is checked
- **THEN** `calibration/bug.md`, `calibration/feature.md`,
  `calibration/greenfield.md`, and `calibration/epic.md` exist
