## ADDED Requirements

### Requirement: The conventions state the runtime boundary as invariant plus seam

`openspec/project.md` SHALL state the determinism boundary over
deterministic executables with exit-code semantics rather than any one
implementation language, and SHALL state the runtime law as a seam: the
operational core runs with zero setup in the target project, the
user-editable seam — app hooks and caffeine sidecars — stays bash 3.2 +
BSD/GNU coreutils, and no interpreter runtime (Node/Ruby/Python) enters
the operational path on either side of the seam. It SHALL name the
core's sanctioned destination — a single statically linked binary,
cross-compiled per release, carrying its own commit provenance — while
remaining true of the bash core that runs today. These statements SHALL
be enforced by tests pinning load-bearing terms, the same way this
capability pins the rest of the guidance.

#### Scenario: The boundary names the invariant, not the language

- **WHEN** `openspec/project.md` is read
- **THEN** its determinism boundary binds deterministic executables with
  exit-code semantics, and no law restricts the core to bash

#### Scenario: The seam stays scripts on both sides

- **WHEN** `openspec/project.md` is read
- **THEN** it states that hooks and sidecars stay bash 3.2 and that no
  interpreter runtime enters the operational path on either side of the
  seam
