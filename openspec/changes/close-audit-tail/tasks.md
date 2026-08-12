## 1. No silent scripts

- [x] 1.1 Red→green: selfcheck, release-check, and convention-check emit
      `harness.*` events to `runs/<app>/telemetry.jsonl` when app state
      exists, no-op otherwise

## 2. The chain starts at preflight

- [ ] 2.1 Red→green: the audit requires one passing `gate.preflight`
      line; audit and conclude fixtures gain it
