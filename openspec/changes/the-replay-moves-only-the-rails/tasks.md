# Tasks — the-replay-moves-only-the-rails

## 1. The instrument

- [x] 1.1 Red→green: `bin/routine-replay` refuses — usage, missing
      requirement, missing or malformed anchor, unreachable anchor —
      creating nothing lasting; `test/replay.bats`
- [ ] 1.2 Red→green: the happy path — worktree at the anchor under
      `runs/<app>/replays/…/<app>`, byte-identical requirement,
      `replay.md` provenance, `ticket.replay` telemetry, the archived
      final event printed; a refused allocation removes the worktree —
      `test/replay.bats`

## 2. The road

- [ ] 2.1 Red→green: `ticket.replay` declared in `lib/roads.txt` with
      its honest waiver; the road-check waiver test renamed for two
      waivers and pinning both — `test/road_check.bats`
