## Why

Two council findings survived the C1–C5 sweep: three harness scripts
(`selfcheck`, `release-check`, `convention-check`) still emit no
telemetry — "6 of 14 silent scripts" only half-closed — and the run
audit never demands preflight evidence, though the protocol's chain
starts there.

## What Changes

- **Harness scripts leave evidence where a destination exists**: each of
  the three emits one line (`harness.selfcheck`, `harness.release`,
  `harness.convention`) with its exit code to
  `runs/<app>/telemetry.jsonl`, following the `app.deps` precedent —
  app derived from `TARGET` (default: current directory), clean no-op
  when no app state exists. Scripts never invent a destination.
- **The audit requires a passing `gate.preflight`** on the ticket's
  record, closing the replay chain's first link.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `telemetry`: harness-script evidence with the no-op rule.
- `audit`: preflight joins the run-level checks.

## Impact

- Modified: `bin/routine-selfcheck`, `bin/routine-release-check`,
  `bin/routine-convention-check`, `bin/routine-audit`, their tests, and
  the audit/conclude fixtures (which gain the preflight line).
