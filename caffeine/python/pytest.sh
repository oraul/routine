#!/usr/bin/env bash
# Caffeine sidecar: mechanical pytest hygiene, scoped to test files.
# Judges nothing a grep cannot see; judgment lives in pytest.md.
# caffeine-topic: python/pytest
# caffeine-applies: pytest >=7
# caffeine-reviewed: 2026-08-12
set -u

# shellcheck source-path=SCRIPTDIR/../..
# shellcheck source=lib/sidecar.sh
. "$(cd "$(dirname "$0")/../.." && pwd)/lib/sidecar.sh"
sidecar_init python/pytest
sidecar_include="test_*.py *_test.py conftest.py"

check P1 "skip without a reason is a silent deletion" \
  'mark\.skip(\(\)|$)' "$target"
check P2 "time.sleep in a test (fake the clock)" \
  'time\.sleep\(' "$target"
check P3 "placeholder assertion (assert True)" \
  'assert[[:space:]]+(True|1)[[:space:]]*$' "$target"

exit "$fails"
