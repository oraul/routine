## MODIFIED Requirements

### Requirement: Sidecars are mechanical checkers with gate semantics
Each caffeine sidecar (`caffeine/<lang>/<topic>.sh`) SHALL check the code
under `TARGET` (default: current directory) against 3–5 mechanical,
grep-able rules declared through the shared library `lib/sidecar.sh` as
`check <id> "<rule>" '<pattern>' [scope]`. Every hit SHALL print as
`caffeine/<ns>/<topic>[<id>] <rule>: <file>:<line>:<content>` — the
bracketed id is the parse handle, the rule string the canonical name.
Scanning SHALL exclude vendored directories (`vendor`, `node_modules`,
`tmp`, `coverage`) by directory, never by filtering hit lines. The
sidecar SHALL exit 0 only when no rule matches, SHALL exit 2 when the
scan itself fails (a broken instrument is never a clean repo), and
SHALL judge nothing a grep cannot see — judgment guidance lives in the
paired `.md`.

#### Scenario: Clean target passes
- **WHEN** the target contains no rule violations
- **THEN** the sidecar exits 0

#### Scenario: Violation named
- **WHEN** a target file trips a rule
- **THEN** the sidecar exits non-zero printing its id, rule, file, and
  line

#### Scenario: Vendored content cannot hide a hit
- **WHEN** a violating line's content mentions `/vendor/` but the file
  lives under `app/`
- **THEN** the sidecar still reports it, and files under `vendor/` are
  skipped by directory

#### Scenario: A broken instrument is loud
- **WHEN** the scan itself errors (an invalid pattern or unreadable
  tree)
- **THEN** the sidecar exits 2, not 0

### Requirement: Every topic satisfies the topic contract
Every caffeine topic SHALL live at depth two (`caffeine/<ns>/<topic>`)
and open with the H1 `# caffeine: <ns>/<topic>` matching its path. Every
`.md` SHALL carry, immediately after the H1, the metadata comment lines
`caffeine-topic` (matching the path), `caffeine-applies` (a non-empty
version constraint), `caffeine-source` (a non-empty upstream reference),
and `caffeine-reviewed` (an ISO date). Every `.sh` SHALL carry
`caffeine-topic`, `caffeine-applies`, and `caffeine-reviewed` header
comments, SHALL have a sibling `.md`, SHALL resolve `TARGET` with a
`$PWD` default, set `-u`, and end `exit "$fails"`, SHALL declare between
3 and 5 `check <id> "<rule>"` rules, and each rule string SHALL appear
verbatim in the sibling `.md`. A `.md` without a sidecar SHALL declare
`caffeine-mode: doc-only`. Every sidecar SHALL have a bats file at
`test/caffeine_<ns>_<topic>.bats`.

#### Scenario: A sidecar without its doc is malformed
- **WHEN** a `caffeine/<ns>/<topic>.sh` exists with no sibling `.md`
- **THEN** the caffeine lint exits non-zero naming the missing doc

#### Scenario: Rule drift is caught
- **WHEN** a sidecar's `check` rule string does not appear in the
  sibling doc
- **THEN** the lint exits non-zero naming the topic and rule

#### Scenario: Doc-only is declared, never inferred
- **WHEN** a `.md` has no sidecar and no `caffeine-mode: doc-only` line
- **THEN** the lint exits non-zero naming the missing declaration

#### Scenario: Missing provenance is a defect
- **WHEN** a topic doc lacks any of the four metadata fields
- **THEN** the lint exits non-zero naming the file and field
