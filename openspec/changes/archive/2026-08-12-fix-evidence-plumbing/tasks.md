## 1. Preflight fails closed

- [x] 1.1 Red→green: `routine-gate preflight` without `ROUTINE_TICKET_DIR`
      exits non-zero naming the context; gate tests carry ticket fixtures

## 2. Loud emission

- [x] 2.1 Red→green: `routine-tdd` exits 3 naming the cause when the
      telemetry write fails (quoted scenario), never printing "recorded"

## 3. Command-bound evidence

- [x] 3.1 Red→green: the recorded scenario carries the command hash
      (`<scenario> [<hash8>]`); same command pairs, different command
      does not
