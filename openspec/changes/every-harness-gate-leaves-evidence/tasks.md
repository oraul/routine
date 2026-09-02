## 1. The lints leave evidence like their siblings

- [x] 1.1 Red→green: `routine-record-lint` emits one `harness.record`
      line per run where `runs/<app>/` exists and nothing otherwise, its
      exit code unchanged; `harness.record` declared in `lib/roads.txt`
      — `test/record_lint.bats`
- [ ] 1.2 Red→green: `routine-test-lint` emits one `harness.test` line
      per run where `runs/<app>/` exists and nothing otherwise, its exit
      code unchanged; `harness.test` declared in `lib/roads.txt` —
      `test/test_lint.bats`
