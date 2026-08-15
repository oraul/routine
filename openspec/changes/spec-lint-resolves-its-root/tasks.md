## 1. The grammar lint obeys the law it enforces

- [ ] 1.1 Red→green: `routine-spec-lint` resolves its caffeine root
      through `routine_root()`, pinned by the consequence — a fixture
      `ROUTINE_ROOT` redirects manifest resolution, so a topic present
      only in the fixture resolves and one present only in the real
      corpus does not
