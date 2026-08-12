#!/usr/bin/env bash
# Caffeine sidecar: mechanical ActiveRecord rules. Judges nothing a grep
# cannot see; judgment guidance lives in active_record.md. TARGET = the app.
# caffeine-topic: ruby/active_record
# caffeine-applies: rails >=7.0
# caffeine-reviewed: 2026-08-12
set -u

# shellcheck source-path=SCRIPTDIR/../..
# shellcheck source=lib/sidecar.sh
. "$(cd "$(dirname "$0")/../.." && pwd)/lib/sidecar.sh"
sidecar_init ruby/active_record

check A1 "update_attribute/update_column skip validations (use update!)" \
  'update_(attribute|column|columns|attributes)\(' "$target"
check A2 "unbatched iteration (use find_each)" \
  '\.(all|where\([^)]*\))\.(each|map)' "$target"
check A3 "save(validate: false) skips validations" \
  'save!?[( ][^)]*validate:[[:space:]]*false' "$target"
check A4 "default_scope (prefer named scopes)" '(^|[[:space:]])default_scope' "$target"

exit "$fails"
