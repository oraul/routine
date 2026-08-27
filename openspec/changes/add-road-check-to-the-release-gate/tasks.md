## 1. The road registry is judged when a release is cut

- [x] 1.1 Red→green: `routine-road-check` prints that it decided
      nothing and exits 0 when the runs directory holds no telemetry at
      all, while a corpus holding telemetry still decides both rules as
      before — `test/road_check.bats`
- [x] 1.2 Red→green: `bin/routine-release-check` invokes
      `routine-road-check` and relays its verdict and output rather
      than restating the comparison, refusing the release when a road
      violation is reported — `test/release_check.bats`
- [ ] 1.3 Declare `harness.render` in `lib/roads.txt` and refile
      `ticket.replay` into the `ticket` block, showing `road-check`
      red before and green after
