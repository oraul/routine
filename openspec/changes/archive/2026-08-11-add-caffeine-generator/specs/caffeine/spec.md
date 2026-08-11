## ADDED Requirements

### Requirement: Dependency discovery is scripted
`bin/routine-deps` SHALL detect the target project's dependency manifests —
`Gemfile`, `package.json`, `requirements.txt` — under `TARGET` (default:
current directory), SHALL extract direct dependency names using grep/awk
only, and SHALL print one caffeine topic per line: `ruby/<gem>` from a
Gemfile, `js/<package>` from package.json dependencies and devDependencies,
`python/<package>` from requirements.txt. When no known manifest exists it
SHALL exit non-zero naming the manifests it looked for.

#### Scenario: Gemfile topics
- **WHEN** the target's Gemfile declares `gem "rails"` and `gem 'pg'`
- **THEN** the output contains `ruby/rails` and `ruby/pg`

#### Scenario: package.json topics
- **WHEN** the target's package.json declares a dependency `"express"`
- **THEN** the output contains `js/express`

#### Scenario: No manifest
- **WHEN** the target has no known manifest
- **THEN** `routine-deps` exits non-zero naming Gemfile, package.json, and
  requirements.txt

### Requirement: Caffeine generation is gated, not trusted
`skills/caffeinate/SKILL.md` SHALL be human-invoked only and SHALL
instruct: discover topics via `routine-deps`; let the human select which to
generate; for each selected topic draft the `caffeine/<topic>.md` guidance
and a `caffeine/<topic>.sh` sidecar with 3–5 mechanical grep-able rules and
one bats fixture per rule, following the existing sidecar contract; and
treat generation as complete only when `routine-selfcheck` passes over the
result. Generated pairs SHALL reach the repository through the normal
change loop, never by direct commit to main.

#### Scenario: Generation protocol present in the skill
- **WHEN** the skill file is read
- **THEN** it names routine-deps discovery, human topic selection, the
  3–5-rule sidecar contract with per-rule fixtures, and the
  selfcheck-green completion condition
