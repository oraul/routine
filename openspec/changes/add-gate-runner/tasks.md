## 1. Telemetry helper

- [ ] 1.1 Red→green: `lib/telemetry.sh` emit function appends one JSON line
      with fixed key order `ts,event,script,ticket,task,exit,ms` to a named
      file, append-only, verified against fixture files
- [ ] 1.2 Red→green: emission is skipped cleanly when `ROUTINE_TICKET_DIR` is
      unset, and rejected (non-zero) when a value contains quotes or newlines

## 2. Gate runner

- [ ] 2.1 Red→green: `bin/routine-gate` argument handling — unknown or missing
      gate name exits non-zero naming the valid gates
- [ ] 2.2 Red→green: stage composition — baseline then hook, first failure
      stops the run and surfaces output, hook exit codes relayed verbatim
- [ ] 2.3 Red→green: seam contract — missing optional hook logs one line and
      passes; missing `developer.sh` exits non-zero naming the exact file and
      a one-line delegation example

## 3. Preflight baseline

- [ ] 3.1 Red→green: selfcheck-first ordering — a red harness aborts preflight
      before any target check
- [ ] 3.2 Red→green: target checks against fixture git repos — dirty worktree
      and detached HEAD each fail with their reason; clean-on-branch passes

## 4. Wiring

- [ ] 4.1 Red→green: each gate run emits exactly one `gate.<name>` telemetry
      line into `ROUTINE_TICKET_DIR` when set, none when unset
