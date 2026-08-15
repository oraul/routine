## 1. The isolation rule

- [x] 1.1 Red→green: `routine-test-lint` refuses a suite that uses
      `BATS_SUITE_TMPDIR` or `BATS_FILE_TMPDIR` and a test that writes
      into `$ROUTINE_REPO_ROOT`, accepts reads of the repository
      unrestricted, reports the isolation rule distinctly, and passes the
      corpus unchanged
