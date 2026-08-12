#!/usr/bin/env bash
# Caffeine sidecar: mechanical RSpec hygiene, scoped to spec/. Judges
# nothing a grep cannot see; structure lives in rspec.md. TARGET = the app.
# caffeine-topic: ruby/rspec
# caffeine-applies: rspec >=3.0
# caffeine-reviewed: 2026-08-12
set -u

# shellcheck source-path=SCRIPTDIR/../..
# shellcheck source=lib/sidecar.sh
. "$(cd "$(dirname "$0")/../.." && pwd)/lib/sidecar.sh"
sidecar_init ruby/rspec

check S1 "legacy should syntax (use expect)" '\.should(_not)?([[:space:]]|\()' "$target/spec"
check S2 "leftover focus mark" '(^|[[:space:]])(fit|fdescribe|fcontext)([[:space:]]|\()|focus:[[:space:]]*true' "$target/spec"
check S3 "sleep in a spec (use test doubles or travel helpers)" '(^|[^a-z_.])sleep([[:space:]]|\()' "$target/spec"
check S4 "any_instance stubs objects the example never built" 'any_instance(_of)?\(' "$target/spec"

exit "$fails"
