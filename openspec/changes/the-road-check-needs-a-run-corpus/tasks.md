## 1. A harness footprint is not a run corpus

- [ ] 1.1 Red→green: `routine-road-check` treats the absence of ticket
      telemetry as the undecided case, resolved through `lib/corpus.sh`
      rather than a second definition, and emits nothing on that path so
      two consecutive runs agree; with a run corpus present it still
      judges every telemetry line including the harness tier —
      `test/road_check.bats`
