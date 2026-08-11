# caffeine Specification

## Purpose

Per-topic developer support: a teaching doc the developer loads only when
the briefing's manifest names it, and a sidecar that mechanically checks the
code against that topic's enforceable rules.

## Requirements

### Requirement: Sidecars are mechanical checkers with gate semantics
Each caffeine sidecar (`caffeine/<lang>/<topic>.sh`) SHALL check the code
under `TARGET` (default: current directory) against 3–5 mechanical,
grep-able rules, SHALL print every hit with its file, line, and rule, SHALL
exit 0 only when no rule matches, and SHALL judge nothing a grep cannot see
— judgment guidance lives in the paired `.md`.

#### Scenario: Clean target passes
- **WHEN** the target contains no rule violations
- **THEN** the sidecar exits 0

#### Scenario: Violation named
- **WHEN** a target file trips a rule
- **THEN** the sidecar exits non-zero printing the file, line, and rule

### Requirement: The Ruby seeds cover rails and active_record
`caffeine/ruby/rails.sh` SHALL flag leftover debugger calls,
string-interpolated SQL in query methods, `puts` in `app/` code, and
`rescue Exception`. `caffeine/ruby/active_record.sh` SHALL flag
`update_attribute(`, `.all.each`, `save(validate: false)`, and
`default_scope`. Each rule SHALL have its own test fixture.

#### Scenario: Interpolated SQL caught
- **WHEN** a target file calls `where("name = #{params[:n]}")`
- **THEN** `rails.sh` exits non-zero naming that line

#### Scenario: Unbatched iteration caught
- **WHEN** a target file calls `User.all.each`
- **THEN** `active_record.sh` exits non-zero naming that line

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

### Requirement: The ruby/sidekiq pair covers job hygiene
`caffeine/ruby/sidekiq.sh` SHALL flag `include Sidekiq::Worker` (legacy
API), keyword arguments passed to `perform_async`, `perform_in`, or
`perform_at` (arguments must be JSON-native), `sleep` inside job class
files, and `sidekiq_options` declaring `retry: false`. Each rule SHALL have
its own test fixture, and `caffeine/ruby/sidekiq.md` SHALL carry the
judgment guidance the greps cannot.

#### Scenario: Keyword arguments caught
- **WHEN** a target file calls `HardJob.perform_async(user_id: 1)`
- **THEN** `sidekiq.sh` exits non-zero naming that line

#### Scenario: Clean job code passes
- **WHEN** jobs use `Sidekiq::Job`, positional JSON-native arguments, and
  default retry behavior
- **THEN** `sidekiq.sh` exits 0
