# Tasks — the-roads-are-declared-and-walked

## 1. The repository ships its own harness destination

- [x] 1.1 Red→green: `.gitignore` restructured to re-include exactly
      `runs/routine/README.md`, the marker committed, pinned by
      `git check-ignore` and `git ls-files` assertions in
      `test/harness_telemetry.bats`

## 2. Declared roads are walked or waivered

- [x] 2.1 Red→green: `lib/roads.txt` seeded with the measured 28 events
      plus `harness.roads` (sole waiver: `app.deps`), and
      `bin/routine-road-check` passes a clean fixture, exits 2 on a
      missing runs directory or roads file — `test/road_check.bats`
- [ ] 2.2 Red→green: the three violation roads — undeclared walked,
      declared unwalked, stale waiver — each named, all reported in one
      run, exit 1; nested ticket telemetry counts as walked —
      `test/road_check.bats`
