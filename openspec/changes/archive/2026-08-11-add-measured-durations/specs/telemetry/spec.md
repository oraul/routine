## ADDED Requirements

### Requirement: Durations are measured at platform precision
Every emitting script SHALL record its measured duration in the `ms` field
via a shared clock helper that SHALL return milliseconds where the
platform's `date` supports nanoseconds and whole seconds × 1000 otherwise,
detected at runtime. A constant duration SHALL never be emitted.

#### Scenario: Millisecond clock on GNU date
- **WHEN** the platform's `date +%s%N` prints digits
- **THEN** the helper returns epoch milliseconds

#### Scenario: Fallback on BSD date
- **WHEN** `date +%s%N` prints a literal `N` suffix
- **THEN** the helper returns epoch seconds × 1000
