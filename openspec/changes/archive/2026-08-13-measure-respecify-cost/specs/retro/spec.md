# retro Specification (delta)

## ADDED Requirements

### Requirement: Retro reports the re-specify cost
The report SHALL include a re-specify cost section keyed by app and
ticket (never pairing across apps): specify episodes as one plus the
ticket's `spec.defective` count, total and worst-episode failed
`spec.lint` runs counted with the analyst gate's exact semantics (the
per-episode counter resets on `spec.defective`), and the seconds from
each `spec.defective` to the next passing `spec.lint` — a defect with
no later passing lint SHALL print as unrecovered. Tickets with no
episodes beyond the first and no failed lints SHALL NOT appear. The
section is computed from existing telemetry on demand; the retro
writes nothing.

#### Scenario: A defect return's cost is visible
- **WHEN** a ticket records a failed lint, a `spec.defective`, and a
  later passing `spec.lint`
- **THEN** the section shows two episodes, the failed-lint counts, and
  the defect-to-recovery seconds for that app and ticket

#### Scenario: An unrecovered defect is named
- **WHEN** a ticket records `spec.defective` with no later passing
  `spec.lint`
- **THEN** the section prints that ticket as unrecovered

#### Scenario: Cost never crosses apps
- **WHEN** two apps hold tickets with the same id
- **THEN** each app's cost line reflects only its own telemetry
