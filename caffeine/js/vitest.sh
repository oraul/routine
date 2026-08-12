#!/usr/bin/env bash
# Caffeine sidecar: mechanical Vitest hygiene, scoped to test files.
# Judges nothing a grep cannot see; judgment lives in vitest.md.
# caffeine-topic: js/vitest
# caffeine-applies: vitest >=1
# caffeine-reviewed: 2026-08-12
set -u

# shellcheck source-path=SCRIPTDIR/../..
# shellcheck source=lib/sidecar.sh
. "$(cd "$(dirname "$0")/../.." && pwd)/lib/sidecar.sh"
sidecar_init js/vitest
sidecar_include="*.test.js *.test.ts *.spec.js *.spec.ts *.test.mjs"

check V1 "focused test left in (.only)" \
  '(describe|it|test)\.only\(' "$target"
check V2 "silently skipped test (.skip)" \
  '(describe|it|test)\.skip\(' "$target"
check V3 "raw setTimeout in a test (use vi.useFakeTimers)" \
  'setTimeout\(' "$target"
check V4 "console.log in a test" \
  '^[[:space:]]*console\.log\(' "$target"

exit "$fails"
