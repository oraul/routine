## Why

The council verified the sidecars are buggy instruments: vendor
filtering suppresses any hit whose *content* mentions `/vendor/`
(silent false negatives in every rule of every sidecar);
`rescue ExceptionNotifier::Error` trips the `rescue Exception` rule
while `rescue ::Exception` escapes it; the word "fit" in an ordinary
example description fails the gate; `perform_async("https://…")`
false-fires on the colon inside the string; a sidecar that cannot run
exits 0 — indistinguishable from a clean repo; rules have no parseable
ids; and the four scripts are copy-paste siblings, so every one of
these was a four-file bug.

## What Changes

- **A shared sidecar library** (`lib/sidecar.sh`): one `scan`/`check`
  implementation, `TARGET` resolution, and exit semantics. `check` takes
  a rule id (`check R1 "<rule>" '<pattern>' [scope]`) and hits print as
  `caffeine/<ns>/<topic>[R1] <rule>: path:line:content` — a parseable,
  referenceable handle. A grep internal error exits 2: a broken sidecar
  can no longer masquerade as a clean repo.
- **Vendor exclusion by directory** (`--exclude-dir=vendor` +
  node_modules/tmp/coverage), not by filtering output lines — content
  mentioning `/vendor/` no longer hides real hits, and
  `app/models/vendor/` no longer gets a free pass by accident.
- **The three verified-wrong patterns repaired**: `rescue Exception`
  gains its right boundary (and catches `::Exception`); focus marks are
  line-anchored (prose "fit" passes, `:focus` metadata caught); kwargs
  detection requires a colon-space after `(` or `,` (URLs pass).
- **High-signal rules join, within the 3–5 contract**: rails gains the
  mass-assignment escape (`permit!`/`to_unsafe_h`); active_record's
  narrow rules broaden (`update_column(s)`/`update_attributes`,
  `where(...).each`, `save!`/paren-less forms); rspec gains silently
  disabled examples (`xit`/`xdescribe`/`xcontext`) and scans all of
  `spec/` (support files included); sidekiq gains the removed `.delay`
  extensions.
- **The test matrix closes**: every changed pattern gets a tripping
  fixture *and* a near-miss passing fixture (the near-misses are what
  would have caught these bugs the day they were written).

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `caffeine`: sidecar requirement gains the shared library, rule ids,
  directory-based exclusion, and internal-error semantics; the topic
  contract's rule extraction follows the new `check` signature.

## Impact

- Added: `lib/sidecar.sh`. Modified: all four sidecars, their guides'
  verbatim rule lists, `bin/routine-caffeine-lint` (rule extraction),
  the four `test/caffeine_ruby_*.bats` files.
