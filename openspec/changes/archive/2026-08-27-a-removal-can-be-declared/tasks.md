## 1. A declared removal stops being a loss

- [x] 1.1 Red→green: `routine-change-check` reads a delta file's
      `## Removed Lines` bullets and exempts exactly those live lines,
      while an undeclared loss beside a declared one still fails
      naming only the undeclared line — `test/change_check.bats`
