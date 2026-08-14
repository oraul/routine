## 1. The shared episode counter

- [x] 1.1 Red→green: `lib/episode.sh` holds the revise count; the
      analyst gate consumes it with its behavior unchanged

## 2. The live-run reader

- [x] 2.1 Red→green: `routine-health <ticket-dir>` derives the phase,
      prints in-flight facts and the next command, with 0/1/2 exit
      semantics — one fixture per death point
- [x] 2.2 Red→green: no-argument mode resolves active tickets (zero,
      one, many) and warns on a stale `index.tsv.new`

## 3. Phase 0 stops guessing

- [x] 3.1 Red→green: the skill's phase 0 runs `routine-health` and
      branches on its exit code — pinned in `test/agents_content.bats`
