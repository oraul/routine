# guidance Specification (delta)

## MODIFIED Requirements

### Requirement: The conventions state the runtime boundary as invariant plus seam

`openspec/project.md` SHALL state the determinism boundary over
deterministic executables with exit-code semantics rather than any one
implementation language, and SHALL state the runtime law as a seam: the
operational core runs with zero setup in the target project, the
user-editable seam — app hooks and caffeine sidecars — stays bash 3.2 +
BSD/GNU coreutils, and no interpreter runtime (Node/Ruby/Python) enters
the operational path on either side of the seam. It SHALL name the
core's sanctioned destination — a single statically linked binary,
built locally from the checkout so every user runs code they can
read, carrying its own commit provenance — and SHALL state the
narrowed setup honestly: zero setup beyond the Go toolchain that
builds it, while remaining true of the bash core that runs today. These statements SHALL
be enforced by tests pinning load-bearing terms, the same way this
capability pins the rest of the guidance.
It SHALL further state which side of the seam a file is on by location
rather than by language: everything under `bin/` and `lib/` is core and
destined for the binary, the seam is exactly
`runs/<app>/hooks/<gate>.sh` and the caffeine sidecars, and a core
script written in bash today records how far the migration has got
rather than a claim about which side it sits on — both sides are bash
scripts, so language identifies neither. That statement SHALL be
pinned by tests in the same way.

#### Scenario: The boundary names the invariant, not the language

- **WHEN** `openspec/project.md` is read
- **THEN** its determinism boundary binds deterministic executables with
  exit-code semantics, and no law restricts the core to bash

#### Scenario: The seam stays scripts on both sides

- **WHEN** `openspec/project.md` is read
- **THEN** it states that hooks and sidecars stay bash 3.2 and that no
  interpreter runtime enters the operational path on either side of the
  seam

#### Scenario: A file's side is decided by where it lives

- **WHEN** `openspec/project.md` is read
- **THEN** it places `bin/` and `lib/` on the core side and names the
  seam as exactly the app hooks and caffeine sidecars

#### Scenario: Bash today is not a seam claim

- **WHEN** a core script is written in bash
- **THEN** `openspec/project.md` states that this records how far the
  migration has got and never that the script belongs to the seam
