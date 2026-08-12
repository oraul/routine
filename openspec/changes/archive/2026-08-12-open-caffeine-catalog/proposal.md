## Why

The council mapped the discovery-to-content gap: of the ten topic
strings `routine-deps`' own tests assert, one resolves.
`ruby/active_record` is permanently undiscoverable (the gem is
`activerecord` and transitive in Rails apps); `rspec-rails` emits a dead
string the tests lock in; there is no catalog anywhere for the analyst
to browse; the lint refuses unknown topics without naming alternatives
against a 3-revise cap; and the two architecture docs are orphaned —
zero references from calibration or agents.

## What Changes

- **The catalog is computed, never stored**: `bin/routine-caffeine-list`
  walks `caffeine/` and prints every topic with its mode (pair/doc-only)
  and lede line — the browsable vocabulary the analyst was missing.
- **`routine-spec-lint` failures teach**: an unresolvable manifest topic
  now lists the available topics in the same breath.
- **Canonicalization via `caffeine/aliases.tsv`**: discovery output maps
  through an alias table — `ruby/activerecord` and `ruby/rspec-rails`
  land on the real topics, and `ruby/rails` also implies
  `ruby/active_record` (transitive in every Rails app). Unknown names
  pass through untouched; the table is data, not code.
- **The orphans get inbound edges**: `calibration/greenfield.md` names
  `architecture/hexagonal`, `calibration/feature.md` names
  `architecture/oop`, and `agents/analyst.md` names the catalog command
  where it teaches manifest authoring.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `caffeine`: dependency discovery canonicalizes through the alias
  table; the computed catalog and the teaching lint failure become
  requirements.

## Impact

- Added: `bin/routine-caffeine-list`, `caffeine/aliases.tsv`,
  `test/caffeine_list.bats`. Modified: `bin/routine-deps`,
  `bin/routine-spec-lint`, `test/deps.bats`, `test/spec_lint.bats`,
  `calibration/{greenfield,feature}.md`, `agents/analyst.md`.
