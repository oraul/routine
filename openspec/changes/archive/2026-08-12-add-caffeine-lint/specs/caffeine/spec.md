## ADDED Requirements

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
3 and 5 `check` rules, and each rule string SHALL appear verbatim in the
sibling `.md`. A `.md` without a sidecar SHALL declare
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

### Requirement: The caffeine lint is scripted
`bin/routine-caffeine-lint` SHALL walk every topic under the routine
root's `caffeine/` directory, check the topic contract, report every
violation in one run, and exit non-zero when any exists; an absent or
empty `caffeine/` SHALL pass. It SHALL emit one `harness.caffeine` line
per run under the harness-evidence rule.

#### Scenario: All violations in one run
- **WHEN** two topics each violate the contract
- **THEN** one lint run reports both and exits non-zero

#### Scenario: Empty corpus passes
- **WHEN** the routine root has no `caffeine/` topics
- **THEN** the lint exits 0

## REMOVED Requirements

### Requirement: The Ruby seeds cover rails and active_record
**Reason**: Per-topic spec requirements grow O(n) with the catalog; the
generic topic contract now owns pair integrity and rule discipline, and
per-topic rules live in the topics themselves.

### Requirement: The ruby/sidekiq pair covers job hygiene
**Reason**: Folded into the topic contract; the sidecar's rule strings
are the canonical per-topic record.

### Requirement: The ruby/rspec pair covers spec structure and hygiene
**Reason**: Folded into the topic contract; the sidecar's rule strings
are the canonical per-topic record.
