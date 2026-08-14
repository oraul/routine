## 1. The gate's reasons survive

- [x] 1.1 Red→green: `routine-gate` mirrors its diagnostics and stage
      output to a truncated-per-run `<ticket>/gate.log`, leaving live
      output unchanged and never touching a ticket on a usage error

## 2. Health names the survivor

- [x] 2.1 Red→green: a non-empty `gate.log` is named in the health
      report as the surviving reason
