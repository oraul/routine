## Why

The `/caffeinate` protocol exists but has never produced a pair. This change
runs it for real: `ruby/sidekiq` — a dependency whose documented footguns
are genuinely grep-able — proving generated caffeine meets the hand-written
bar.

## What Changes

- Add `caffeine/ruby/sidekiq.{md,sh}` following the sidecar contract: four
  mechanical rules (legacy `include Sidekiq::Worker`, non-JSON keyword
  arguments to `perform_async`/`perform_in`/`perform_at`, `sleep` inside
  job classes, `retry: false` without a stated dead-set plan), one bats
  fixture per rule plus a clean fixture; judgment guidance in the `.md`.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `caffeine`: gains the `ruby/sidekiq` pair requirement alongside the two
  founding seeds.

## Impact

- New: `caffeine/ruby/sidekiq.md`, `caffeine/ruby/sidekiq.sh`,
  `test/caffeine_sidekiq.bats`. First output of the `/caffeinate` protocol.
