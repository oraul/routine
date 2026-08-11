## ADDED Requirements

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
