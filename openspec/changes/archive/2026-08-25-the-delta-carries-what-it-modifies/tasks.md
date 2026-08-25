# Tasks — the-delta-carries-what-it-modifies

## 1. The carry becomes an exit code

- [x] 1.1 Red→green: `bin/routine-change-check <change-id>` passes a
      complete carry (extended-in-place lines included), names the
      capability, requirement, and first lost line of an incomplete
      one, fails a MODIFIED requirement absent from the live spec,
      exits 2 on a missing or unknown id, and emits one
      `harness.change` telemetry line per run with the road declared
      in `lib/roads.txt` — `test/change_check.bats`
