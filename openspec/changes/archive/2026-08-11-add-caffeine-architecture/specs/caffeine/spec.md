## ADDED Requirements

### Requirement: Doc-only topics carry judgment without a sidecar
A caffeine topic MAY ship only its `caffeine/<topic>.md` when its rules are
judgment rather than mechanics; such a topic SHALL be legal in any task
manifest. The `architecture/` namespace SHALL hold language-agnostic
doc-only topics, seeded with `architecture/oop.md` (object-oriented design)
and `architecture/hexagonal.md` (ports-and-adapters boundaries).

#### Scenario: Architecture seeds exist
- **WHEN** the repository is checked
- **THEN** `caffeine/architecture/oop.md` and
  `caffeine/architecture/hexagonal.md` exist and carry developer guidance

#### Scenario: Doc-only topic in a manifest
- **WHEN** a task manifest names `architecture/oop`
- **THEN** the developer loads its doc and the developer gate passes
  without running any sidecar for it
