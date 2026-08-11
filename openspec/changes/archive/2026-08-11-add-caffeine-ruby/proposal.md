## Why

The developer gate still runs on hooks alone; caffeine is the mechanism that
teaches the developer per topic and mechanically checks the code against
that topic's enforceable rules. The two Ruby seeds prove the pattern the
whole caffeine layer will follow.

## What Changes

- Add `caffeine/ruby/rails.{md,sh}`: the teaching doc and a sidecar with
  four grep-able rules (leftover debuggers, string-interpolated SQL,
  `puts` in app code, `rescue Exception`), each with its own fixture.
- Add `caffeine/ruby/active_record.{md,sh}`: teaching doc and a sidecar with
  four grep-able rules (`update_attribute`, `.all.each`,
  `save(validate: false)`, `default_scope`), each with its own fixture.
- Implement the developer gate baseline in `bin/routine-gate`: read the
  current task's briefing manifest (`## Caffeine`), run each named sidecar
  against `TARGET`, emit one `gate.developer.script` telemetry line per
  sidecar, fail on the first non-zero sidecar or a manifest entry with no
  sidecar file.

## Capabilities

### New Capabilities

- `caffeine`: the topic-pair contract — sidecar exit semantics,
  `TARGET` parameterization, fixture-tested mechanical rules, judgment
  guidance confined to the `.md`.

### Modified Capabilities

- `gates`: the developer gate gains its baseline (manifest-driven sidecar
  runs with per-script telemetry).

## Impact

- New: `caffeine/ruby/*`, their bats suites and fixtures.
- Modified: `bin/routine-gate` (developer baseline only), `test/gate.bats`.
- `routine-selfcheck` and CI already lint `caffeine/*/*.sh` by glob — no
  harness changes.
