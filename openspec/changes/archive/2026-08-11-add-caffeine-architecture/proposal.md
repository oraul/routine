## Why

Caffeine topics are technology-scoped (`ruby/rails`), but the strongest
guidance a developer can load is often architectural — object-oriented
design, hexagonal boundaries — and it applies in any language. Architecture
rules are judgment, not greps, which exposes a gap: the developer gate
currently rejects any manifest topic without a sidecar, making doc-only
topics illegal.

## What Changes

- Make **doc-only topics legal**: the developer gate runs `caffeine/<topic>.sh`
  when it exists; when only `caffeine/<topic>.md` exists it logs one line
  and passes (the developer loads the doc); a topic with neither file still
  fails naming both paths.
- Add the language-agnostic `architecture/` namespace with two seed docs:
  `architecture/oop.md` (object-oriented design judgment) and
  `architecture/hexagonal.md` (ports-and-adapters boundaries). The analyst
  names them in a task's manifest like any topic.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `caffeine`: doc-only topics become part of the contract, with the
  `architecture/` seeds.
- `gates`: the developer baseline's manifest resolution gains the doc-only
  path.

## Impact

- Modified: `bin/routine-gate`, `test/gate.bats`, `skills/caffeinate/SKILL.md`
  (one clarifying line). New: `caffeine/architecture/{oop,hexagonal}.md`.
