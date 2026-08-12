## ADDED Requirements

### Requirement: The corpus spans concern and ecosystem namespaces
The caffeine corpus SHALL carry, beyond per-package topics, doc-only
concern topics (`testing/tdd`, `security/secrets`) loadable by any
ecosystem, and at least one application and one testing pair per
supported discovery ecosystem (`ruby/`, `js/`, `python/`). Sidecars
outside Ruby SHALL scan their ecosystem's file globs through the shared
library's `sidecar_include`.

#### Scenario: TDD judgment is loadable everywhere
- **WHEN** a task manifest in any ecosystem names `testing/tdd`
- **THEN** the doc loads and the developer gate passes it as doc-only
  evidence

#### Scenario: A js target has a real vocabulary
- **WHEN** `routine-caffeine-list` runs
- **THEN** it lists `js/express`, `js/vitest`, `python/django`, and
  `python/pytest` alongside the ruby topics
