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
