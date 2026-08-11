# Shared bats setup. Resolves the repo root once so tests never hardcode
# paths (Law 6); individual suites may override ROUTINE_ROOT per test.

setup() {
  ROUTINE_REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export ROUTINE_REPO_ROOT
}
