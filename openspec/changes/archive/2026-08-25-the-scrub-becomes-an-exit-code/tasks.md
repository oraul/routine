# Tasks — the-scrub-becomes-an-exit-code

## 1. One pattern list, then the check that uses it

- [x] 1.1 Red→green: the sensitive patterns live once in
      `lib/sensitive.sh` and `routine-convention-check` sources them,
      behavior unchanged — `test/convention_check.bats` pins the
      library and keeps the behavior honest
- [x] 1.2 Red→green: `bin/routine-pr-body-check <file>` refuses a body
      carrying any shared sensitive shape, naming line and pattern
      class without echoing the match; clean body exits 0; usage exits
      2; one `harness.prbody` telemetry line per run and the road
      declared in `lib/roads.txt` — `test/pr_body_check.bats`
