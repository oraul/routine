## 1. A harness footprint is not a run corpus

- [x] 1.1 Red→green: `routine-road-check` resolves the run corpus
      through `lib/corpus.sh` rather than a second definition, and emits
      nothing on the undecided path so two consecutive runs agree —
      `test/road_check.bats`
- [ ] 1.2 Red→green: the undeclared-road rule decides with or without a
      run corpus, while only the unwalked-road rule waits for one, so
      the release gate still catches an undeclared road on a machine
      that has never run a ticket — `test/road_check.bats`,
      `test/release_check.bats`
