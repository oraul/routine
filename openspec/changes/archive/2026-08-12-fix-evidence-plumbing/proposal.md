## Why

The agents council found the loop's worst class of defect is silent
evidence loss: `routine-gate preflight` without a ticket context prints
success, records nothing, and kills the ticket at conclude (the audit
demands a passing `gate.preflight` line, and there is no repair path);
`routine-tdd` ignores the telemetry writer's rejection of a quoted
scenario string — evidence vanishes while the developer reads
"recorded"; and nothing links a red to the command that produced it, so
`red -- false` then `green -- true` yields perfect evidence — the
cheapest gaming vector in the system.

## What Changes

- **Preflight fails closed without a ticket context**, matching the
  analyst and developer gates: the audit demands preflight evidence, so
  a preflight that cannot record is a protocol error at the moment it
  happens, not at conclude.
- **`routine-tdd` fails loudly when emission fails**: a rejected
  scenario value (quote, newline) or any telemetry write failure exits
  non-zero naming the cause — never "recorded" with nothing recorded.
- **The evidence binds to the command**: `routine-tdd` appends a short
  hash of the test command to the scenario it records
  (`<scenario> [<hash8>]`). The audit's byte-exact pairing then enforces
  red and green ran the *same command* with zero schema change — a red
  from one test cannot green with another.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `gates`: preflight requires the ticket context.
- `tdd`: loud emission failure; command-bound evidence.

## Impact

- Modified: `bin/routine-gate`, `bin/routine-tdd`, `test/gate.bats`
  (preflight tests gain ticket contexts), `test/tdd.bats`,
  `agents/developer.md` (the recorded-scenario form shown truthfully).
