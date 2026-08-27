# conventions Specification (delta)

## MODIFIED Requirements

### Requirement: A delta carries what it modifies
`bin/routine-change-check <change-id>` SHALL judge every requirement
under a `## MODIFIED Requirements` section of the change's deltas
against the live spec it modifies: each line of the live requirement —
heading to next heading, blank lines exempt — must survive into the
delta's version, either as an identical line or inside an extended
one, and the check SHALL exit non-zero naming the capability, the
requirement, and the first line the delta lost. A requirement the
delta claims to modify that the live spec does not hold SHALL also
fail by name. `## ADDED Requirements` sections carry nothing and are
exempt. A missing or unknown change id SHALL exit 2 with usage. Every
run SHALL emit one `harness.change` telemetry line, and the road
SHALL be declared in `lib/roads.txt`. The check runs before sync —
after sync the live spec already contains the delta and the
comparison decides nothing — and it hunts the dropped-line class: a
line whose text happens to survive inside an unrelated line can
escape it, so byte-exactness outside stated additions stays the
author's diff, while the silent loss that already shipped once
becomes an exit code. A removal the delta declares SHALL NOT count as
a loss: a `## Removed Lines` section in the delta file, holding one
`- <text>` bullet per deliberately dropped live line, exempts exactly
those lines and no others, and the check SHALL still refuse every
undeclared loss in the same run. The declaration is a statement of
intent the author writes and the reviewer reads — the check decides
only whether a loss was declared, never whether the removal was
wise.

#### Scenario: A complete carry passes
- **WHEN** a modified requirement's delta holds every live line,
  some extended in place, plus its additions
- **THEN** the check exits 0

#### Scenario: A dropped line is named
- **WHEN** the delta's version of a modified requirement lost one
  live line
- **THEN** the check exits non-zero naming the capability, the
  requirement, and the lost line

#### Scenario: Modifying a requirement that does not exist fails
- **WHEN** a delta's MODIFIED section names a requirement absent from
  the live spec
- **THEN** the check exits non-zero naming it

#### Scenario: An unknown change id is a usage error
- **WHEN** the check runs with no argument or an id no change
  directory holds
- **THEN** it exits 2 with usage

#### Scenario: A declared removal is not a loss
- **WHEN** a modified requirement's delta drops a live line and the
  delta file's `## Removed Lines` section carries that line as a
  bullet
- **THEN** the check exits 0

#### Scenario: An undeclared loss still fails beside a declared one
- **WHEN** one dropped line is declared and another is not
- **THEN** the check exits non-zero naming only the undeclared line
