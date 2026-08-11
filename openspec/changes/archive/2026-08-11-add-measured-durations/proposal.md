## Why

Telemetry's `ms` field is honest only for gates; every lifecycle script
hardcodes `0`, so the retro's duration statistics describe nothing. The
platform limits precision (BSD `date` has no nanoseconds) but not honesty:
measure everywhere, at the best precision the platform provides.

## What Changes

- Add `routine_now_ms` to `lib/telemetry.sh`: milliseconds from
  `date +%s%N` where supported (GNU/Linux, CI), whole-second × 1000
  fallback where not (BSD/macOS) — detected at runtime, no configuration.
- Every telemetry-emitting script (`routine-gate`, `routine-next`,
  `routine-done`, `routine-block`, `routine-unblock`, `routine-conclude`,
  `routine-spec-lint`, `routine-ticket-new`) records its measured duration
  instead of a constant.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `telemetry`: durations are measured, never constant.

## Impact

- Modified: `lib/telemetry.sh`, the eight emitting scripts, telemetry
  tests. Retro duration statistics become meaningful on Linux immediately
  and second-resolution on macOS.
