## MODIFIED Requirements

### Requirement: Dependency discovery is scripted
`bin/routine-deps` SHALL detect the target project's dependency manifests —
`Gemfile`, `package.json`, `requirements.txt` — under `TARGET` (default:
current directory), SHALL extract direct dependency names using grep/awk
only, and SHALL print one caffeine topic per line: `ruby/<gem>` from a
Gemfile, `js/<package>` from package.json dependencies and devDependencies,
`python/<package>` from requirements.txt. Extracted names SHALL be
canonicalized through `caffeine/aliases.tsv` (`<emitted>` TAB
`<topic> [<topic>…]`): a matching row replaces the emitted name with its
topics (one-to-many rows express implied topics); names without a row
pass through unchanged. When no known manifest exists it SHALL exit
non-zero naming the manifests it looked for. When `runs/<app>/` exists
for the target it SHALL emit one `app.deps` line with its exit code to
`runs/<app>/telemetry.jsonl`; without app state it SHALL emit nothing
rather than invent a destination.

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

#### Scenario: Discovery leaves app-level evidence
- **WHEN** `routine-deps` runs for a target whose `runs/<app>/` exists
- **THEN** `runs/<app>/telemetry.jsonl` gains one `app.deps` line

#### Scenario: Aliases land on real topics
- **WHEN** the Gemfile declares `gem "rspec-rails"`
- **THEN** the output contains `ruby/rspec` and not `ruby/rspec-rails`

#### Scenario: A topic can be implied
- **WHEN** the Gemfile declares `gem "rails"`
- **THEN** the output contains `ruby/active_record` alongside
  `ruby/rails`

## ADDED Requirements

### Requirement: The catalog is computed, never stored
`bin/routine-caffeine-list` SHALL walk the routine root's `caffeine/`
topics and print one line per topic — the topic, its mode (`pair` or
`doc-only`), and the doc's first prose line — deriving everything from
the tree at run time. `bin/routine-spec-lint` SHALL, when a manifest
topic resolves to nothing, list the available topics in the failure
output.

#### Scenario: The vocabulary is browsable
- **WHEN** `routine-caffeine-list` runs
- **THEN** every topic under `caffeine/` appears with its mode and lede

#### Scenario: Refusals teach
- **WHEN** a manifest names an unresolvable topic
- **THEN** the lint failure names the topic and lists the available ones
