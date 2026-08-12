## MODIFIED Requirements

### Requirement: Dependency discovery is scripted
`bin/routine-deps` SHALL detect the target project's dependency manifests —
`Gemfile`, `package.json`, `requirements.txt` — under `TARGET` (default:
current directory), SHALL extract direct dependency names using grep/awk
only, and SHALL print one caffeine topic per line: `ruby/<gem>` from a
Gemfile, `js/<package>` from package.json dependencies and devDependencies,
`python/<package>` from requirements.txt. When no known manifest exists it
SHALL exit non-zero naming the manifests it looked for. When
`runs/<app>/` exists for the target it SHALL emit one `app.deps` line
with its exit code to `runs/<app>/telemetry.jsonl`; without app state it
SHALL emit nothing rather than invent a destination.

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
